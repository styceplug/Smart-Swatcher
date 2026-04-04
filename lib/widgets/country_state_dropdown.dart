import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

class CountryService {
  static final CountryService _instance = CountryService._internal();
  factory CountryService() => _instance;
  CountryService._internal();

  List<CountryData>? _cachedCountries;
  Future<List<CountryData>>? _loadingFuture;

  // Load countries with caching
  Future<List<CountryData>> loadCountries() async {
    // Return cached data if available
    if (_cachedCountries != null) {
      return _cachedCountries!;
    }

    // If already loading, return the existing future
    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    // Start loading
    _loadingFuture = _loadCountriesFromAsset();
    _cachedCountries = await _loadingFuture!;
    _loadingFuture = null;

    return _cachedCountries!;
  }

  Future<List<CountryData>> _loadCountriesFromAsset() async {
    final jsonStr = await rootBundle.loadString('assets/countries_state.json');
    final List<dynamic> data = json.decode(jsonStr);
    return data.map((e) => CountryData.fromJson(e)).toList();
  }

  // Get countries synchronously (returns null if not loaded)
  List<CountryData>? getCachedCountries() => _cachedCountries;

  // Check if data is loaded
  bool get isLoaded => _cachedCountries != null;

  // Preload - call this in your app initialization
  Future<void> preload() async {
    await loadCountries();
  }

  // Clear cache if needed (e.g., for testing or updates)
  void clearCache() {
    _cachedCountries = null;
  }
}

class CountryData {
  final String name;
  final List<StateData> states;

  CountryData({required this.name, required this.states});

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      name: json['name'] as String,
      states:
          (json['states'] as List<dynamic>)
              .map((e) => StateData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class StateData {
  final String name;

  StateData({required this.name});

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(name: json['name'] as String);
  }
}

class CountryState extends StatefulWidget {
  final String? selectedCountry;
  final String? selectedState;
  final Function(String?) onCountryChanged;
  final Function(String?) onStateChanged;

  const CountryState({
    super.key,
    required this.selectedCountry,
    required this.selectedState,
    required this.onCountryChanged,
    required this.onStateChanged,
  });

  @override
  State<CountryState> createState() => _CountryStateState();
}

class _CountryStateState extends State<CountryState> {
  final _countryService = CountryService();
  late Future<List<CountryData>> _countriesFuture;

  @override
  void initState() {
    super.initState();
    _countriesFuture = _countryService.loadCountries();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CountryData>>(
      future: _countriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No countries available");
        }

        final countries = snapshot.data!;
        final countryNames = countries.map((c) => c.name).toList();
        final selectedCountryValue =
            countryNames.contains(widget.selectedCountry)
                ? widget.selectedCountry
                : null;

        final selectedCountryObj =
            selectedCountryValue != null
                ? countries.firstWhere(
                  (c) => c.name == selectedCountryValue,
                  orElse: () => countries.first,
                )
                : countries.first;

        final stateNames =
            selectedCountryObj.states.map((s) => s.name).toList();
        final selectedStateValue =
            stateNames.contains(widget.selectedState)
                ? widget.selectedState
                : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchSelectorField(
              label: 'Country',
              value: selectedCountryValue,
              hintText: 'Search country',
              icon: Icons.public_rounded,
              onTap: () async {
                final selected = await _showSelectionSheet(
                  context,
                  title: 'Select Country',
                  searchHint: 'Search country',
                  items: countryNames,
                  selectedValue: selectedCountryValue,
                  emptyText: 'No countries match your search.',
                );
                if (selected == null) return;
                widget.onCountryChanged(selected);
                widget.onStateChanged(null);
              },
            ),
            SizedBox(height: Dimensions.height20),
            _SearchSelectorField(
              label: 'State',
              value: selectedStateValue,
              hintText:
                  selectedCountryValue == null
                      ? 'Select country first'
                      : 'Search state',
              icon: Icons.location_on_outlined,
              enabled: selectedCountryValue != null && stateNames.isNotEmpty,
              onTap: () async {
                if (selectedCountryValue == null || stateNames.isEmpty) {
                  return;
                }
                final selected = await _showSelectionSheet(
                  context,
                  title: 'Select State',
                  searchHint: 'Search state',
                  items: stateNames,
                  selectedValue: selectedStateValue,
                  emptyText: 'No states match your search.',
                );
                if (selected == null) return;
                widget.onStateChanged(selected);
              },
            ),
          ],
        );
      },
    );
  }
}

class CountryDropdown extends StatefulWidget {
  final String? selectedCountry;
  final ValueChanged<String?> onCountryChanged;

  const CountryDropdown({
    super.key,
    this.selectedCountry,
    required this.onCountryChanged,
  });

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  final _countryService = CountryService();
  late Future<List<String>> _countriesFuture;

  @override
  void initState() {
    super.initState();
    _countriesFuture = _loadCountryNames();
  }

  Future<List<String>> _loadCountryNames() async {
    final countries = await _countryService.loadCountries();
    return countries.map((c) => c.name).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _countriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No countries available");
        }

        final countries = snapshot.data!;
        final selectedCountryValue =
            countries.contains(widget.selectedCountry)
                ? widget.selectedCountry
                : null;

        return _SearchSelectorField(
          label: 'Country',
          value: selectedCountryValue,
          hintText: 'Search country',
          icon: Icons.public_rounded,
          onTap: () async {
            final selected = await _showSelectionSheet(
              context,
              title: 'Select Country',
              searchHint: 'Search country',
              items: countries,
              selectedValue: selectedCountryValue,
              emptyText: 'No countries match your search.',
            );
            if (selected == null) return;
            widget.onCountryChanged(selected);
          },
        );
      },
    );
  }
}

Future<String?> _showSelectionSheet(
  BuildContext context, {
  required String title,
  required String searchHint,
  required List<String> items,
  required String? selectedValue,
  required String emptyText,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return _SelectionSheet(
        title: title,
        searchHint: searchHint,
        items: items,
        selectedValue: selectedValue,
        emptyText: emptyText,
      );
    },
  );
}

class _SearchSelectorField extends StatelessWidget {
  const _SearchSelectorField({
    required this.label,
    required this.hintText,
    required this.icon,
    required this.onTap,
    this.value,
    this.enabled = true,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final VoidCallback onTap;
  final String? value;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decorationTheme = theme.inputDecorationTheme;
    final hasValue = value != null && value!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: Dimensions.font14,
            fontWeight: FontWeight.w600,
            color: AppColors.black1,
          ),
        ),
        SizedBox(height: Dimensions.height8),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          child: InputDecorator(
            decoration: InputDecoration(
              filled: decorationTheme.filled,
              fillColor:
                  enabled
                      ? decorationTheme.fillColor
                      : AppColors.grey2.withValues(alpha: 0.55),
              contentPadding: decorationTheme.contentPadding,
              prefixIcon: Icon(icon, color: AppColors.primary4),
              suffixIcon: Icon(
                Icons.search_rounded,
                color: enabled ? AppColors.primary4 : AppColors.grey4,
              ),
              border: decorationTheme.border,
              enabledBorder: decorationTheme.enabledBorder,
              focusedBorder: decorationTheme.focusedBorder,
              errorBorder: decorationTheme.errorBorder,
              focusedErrorBorder: decorationTheme.focusedErrorBorder,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value! : hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font15,
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                      color: hasValue ? AppColors.black1 : theme.hintColor,
                    ),
                  ),
                ),
                if (enabled)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary1,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Search',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionSheet extends StatefulWidget {
  const _SelectionSheet({
    required this.title,
    required this.searchHint,
    required this.items,
    required this.selectedValue,
    required this.emptyText,
  });

  final String title;
  final String searchHint;
  final List<String> items;
  final String? selectedValue;
  final String emptyText;

  @override
  State<_SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<_SelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems =
        widget.items
            .where(
              (item) => item.toLowerCase().contains(_query.trim().toLowerCase()),
            )
            .toList();

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.46,
        maxChildSize: 0.94,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                SizedBox(height: Dimensions.height12),
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.grey3,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    Dimensions.height18,
                    Dimensions.width20,
                    Dimensions.height10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black1,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    0,
                    Dimensions.width20,
                    Dimensions.height12,
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (value) => setState(() => _query = value),
                    cursorColor: AppColors.primary5,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon:
                          _query.isEmpty
                              ? null
                              : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                    ),
                  ),
                ),
                Expanded(
                  child:
                      filteredItems.isEmpty
                          ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(Dimensions.width20),
                              child: Text(
                                widget.emptyText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.grey5,
                                  fontSize: Dimensions.font14,
                                ),
                              ),
                            ),
                          )
                          : ListView.separated(
                            controller: scrollController,
                            padding: EdgeInsets.fromLTRB(
                              Dimensions.width20,
                              0,
                              Dimensions.width20,
                              Dimensions.height30,
                            ),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isSelected = item == widget.selectedValue;

                              return Material(
                                color:
                                    isSelected
                                        ? AppColors.primary1.withValues(
                                          alpha: 0.8,
                                        )
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radius20,
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radius20,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.width15,
                                    vertical: Dimensions.height5,
                                  ),
                                  title: Text(
                                    item,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font15,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                      color: AppColors.black1,
                                    ),
                                  ),
                                  trailing:
                                      isSelected
                                          ? const Icon(
                                            Icons.check_circle_rounded,
                                            color: AppColors.primary5,
                                          )
                                          : const Icon(
                                            Icons.chevron_right_rounded,
                                            color: AppColors.grey4,
                                          ),
                                  onTap: () => Navigator.of(context).pop(item),
                                ),
                              );
                            },
                            separatorBuilder:
                                (_, __) =>
                                    SizedBox(height: Dimensions.height8),
                            itemCount: filteredItems.length,
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

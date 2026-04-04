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
            // COUNTRY
            DropdownButtonFormField<String>(
              initialValue: selectedCountryValue,
              decoration: _inputDecoration(),
              style: TextStyle(
                color: AppColors.black1,
                fontFamily: 'Poppins',
                fontSize: Dimensions.font15,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              iconEnabledColor: AppColors.primary4,
              items:
                  countryNames.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
              onChanged: (value) {
                widget.onCountryChanged(value);
                widget.onStateChanged(null);
              },
              hint: Text(
                "Choose a country",
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font14,
                ),
              ),
            ),

            SizedBox(height: 20),

            // STATE
            DropdownButtonFormField<String>(
              initialValue: selectedStateValue,
              style: TextStyle(
                color: AppColors.black1,
                fontFamily: 'Poppins',
                fontSize: Dimensions.font15,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              iconEnabledColor: AppColors.primary4,
              decoration: _inputDecoration(),
              items:
                  stateNames.map((state) {
                    return DropdownMenuItem(value: state, child: Text(state));
                  }).toList(),
              onChanged: widget.onStateChanged,
              hint: Text(
                "Choose a state",
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration() {
    final theme = Theme.of(context);
    final decorationTheme = theme.inputDecorationTheme;

    return InputDecoration(
      filled: decorationTheme.filled,
      fillColor: decorationTheme.fillColor,
      contentPadding: decorationTheme.contentPadding,
      hintStyle: TextStyle(
        color: theme.hintColor,
        fontFamily: 'Poppins',
        fontSize: Dimensions.font14,
      ),
      border: decorationTheme.border,
      enabledBorder: decorationTheme.enabledBorder,
      focusedBorder: decorationTheme.focusedBorder,
      errorBorder: decorationTheme.errorBorder,
      focusedErrorBorder: decorationTheme.focusedErrorBorder,
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

        return DropdownButtonFormField<String>(
          initialValue: selectedCountryValue,
          decoration: _inputDecoration(context),
          style: TextStyle(
            color: AppColors.black1,
            fontFamily: 'Poppins',
            fontSize: Dimensions.font15,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          iconEnabledColor: AppColors.primary4,
          items:
              countries.map((country) {
                return DropdownMenuItem(value: country, child: Text(country));
              }).toList(),
          onChanged: widget.onCountryChanged,
          hint: Text(
            "Choose a country",
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final decorationTheme = theme.inputDecorationTheme;

    return InputDecoration(
      filled: decorationTheme.filled,
      fillColor: decorationTheme.fillColor,
      contentPadding: decorationTheme.contentPadding,
      hintStyle: TextStyle(
        color: theme.hintColor,
        fontFamily: 'Poppins',
        fontSize: Dimensions.font14,
      ),
      border: decorationTheme.border,
      enabledBorder: decorationTheme.enabledBorder,
      focusedBorder: decorationTheme.focusedBorder,
      errorBorder: decorationTheme.errorBorder,
      focusedErrorBorder: decorationTheme.focusedErrorBorder,
    );
  }
}

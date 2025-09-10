import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

import '../models/country_state.dart';


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
  late Future<List<CountryData>> _countriesFuture;

  @override
  void initState() {
    super.initState();
    _countriesFuture = loadCountries();
  }

  Future<List<CountryData>> loadCountries() async {
    final jsonStr = await rootBundle.loadString('assets/countries_states.json');
    final List<dynamic> data = json.decode(jsonStr);
    return data.map((e) => CountryData.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<CountryData>>(
      future: _countriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No countries available");
        }

        final countries = snapshot.data!;
        final countryNames = countries.map((c) => c.name).toList();


        final selectedCountryObj = countries.firstWhere(
              (c) => c.name == widget.selectedCountry,
          orElse: () => countries.first,
        );

        final stateNames = selectedCountryObj.states.map((s) => s.name).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COUNTRY
            Text("Select Country", style: Theme.of(context).textTheme.titleMedium),
             SizedBox(height:Dimensions.height10 ),
            DropdownButtonFormField<String>(
              value: widget.selectedCountry,
              decoration: _inputDecoration(isDark),
              items: countryNames.map((country) {
                return DropdownMenuItem(value: country, child: Text(country));
              }).toList(),
              onChanged: (value) {
                widget.onCountryChanged(value);
                widget.onStateChanged(null); // reset state when country changes
              },
              hint: Text("Choose a country", style: TextStyle(color: Theme.of(context).hintColor)),
            ),

             SizedBox(height: Dimensions.height20),

            // STATE
            Text("Select State", style: Theme.of(context).textTheme.titleMedium),
             SizedBox(height: Dimensions.height10),
            DropdownButtonFormField<String>(
              value: widget.selectedState,
              decoration: _inputDecoration(isDark),
              items: stateNames.map((state) {
                return DropdownMenuItem(value: state, child: Text(state));
              }).toList(),
              onChanged: widget.onStateChanged,
              hint: Text("Choose a state", style: TextStyle(color: Theme.of(context).hintColor)),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(bool isDark) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: isDark ? Colors.white12 : const Color(0xFFDBD0C8).withOpacity(0.1),
      contentPadding:  EdgeInsets.symmetric(horizontal: Dimensions.width15, vertical: Dimensions.height10),
    );
  }
}
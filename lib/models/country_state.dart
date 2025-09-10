class StateInfo {
  final String code;
  final String name;
  StateInfo({required this.code, required this.name});
  factory StateInfo.fromJson(Map<String, dynamic> json) {
    return StateInfo(code: json['code'], name: json['name']);
  }
}

class CountryData {
  final String code2, code3, name, capital, region, subregion;
  final List<StateInfo> states;
  CountryData({
    required this.code2,
    required this.code3,
    required this.name,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.states,
  });
  factory CountryData.fromJson(Map<String, dynamic> json) {
    var statesJson = json['states'] as List<dynamic>? ?? [];
    return CountryData(
      code2: json['code2'] ?? '',
      code3: json['code3'] ?? '',
      name: json['name'] ?? '',
      capital: json['capital'] ?? '',
      region: json['region'] ?? '',
      subregion: json['subregion'] ?? '',
      states: statesJson.map((e) => StateInfo.fromJson(e)).toList(),
    );
  }
}
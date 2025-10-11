class ContactNumbers {

  ContactNumbers({
    required this.appSupport,
    required this.salesNumbers,
  });

  factory ContactNumbers.fromJson(final Map<String, dynamic> json) {
    return ContactNumbers(
      appSupport: (json['appSupport'] as List)
          .map((final item) => AppSupport.fromJson(item))
          .toList(),
      salesNumbers: (json['salesNumbers'] as List)
          .map((final item) => SalesNumber.fromJson(item))
          .toList(),
    );
  }
  final List<AppSupport> appSupport;
  final List<SalesNumber> salesNumbers;
}

class AppSupport {

  AppSupport({
    required this.name,
    required this.number,
    required this.numberMobile,
    required this.color,
  });

  factory AppSupport.fromJson(final Map<String, dynamic> json) {
    return AppSupport(
      name: json['name'] as String,
      number: json['number'] as String,
      numberMobile: json['numberMobile'] as String,
      color: json['color'] as String,
    );
  }
  final String name;
  final String number;
  final String numberMobile;
  final String color;
}

class SalesNumber {

  SalesNumber({
    required this.name,
    required this.number,
    required this.color,
  });

  factory SalesNumber.fromJson(final Map<String, dynamic> json) {
    return SalesNumber(
      name: json['name'] as String,
      number: json['number'] as String,
      color: json['color'] as String,
    );
  }
  final String name;
  final String number;
  final String color;
}

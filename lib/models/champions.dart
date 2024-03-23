class Champion {
  String rawName;
  String parsedName;

  Champion(this.rawName, this.parsedName);

  Map<String, dynamic> toJson() {
    return {
      'parsedName': parsedName,
      'rawName': rawName,
    };
  }

  factory Champion.fromJson(Map<String, dynamic> json) {
    return Champion(
      json['rawName'],
      json['parsedName'],
    );
  }
}
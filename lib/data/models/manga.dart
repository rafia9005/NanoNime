class Manga {
  final String title;
  final String type;
  final String thumb;
  final String endpoint;
  final String uploadOn;
  final String sortDesc;

  Manga({
    required this.title,
    required this.type,
    required this.thumb,
    required this.endpoint,
    required this.uploadOn,
    required this.sortDesc,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      thumb: json['thumb'] ?? '',
      endpoint: json['endpoint'] ?? '',
      uploadOn: json['upload_on'] ?? '',
      sortDesc: json['sortDesc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'thumb': thumb,
      'endpoint': endpoint,
      'upload_on': uploadOn,
      'sortDesc': sortDesc,
    };
  }
}

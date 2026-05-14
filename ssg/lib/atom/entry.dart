class Entry {
  String title;
  String link;
  String id;
  String published;
  String updated;
  String content;
  String? summary;
  String sourcePath;
  String? xmlLang;
  String? xmlBase;

  Entry({
    required this.title,
    required this.link,
    required this.id,
    required this.published,
    required this.updated,
    required this.content,
    required this.sourcePath,
    this.summary,
    this.xmlLang,
    this.xmlBase,
  });
}

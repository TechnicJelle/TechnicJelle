class Entry {
  final String title;
  final String link;
  final String id;
  final String published;
  final String updated;
  final String content;
  final String sourcePath;
  final String? xmlLang;
  final String? xmlBase;

  Entry({
    required this.title,
    required this.link,
    required this.id,
    required this.published,
    required this.updated,
    required this.content,
    required this.sourcePath,
    this.xmlLang,
    this.xmlBase,
  });
}

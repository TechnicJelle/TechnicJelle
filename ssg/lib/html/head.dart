import "package:bindings_html/html/base.dart";

class Head extends Element {
  String title;

  List<Meta> metas;
  List<Link> links;
  List<Style> styles;

  Head({
    required this.title,
    required this.metas,
    required this.links,
    required this.styles,
  });

  @override
  String build() {
    final List<List<Element>> categories = [metas, links, styles];
    final String concatenated = categories
        .map(
          (List<Element> els) => els.map((Element el) => el.build()).join("\n"),
        )
        .join("\n\n");
    return "<head>\n"
        '<meta charset="UTF-8">\n'
        "<title>$title</title>\n\n"
        "$concatenated\n"
        "</head>";
  }
}

class Meta extends Element {
  String key;
  String value;

  String? content;

  Meta.name({required String name, required String this.content}) : key = "name", value = name;

  Meta.httpEquiv({required String httpEquiv, required String this.content})
    : key = "http-equiv",
      value = httpEquiv;

  @override
  String build() {
    if (content != null) {
      return '<meta $key="$value" content="$content">';
    }
    return '<meta $key="$value">';
  }
}

class Link extends Element {
  String rel;
  String type;
  String sizes;
  String href;

  Link({
    required this.rel,
    required this.type,
    required this.sizes,
    required this.href,
  });

  @override
  String build() {
    return '<link rel="$rel" type="$type" sizes="$sizes" href="$href">';
  }
}

class Style extends Element {
  String css;

  Style({required this.css});

  @override
  String build() {
    return "<style>\n"
        "${css.trim()}\n"
        "</style>";
  }
}

import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class Head extends Element {
  String title;

  Iterable<Meta>? metas;
  Iterable<Link>? links;
  Iterable<Style>? styles;

  Head({
    required this.title,
    this.metas,
    this.links,
    this.styles,
  }) : super(children: []);

  @override
  String build() {
    final Iterable<Iterable<Element>> categories = [metas ?? [], links ?? [], styles ?? []];
    final String concatenated = categories
        .map((Iterable<Element> els) => els.map((Element el) => el.build()).join("\n"))
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

  Meta.name({
    required String name,
    required this.content,
  }) : key = "name",
       value = name,
       super(children: []);

  Meta.httpEquiv({
    required String httpEquiv,
    required this.content,
  }) : key = "http-equiv",
       value = httpEquiv,
       super(children: []);

  @override
  String build() {
    if (content != null) {
      return '<meta $key="$value" content="$content">';
    }
    return '<meta $key="$value">';
  }
}

enum PreloadType {
  fetch,
  font,
  image,
  script,
  style,
  track,
}

class Link extends Element {
  String rel;
  String href;
  Map<String, String?>? args;

  Link.icon({
    required String? type,
    required String? sizes,
    required this.href,
  }) : rel = "icon",
       args = {
         "type": type,
         "sizes": sizes,
       },
       super(children: []);

  Link.stylesheet({
    required this.href,
  }) : rel = "stylesheet",
       super(children: []);

  Link.preload({
    required this.href,
    required PreloadType as,
  }) : rel = "preload",
       args = {
         "as": as.name,
       },
       super(children: []);

  static Iterable<Link> preloadedStylesheet({required String href}) {
    return [
      Link.preload(href: href, as: PreloadType.style),
      Link.stylesheet(href: href),
    ];
  }

  @override
  String build() {
    return '<link rel="$rel" href="$href"${args.args()}>';
  }
}

class Style extends Element {
  String css;

  Style({
    required this.css,
  }) : super(children: []);

  @override
  String build() {
    return "<style>\n"
        "${css.trim()}\n"
        "</style>";
  }
}

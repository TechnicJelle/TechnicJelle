import "package:techs_html_bindings/elements.dart";

Section generateWebrings() {
  return Section(
    classes: ["webrings"],
    children: [
      H2(children: [T("Webrings")]),
      ...generateWebring(
        name: "Graphics Programming",
        linkPrev: "https://graphics-programming.org/webring/frogs/technicjelle/prev",
        linkRoot: "https://graphics-programming.org/webring/",
        linkNext: "https://graphics-programming.org/webring/frogs/technicjelle/next",
        imageUrl: "https://graphics-programming.org/img/froge.webp",
        imageAlt: "a friendly froge",
      ),
    ],
  );
}

List<Element> generateWebring({
  required String name,
  required String linkPrev,
  required String linkRoot,
  required String linkNext,
  required String imageUrl,
  required String imageAlt,
}) {
  return [
    H3(children: [T(name)]),
    Div(
      classes: ["webring"],
      children: [
        A(href: linkPrev, children: [T("⬅️")]),
        A(
          href: linkRoot,
          children: [Image(src: imageUrl, alt: imageAlt)],
        ),
        A(href: linkNext, children: [T("➡️")]),
      ],
    ),
  ];
}

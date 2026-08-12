import "package:techs_html_bindings/elements.dart";

Section generateWebrings() {
  return Section(
    classes: ["webrings"],
    children: [
      H2.text("Webrings"),
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
    H3.text(name),
    Div(
      classes: ["webring"],
      children: [
        A.text("⬅️", href: linkPrev),
        A(
          href: linkRoot,
          children: [Image(src: imageUrl, alt: imageAlt)],
        ),
        A.text("➡️", href: linkNext),
      ],
    ),
  ];
}

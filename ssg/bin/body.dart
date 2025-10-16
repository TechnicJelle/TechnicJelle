import "dart:io";

import "package:ssg/html.dart";
import "package:ssg/markdown.dart";

import "projects.dart";

Header generateHeader() => Header(
  classes: ["mono-font"],
  children: [
    A(href: "https://github.com/TechnicJelle?tab=repositories&type=source", children: [T("TechnicJelle")]),
    Span(classes: ["small"], children: [T("/")]),
    A(
      href: "https://github.com/TechnicJelle/TechnicJelle",
      children: [
        Span(classes: ["stealth-link"], children: [T("README")]),
        Span(classes: ["small"], children: [T(".md")]),
      ],
    ),
  ],
);

Body generateBody() => Body(
  header: generateHeader(),
  main: Main(
    children: [
      ...markdown(File("README.md")),
      ...generateProjects(),
    ],
  ),
  footer: generateFooter(),
);

Footer generateFooter() {
  return Footer(
    children: [
      Section(
        id: "webrings-container",
        children: [
          H2(children: [T("Webrings")]),
          H4(children: [T("Graphics Programming")]),
          Div(
            inlineStyles: [
              "display: flex",
              "gap: 0.25rem",
              "justify-content: center",
              "align-items: center",
            ],
            children: [
              A(
                href: "https://graphics-programming.org/webring/frogs/technicjelle/prev",
                children: [T("⬅️")],
              ),
              A(
                href: "https://graphics-programming.org/webring/",
                inlineStyles: ["height: 1.5em"],
                children: [
                  Image(
                    src: "https://graphics-programming.org/img/froge.webp",
                    alt: "a friendly froge",
                    inlineStyles: ["object-fit: contain", "height: 1.5em"],
                  ),
                ],
              ),
              A(
                href: "https://graphics-programming.org/webring/frogs/technicjelle/next",
                children: [T("➡️")],
              ),
            ],
          ),
        ],
      ),
      P(
        children: [
          T("Last updated on"),
          Time(
            datetime: DateTime.now().toIso8601String(),
            visible: DateTime.now().copyWith(microsecond: 0).toIso8601String().replaceAll("T", " "),
          ),
        ],
      ),
      Address(
        children: [
          P(
            inlineStyles: ["margin-bottom: 0"],
            children: [
              T("Website made by"),
              A(href: "mailto:technicjelleplay@gmail.com", children: [T("TechnicJelle")]),
            ],
          ),
        ],
      ),
      P(
        inlineStyles: ["margin-top: 0"],
        children: [T("©Copyright ${DateTime.now().year} by TechnicJelle. All rights reserved.")],
      ),
    ],
  );
}

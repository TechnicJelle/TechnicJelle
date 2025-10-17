import "dart:io";

import "package:ssg/html.dart";
import "package:ssg/markdown.dart";

import "projects.dart";
import "table_of_contents.dart";
import "webrings.dart";

Header generateHeader() => Header(
  children: [
    Div(
      classes: ["mono-font"],
      inlineStyles: ["display: flex", "align-items: center"],
      children: [
        A(href: "https://github.com/TechnicJelle?tab=repositories&type=source", children: [T("TechnicJelle")]),
        Span(classes: ["small"], children: [T("/")]),
        A(
          inlineStyles: ["display: flex", "align-items: end"],
          href: "https://github.com/TechnicJelle/TechnicJelle",
          children: [
            Span(classes: ["stealth-link"], children: [T("README")]),
            Span(classes: ["small"], children: [T(".md")]),
          ],
        ),
      ],
    ),
  ],
);

Body generateBody() {
  final List<Element> mainContent = [
    ...markdown(File("README.md")),
    ...generateProjects(),
    generateWebrings(),
  ];

  //generate ToC from the mainContent and insert it into the mainContent once it's done
  mainContent.insert(
    mainContent.indexOf(mainContent.firstWhere((element) => element.id == "projects")),
    generateToC(fromContent: mainContent),
  );

  return Body(
    header: generateHeader(),
    main: Main(children: mainContent),
    footer: generateFooter(),
  );
}

Footer generateFooter() {
  return Footer(
    children: [
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

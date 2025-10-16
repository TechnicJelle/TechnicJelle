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
  footer: Footer(children: []),
);

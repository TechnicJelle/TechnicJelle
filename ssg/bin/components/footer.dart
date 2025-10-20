import "package:ssg/html.dart";

Footer generateFooter() {
  return Footer(
    children: [
      P(
        children: [
          T("Website last updated on"),
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

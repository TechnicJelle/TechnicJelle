import "package:techs_html_bindings/elements.dart";

Footer generateFooter({bool shouldDisplayLastUpdatedTime = false}) {
  return Footer(
    children: [
      if (shouldDisplayLastUpdatedTime)
        P(
          children: [
            T("Website last updated on "),
            Time.now(),
          ],
        ),
      Address(
        children: [
          P(
            inlineStyles: ["margin-bottom: 0"],
            children: [
              T("Website made by "),
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

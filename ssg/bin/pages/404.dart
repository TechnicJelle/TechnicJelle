import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/constants.dart";
import "package:techs_html_bindings/elements.dart";

Future<void> create404() async {
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(
      extraInlineStyles: [
        """
h1 {
	font-size: clamp(8em, min(20vw, 50vh), 20em);
	margin-bottom: 1rem;
}

h1, h2, p {
	text-align: center;
	border: none;
}
""",
      ],
    ),
    body: Body(
      header: generateHeader(filename: "404"),
      main: Main(
        children: [
          H1.text("404"),
          P.text("This page could not be found!"),
          H2.text("Please double-check your URL.", autoLink: false),
          P(
            children: [
              T("Or go back to the "),
              A.text("Home Page", href: "/"),
              T(", or check out the "),
              A.text("Blog", href: "/blog"),
              T("!"),
            ],
          ),
        ],
      ),
      footer: generateFooter(),
    ),
  ).build();
  File(p.join(dirBuild.path, "404.html")).writeAsStringSync(indexHTML);
}

import "dart:io";

import "package:techs_html_bindings/elements.dart";

Element getLogo(String logo) {
  final File icon = File("images/icons/$logo.svg");
  return T(
    icon
        .readAsStringSync()
        .replaceAll(
          ' xmlns="http://www.w3.org/2000/svg">',
          ' xmlns="http://www.w3.org/2000/svg" width="24" height="24">',
        )
        .replaceAll('"/></svg>', '" fill="currentColor"/></svg>'),
  );
}

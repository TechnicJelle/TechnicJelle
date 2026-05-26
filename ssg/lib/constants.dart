import "dart:io";

import "package:github/github.dart";
import "package:path/path.dart" as p;

///does not include trailing slash to makes string interpolation look prettier
const String baseUrl = "https://technicjelle.com";

final Directory dirBuild = Directory("build");

final github = GitHub(auth: findAuthenticationFromEnvironment());

HttpClient http = HttpClient()..userAgent = "TechnicJelle's SSG";

extension UriExtension on Uri {
  String getFileName() => p.basename(pathSegments.join("/"));

  String getExtension() => p.extension(pathSegments.join("/"));
}

extension FilterFSE on Iterable<FileSystemEntity> {
  List<Directory> dirs() => whereType<Directory>().toList();

  List<File> files() => whereType<File>().toList();
}

extension SortFiles on List<FileSystemEntity> {
  void sortFSE() => sort((a, b) => a.path.compareTo(b.path));
}

extension NumString on int {
  String toStringDigits([int digits = 2]) => toString().padLeft(digits, "0");

  String toStringLargeNumber() {
    final str = toString();
    final StringBuffer sb = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        sb.write(" ");
      }
      sb.write(str[i]);
    }

    return sb.toString();
  }
}

extension TimeFormat on DateTime {
  String toAtomString() => copyWith(microsecond: 0).toUtc().toIso8601String();
}

const List<String> monthNames = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

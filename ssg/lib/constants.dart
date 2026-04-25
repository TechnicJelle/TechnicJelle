import "dart:io";

import "package:github/github.dart";
import "package:path/path.dart" as p;

///does not include trailing slash to makes string interpolation look prettier
const String baseUrl = "https://technicjelle.com";

final Directory dirBuild = Directory("build")..createSync();

final github = GitHub(auth: findAuthenticationFromEnvironment());

HttpClient http = HttpClient()..userAgent = "TechnicJelle's SSG";

extension UriExtension on Uri {
  String getFileName() => p.basename(pathSegments.join("/"));

  String getExtension() => p.extension(pathSegments.join("/"));
}

extension SortFiles on List<FileSystemEntity> {
  void sortFSE() => sort((a, b) => a.path.compareTo(b.path));
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

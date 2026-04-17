import "dart:io";

import "package:github/github.dart";
import "package:path/path.dart" as p;

final Directory dirBuild = Directory("build")..createSync();

final github = GitHub(auth: findAuthenticationFromEnvironment());

HttpClient http = HttpClient()..userAgent = "TechnicJelle's SSG";

extension UriExtension on Uri {
  String getFileName() => p.basename(path);

  String getExtension() => p.extension(path);
}

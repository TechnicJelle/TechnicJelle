import "dart:io";

import "package:github/github.dart";

final Directory dirBuild = Directory("build")..createSync();

final github = GitHub(auth: findAuthenticationFromEnvironment());

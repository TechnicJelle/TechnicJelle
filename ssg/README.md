# Custom Static Site Generator for TechnicJelle's Website

Written in Dart.

- `lib` contains HTML bindings and other utilities
  - Hopefully I can split this off into a proper Pub.dev package at some point, so I can reuse it for other websites, too.
- `bin` contains the actual SSG-specific code

## Running

Run from the root of the repository, not in here.

```bash
dart run ssg/bin/main.dart
```

The output will be in the `build` folder, also in the root.

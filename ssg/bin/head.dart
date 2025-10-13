import "dart:io";

import "package:ssg/html.dart";

Head generateHead() => Head(
  title: "TechnicJelle",
  metas: [
    Meta.name(name: "viewport", content: "width=device-width, initial-scale=1"),
    Meta.name(name: "og:title", content: "TechnicJelle"),
    Meta.name(name: "description", content: "On this website you'll find info about me and my projects"),
    Meta.name(name: "og:description", content: "On this website you'll find info about me and my projects"),
    Meta.name(name: "theme-color", content: "#001FF1"),
    Meta.name(name: "og:image", content: "https://technicjelle.com/images/logo-128.gif"),
    Meta.httpEquiv(httpEquiv: "X-Clacks-Overhead", content: "GNU Terry Pratchett"),
  ],
  links: [
    Link(
      rel: "icon",
      type: "image/png",
      sizes: "32x32",
      href: "/favicon-32x32.png",
    ),
    Link(
      rel: "icon",
      type: "image/png",
      sizes: "16x16",
      href: "/favicon-16x16.png",
    ),
  ],
  styles: [
    Style(css: File("ssg/styles/main.css").readAsStringSync()),
  ],
);

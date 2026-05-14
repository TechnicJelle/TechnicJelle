import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:techs_html_bindings/elements.dart";

class TagStore<R> {
  final Map<String, List<R>> _tagsAndTheirUsages = {};

  Iterable<String> get allTags => _tagsAndTheirUsages.keys;

  TagStore();

  void setUsagesForTag({required String tag, required List<R> usages}) {
    _tagsAndTheirUsages[tag] = usages;
  }

  void registerUsageForTag({required String tag, required R usage}) {
    if (_tagsAndTheirUsages.containsKey(tag)) {
      _tagsAndTheirUsages[tag]!.add(usage);
    } else {
      _tagsAndTheirUsages[tag] = [usage];
    }
  }

  int getUsageAmount({required String tag}) {
    return _tagsAndTheirUsages[tag]!.length;
  }

  Iterable<MapEntry<String, List<R>>> get entries => _tagsAndTheirUsages.entries;

  Element generateTagsList({
    required String hrefPrefix,
    Iterable<String>? tags,
    bool withUsageAmount = false,
  }) {
    final Iterable<String> tagsToList;
    if (tags == null) {
      tagsToList = allTags.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    } else {
      tagsToList = tags;
    }
    return UnorderedList(
      classes: ["tags"],
      items: tagsToList.map(
        (String tag) => ListItem(
          classes: [cleanTag(tag)],
          children: [
            A(
              href: "$hrefPrefix/${cleanTag(tag)}",
              children: [
                T(tag),
                if (withUsageAmount) T("(${getUsageAmount(tag: tag)})"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void writeTagsPage({
    required String title,
    required String h1Text,
    required Directory dir,
    required String hrefPrefix,
    List<A> breadcrumbs = const [],
    List<String> extraStyles = const [],
  }) {
    final String tagsPage = HTML(
      lang: "en",
      head: generateHead(title: title, extraStyles: [...extraStyles, "tags"]),
      body: Body(
        header: generateHeader(breadcrumbs: breadcrumbs, filename: "Tags"),
        main: Main(
          children: [
            H1.text(h1Text),
            generateTagsList(hrefPrefix: hrefPrefix, withUsageAmount: true),
          ],
        ),
        footer: generateFooter(),
      ),
    ).build();
    dir.createSync(recursive: true);
    File(p.join(dir.path, "index.html")).writeAsStringSync(tagsPage);
  }
}

String cleanTag(String tag) {
  return tag.replaceAll(" ", "-").replaceAll("#", "s").replaceAll("+", "p").replaceAll("/", "_");
}

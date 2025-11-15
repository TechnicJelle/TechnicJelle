import "package:ssg/projects_loading.dart";
import "package:techs_html_bindings/elements.dart";

String cleanTag(String tag) {
  return tag.replaceAll(" ", "-").replaceAll("#", "s").replaceAll("+", "p").replaceAll("/", "_");
}

Element generateTagsList({Iterable<String>? tags, bool withUsageAmount = false}) {
  final Iterable<String> allTags;
  if (tags == null) {
    allTags = tagsAndTheirUsages.keys.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  } else {
    allTags = tags;
  }
  return UnorderedList(
    classes: ["tags"],
    items: allTags.map(
      (String tag) => ListItem(
        classes: [cleanTag(tag)],
        children: [
          A(
            href: "/tags/${cleanTag(tag)}",
            children: [
              T(tag),
              if (withUsageAmount) T("(${tagsAndTheirUsages[tag]!.length})"),
            ],
          ),
        ],
      ),
    ),
  );
}

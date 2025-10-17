import "package:ssg/html.dart";
import "package:ssg/utils.dart";

import "stack.dart";

List<ListItem> tocHeadingsToListItems(List<Hn> tocHeadings) {
  final List<ListItem> finalListItems = [];

  final Stack<List<Element>> levels = Stack()..push(finalListItems);
  int lastLevel = 2;

  for (final heading in tocHeadings) {
    if (heading.level > lastLevel) {
      //the level increased, so we make a new <ol>
      final OrderedList ol = OrderedList(items: []);
      //and add it to the current "parent"
      levels.peek.last.children = [...levels.peek.last.children, ol];
      //and now this becomes the new "parent"
      levels.push(ol.items as List<Element>);
    } else if (heading.level < lastLevel) {
      //so this level is done, so descend a level again
      levels.pop();
    }

    //we record the current level for next loop around
    lastLevel = heading.level;
    //we now add a link to the current heading to the current level
    levels.peek.add(
      ListItem(
        children: [
          A(href: "#${heading.id}", children: [T(heading.innerText)]),
        ],
      ),
    );
  }

  return finalListItems;
}

Aside generateToC({required List<Element> fromContent}) {
  final List<Hn> allHeadings = [];
  fromContent.collectOfType(into: allHeadings);
  final List<Hn> tocHeadings = [];
  for (final heading in allHeadings) {
    if (heading.level > 1 && heading.level <= 3) {
      tocHeadings.add(heading);
    }

    // Stop recording after the webrings
    // (kind of a hack, but whatever)
    // (ideally it would filter out everything specifically in the Hn of the webrings, and be able to continue again after)
    if (heading.id == "webrings") break;
  }

  return Aside(
    children: [
      Nav(
        children: [
          H2(id: "toc", children: [T("Table of Contents")]),
          OrderedList(items: tocHeadingsToListItems(tocHeadings)),
        ],
      ),
    ],
  );
}

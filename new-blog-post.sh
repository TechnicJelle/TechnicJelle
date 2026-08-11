#!/usr/bin/env bash

if [ "$1" ]; then
	NEW_POST_NAME="$1"
else
	NEW_POST_NAME=$(yad --title="New post name?" --text="Please give the name for the new post:" --entry)
fi

[ -z "$NEW_POST_NAME" ] && exit 1

dart run ssg/bin/main.dart new-blog-post "$NEW_POST_NAME"

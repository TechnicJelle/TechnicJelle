#!/usr/bin/env bash

if [ "$1" ]; then
	NEW_FILE_NAME="$1"
else
	NEW_FILE_NAME=$(yad --entry)
fi

dart run ssg/bin/main.dart new-blog-post "$NEW_FILE_NAME"

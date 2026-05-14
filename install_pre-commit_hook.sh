#!/usr/bin/env bash

# Make sure that the clean_exif script runs as pre-commit hook,
# so I don't have to remember to run the script manually when I add new media to the blog.

ln -s "blog/clean_exif.dart" ".git/hooks/pre-commit"

#!/bin/sh
DART_FLAGS="--checked" dartium --disable-web-security --alow-file-access-from-files--user-data-dir=~/.dartium ./web/src/index.html


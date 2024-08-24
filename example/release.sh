#!/bin/sh

# This script is used to upload WASM to justprodev.com GH Pages

# Build the project
flutter build  web --wasm --base-href /demo/cached_image/

# copy the build to the gh-pages branch
cp -r build/web/* ../../justprodev.github.io/demo/cached_image/
cd ../../justprodev.github.io/demo/cached_image/
git pull
git add .
git commit -m "update cached_image demo"
git push origin master


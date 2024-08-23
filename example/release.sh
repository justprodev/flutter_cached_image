#!/bin/sh

# This script is used to upload WASM to justprodev.com GH Pages

# Build the project
flutter build  web --wasm

# rewrite base href to <base href="/demo/cached_image/"> in index.html
sed -i -e 's/<base href="\/">/<base href="\/demo\/cached_image\/">/g' build/web/index.html

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX sed
    sed -i '' -e 's/<base href="\/">/<base href="\/demo\/cached_image\/">/g' build/web/index.html
else
    # GNU sed
    sed -i'' -e 's/<base href="\/">/<base href="\/demo\/cached_image\/">/g' build/web/index.html
fi

# copy the build to the gh-pages branch
cp -r build/web/* ../../justprodev.github.io/demo/cached_image/
cd ../../justprodev.github.io/demo/cached_image/
git add .
git commit -m "update cached_image demo"
git push origin master



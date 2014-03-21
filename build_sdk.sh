#!/bin/sh
VERSION="0.1"
BUILDER_USER=dart
SDK_PATH_CURRENT=/home/$BUILDER_USER/bin/dart-sdk
SDK_PATH_OLD=/home/$BUILDER_USER/bin/dart-sdk-old
GCLIENT_PATH=/home/$BUILDER_USER/src/depot_tools
SOURCE_PATH=/home/$BUILDER_USER/src
OUTPUT_SDK_PATH=$SOURCE_PATH/dart/out/ReleaseX64/dart-sdk
DART_VERSION="1.2"
DART_DEPS_URL="http://dart.googlecode.com/svn/branches/$DART_VERSION/deps/all.deps"

fatalError()
{
 echo "Fatal error"
 exit 1
}

echo "Script v$VERSION"
echo "Please see: https://code.google.com/p/dart/wiki/Building"
echo " https://code.google.com/p/dart/wiki/BuildingOnDebian"
echo " required: subversion make g++ openjdk-6-jdk"

echo "Build Dart '$DART_VERSION' SDK"
echo "Work directory: $SOURCE_PATH"
cd $SOURCE_PATH || fatalError
if [ -d "$SDK_PATH_CURRENT" ]; then
  if [ -d "$SDK_PATH_OLD" ]; then
   echo "Remove backup old SDK $SDK_PATH_OLD"
   rm -R "$SDK_PATH_OLD" || fatalError
  fi 
fi
echo "Update Dart '$DART_VERSION' source code"
echo "gclient config $DART_DEPS_URL"
$GCLIENT_PATH/gclient config $DART_DEPS_URL || fatalError
echo "gclient sync"
$GCLIENT_PATH/gclient sync || fatalError
echo "gclient runhooks"
$GCLIENT_PATH/gclient runhooks || fatalError

echo "Build Dart '$DART_VERSION'"
cd $SOURCE_PATH/dart || fatalError
tools/build.py --mode=release --arch=x64 create_sdk
echo "Build success"
if [ -d "$SDK_PATH_CURRENT" ]; then
 if [ -d "$SDK_PATH_OLD" ]; then
  echo "Remove backup old SDK $SDK_PATH_OLD"
  rm -R "$SDK_PATH_OLD" || fatalError
 fi 
 echo "Backuping current SDK $SDK_PATH_CURRENT -> $SDK_PATH_OLD"
 mv "$SDK_PATH_CURRENT" "$SDK_PATH_OLD" || fatalError
fi
echo "Upgrade SDK $OUTPUT_SDK_PATH -> $SDK_PATH_CURRENT"
cp -R "$OUTPUT_SDK_PATH" "$SDK_PATH_CURRENT" || fatalError
echo "Build Dart '$DART_VERSION' ok"


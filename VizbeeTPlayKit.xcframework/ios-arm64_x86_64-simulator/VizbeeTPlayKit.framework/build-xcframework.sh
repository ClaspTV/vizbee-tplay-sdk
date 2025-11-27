#
#  build.sh
#  VizbeeKit
#
#  Created by Sidharth Datta on 30/01/24.
#  Copyright © 2024 Vizbee. All rights reserved.
#

#!/bin/bash

# Define the paths and filenames
WORKSPACE_PATH="../VizbeeKit.xcworkspace"
TARGET_NAME="VizbeeTPlayKit"
INFO_PLIST_PATH="./Info.plist"
OUTPUT_PATH="../dist/VizbeeTPlayKit"
ARCHIVE_PATH="../archives/VizbeeTPlayKit"
SPM_REPO_PATH="../../../vizbee-tplay-sdk"

# Function to update plist files
update_plist_files() {
    # Update semantic version string
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $SEMANTIC_VERSION" $INFO_PLIST_PATH
    /usr/libexec/PlistBuddy -c "Set :VZBBundleShortVersionString $SEMANTIC_VERSION" $INFO_PLIST_PATH
    # Update bundle version string
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUNDLE_VERSION" $INFO_PLIST_PATH
    /usr/libexec/PlistBuddy -c "Set :VZBBundleVersion $BUNDLE_VERSION" $INFO_PLIST_PATH
    # Stage Info.plist for VCS convenience
    git add $INFO_PLIST_PATH
}

# Function to clean old archives file
clear_archives(){
    echo "Clearing previous archives if any..."
    rm -rf "$ARCHIVE_PATH"
}

# Function to build the framework
build_framework() {
    
    # build for iPhone OS
    xcodebuild clean archive \
    -workspace "$WORKSPACE_PATH" \
    -scheme "$TARGET_NAME" \
    -sdk iphoneos \
    -configuration "$CONFIG_TYPE" \
    -archivePath "$ARCHIVE_PATH/$TARGET_NAME.xcarchive" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO
    
    # build for iOS Simulator
    xcodebuild clean archive \
    -workspace "$WORKSPACE_PATH" \
    -scheme "$TARGET_NAME" \
    -sdk iphonesimulator \
    -configuration "$CONFIG_TYPE" \
    -archivePath "$ARCHIVE_PATH/$TARGET_NAME-simulator.xcarchive" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO
}

# Function to create XCFramework
create_xcframework() {
    
    xcodebuild -create-xcframework \
    -framework "$ARCHIVE_PATH/$TARGET_NAME.xcarchive/Products/Library/Frameworks/$TARGET_NAME.framework" \
    -framework "$ARCHIVE_PATH/$TARGET_NAME-simulator.xcarchive/Products/Library/Frameworks/$TARGET_NAME.framework" \
    -output "$ARCHIVE_PATH/$TARGET_NAME.xcframework"
    
    mkdir -p $OUTPUT_PATH
    cp -r "$ARCHIVE_PATH/$TARGET_NAME.xcframework" "$OUTPUT_PATH"
}

# Function to update files (spm, cocoapod, carthage, etc.)
copy_to_spm() {
    # Copy to spm folder
    echo "Updating VizbeeHomeSSOKit SPM xcframework..."
    mkdir -p $OUTPUT_PATH/SPM
    cp -r "$OUTPUT_PATH/$TARGET_NAME.xcframework" "$OUTPUT_PATH/SPM"
}

# Function to update XCFramework to spm git
update_spm_git_repo(){
    echo "Updating spm repo... $SPM_REPO_PATH/$TARGET_NAME.xcframework"
    # Replace the existing XCFramework in the SPM Git repository
    rm -rf "$SPM_REPO_PATH/$TARGET_NAME.xcframework"
    cp -R "$OUTPUT_PATH/SPM/$TARGET_NAME.xcframework" "$SPM_REPO_PATH"
    
    # Commit and push changes to the Git repository
    cd "$SPM_REPO_PATH" || exit
    
    if [ $CONFIG_TYPE="Release" ]
    then
    BRANCH_NAME = master
    else
    BRANCH_NAME = debug
    fi
    
    git add "./*"
    git checkout $BRANCH_NAME
    git commit -m "$CONFIG_TYPE/$SEMANTIC_VERSION"
    git tag "$SEMANTIC_VERSION"
    
    git push origin $BRANCH_NAME --tags
}


main() {
    if [ $# -ne 3 ]; then
    echo "usage: $0 <version_string> <bundle> <configuration>"
    echo ""
    echo "e.g. $0 1.0 234B Release"
    exit
    fi
    
    export SEMANTIC_VERSION="$1"
    export BUNDLE_VERSION="$2"
    export CONFIG_TYPE="$3"
    export VERSION_STRING="$SEMANTIC_VERSION-$BUNDLE_VERSION"
    
    clear_archives
    
    build_framework
    create_xcframework
    
    copy_to_spm
    #    update_spm_git_repo
}

main "$@"

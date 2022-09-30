#!/bin/bash

DESTINATION_FOLDER="$HOME/.java-dap-tool"

if [ ! -d $DESTINATION_FOLDER ]; then

    echo "Create folder $DESTINATION_FOLDER"
    mkdir $DESTINATION_FOLDER
fi


JAVA_DEBUG="java-debug"
JAVA_DEBUG_REPO="https://github.com/microsoft/$JAVA_DEBUG"
JAVA_DEBUG_TARGET_FILE="com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*"

VSCODE_JAVA_TEST="vscode-java-test"
VSCODE_JAVA_TEST_REPO="https://github.com/microsoft/$VSCODE_JAVA_TEST"
VSCODE_JAVA_TARGET_FILE="server/*"

clone_repo() {

    repo=$1
    folder="$DESTINATION_FOLDER/$2"

    if [ -d $folder ]; then
        echo "Delete folder $folder"
        rm -rf $folder
    fi

    git clone $repo $folder
}

file_exist() {

    path=$1
    if [[ $(ls $path 2>/dev/null | wc -l) != "0" ]]; then
        echo "true"
    else
        echo "false"
    fi 
}

check_result_after_build() {
    module=$1
    target_file=$2
    exist=$(file_exist $target_file)

    if [[ $exist == "true" ]]; then
        echo "$module is installed successfully"
    fi
}


build_java_debug() {
    clone_repo $JAVA_DEBUG_REPO $JAVA_DEBUG

    folder="$DESTINATION_FOLDER/$JAVA_DEBUG"
    cd $folder 
    ./mvnw clean install
}


build_vscode_java_test() {
    clone_repo $VSCODE_JAVA_TEST_REPO $VSCODE_JAVA_TEST

    folder="$DESTINATION_FOLDER/$VSCODE_JAVA_TEST"
    cd $folder
    npm install
    npm run build-plugin
}

run() {
    build_java_debug 
    build_vscode_java_test
   
    java_folder="$DESTINATION_FOLDER/$JAVA_DEBUG"
    java_debug_target_file=$java_folder/$JAVA_DEBUG_TARGET_FILE
    check_result_after_build $JAVA_DEBUG $java_debug_target_file
   
    vscode_java_test_folder="$DESTINATION_FOLDER/$JAVA_DEBUG"
    vscode_java_test_target_file=$vscode_java_test_folder/$VSCODE_JAVA_TARGET_FILE
    check_result_after_build $VSCODE_JAVA_TEST $vscode_java_test_target_file
}

run 

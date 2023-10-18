#!/bin/bash

# Exit on error
set -eo pipefail

# Check if arguments are given
TARGET_DIR=$HOME/bin
SOURCE_DIR=$PWD
SOURCE_FILES="${@}"

# Check if target dir exists
if [[ ! -d $TARGET_DIR ]]
then
    echo "Target dir ${TARGET_DIR} does not exist!"
    exit 1
fi

for file in $SOURCE_FILES
do
    # Check if file exists
    if [[ ! -e $file ]]
    then
        echo "File ${file} does not exist"
        exit 1
    fi

    # Check if file is executable
    if [[ ! -x $file ]]
    then
        echo "File ${file} is not executable"
        exit 1
    fi

    # Check if symlink already exists
    if [[ -e $TARGET_DIR/$file ]]
    then
        # Ask if overwrite
        read -p "File ${TARGET_DIR}/${file} already exists. Overwrite? [y/N] " overwrite
        
        case $overwrite in
            [Yy]*)
                continue ;;
            *)
                echo "Skipping ${file}"
                exit 1
                ;;
        esac
    fi

    # Create symlink
    ln -sfv $SOURCE_DIR/$file $TARGET_DIR/
done

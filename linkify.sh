#!/bin/bash
set -eo pipefail


TARGET_DIR=$HOME/bin
SOURCE_DIR=$PWD
SOURCE_FILES="${@}"

if [[ ! -d $TARGET_DIR ]]
then
    echo "Target dir ${TARGET_DIR} does not exist!"
    exit 1
fi

for file in $SOURCE_FILES
do
    if [[ ! -e $file ]]
    then
        echo "File ${file} does not exist"
        exit 1
    fi

    if [[ ! -x $file ]]
    then
        echo "File ${file} is not executable"
        exit 1
    fi

    if [[ -e $TARGET_DIR/$file ]]
    then
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

    ln -sfv $SOURCE_DIR/$file $TARGET_DIR/
done

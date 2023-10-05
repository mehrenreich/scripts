#!/bin/bash
#
# Script to bump the version of a project.
#
# Most parts of the script are written by GitHub Copilot.
#


CURRENT_BRANCH=`git branch --show-current`
PROTECTED_BRANCH="main"

LATEST_HASH=`git log --pretty=format:'%h' -n 1`

TEMPFILE=`mktemp`

CURRENT_VERSION=""

function bump_version () {
    # get the current version and raise the minor version number by one
    # e.g. 0.0.1 -> 0.1.0
    local current_version=$1

    # split the version into an array
    current_version_array=(`echo $current_version | tr '.' ' '`)
    v_major=${current_version_array[0]}
    v_minor=${current_version_array[1]}
    v_patch=${current_version_array[2]}

    # raise the minor version number by one
    v_minor=$((v_minor + 1))
    v_patch=0

    # set the new version
    new_version="$v_major.$v_minor.$v_patch"

    # return the new version
    echo $new_version
}

#
# Check if the current branch is the protected branch.
#
if [[ $CURRENT_BRANCH != $PROTECTED_BRANCH ]]
then
    echo -e "\033[31mYou are not on the ${PROTECTED_BRANCH} branch.\033[0m"
    echo -e "\033[31mExiting...\033[0m"
    exit 0
fi

#
# Try to get the version from the VERSION file, otherwise set it to 0.0.1
#
if [[ -f VERSION ]]
then
    CURRENT_VERSION=`cat VERSION`
fi

SUGGESTED_NEW_VERSION=`bump_version ${CURRENT_VERSION:-"0.0.1"}`

#
# Get the new version from the user.
#
echo -e "Latest commit hash: \033[1m${LATEST_HASH}\033[0m"
echo -e "Current version: \033[1m${CURRENT_VERSION}\033[0m"
echo -en "Enter a version number [\033[1m${SUGGESTED_NEW_VERSION}\033[0m]: "
read RESPONSE
if [[ $RESPONSE == "" ]]
then
    NEW_VERSION=$SUGGESTED_NEW_VERSION
else
    NEW_VERSION=$RESPONSE
fi

#
# Check if the new version is the same as the current version.
#
if [[ $NEW_VERSION == $CURRENT_VERSION ]]
then
    echo -e "\033[31mNew version is the same as the current version.\033[0m"
    echo -e "\033[31mExiting...\033[0m"
    exit 0
fi

#
# Check if the version string is valid by using regex
#
if [[ ! $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
then
    echo -e "\033[31mInvalid version string.\033[0m"
    echo -e "\033[31mExiting...\033[0m"
    exit 0
fi

echo -e "\033[33mWill set new version to be ${NEW_VERSION}\033[0m"

#
# Set the git tag to "v<version>".
#
echo -e "\033[33mTagging version ${NEW_VERSION}...\033[0m"
GIT_TAG="v${NEW_VERSION}"

#
# Check if that tag already exists.
#
if [[ `git tag -l "${GIT_TAG}"` ]]
then
    echo -e "\033[31mTag ${GIT_TAG} already exists.\033[0m"
    echo -e "\033[31mExiting...\033[0m"
    exit 0
fi

#
# Update the VERSION file.
#
echo -e "\033[33mUpdating VERSION file...\033[0m"
echo "${NEW_VERSION}" > VERSION

#
# Update the CHANGELOG.md file.
#
if [[ -f CHANGELOG.md ]]
then
    echo -e "\033[33mUpdating CHANGELOG.md file...\033[0m"
else
    echo -e "\033[33mCreating CHANGELOG.md file...\033[0m"
    touch CHANGELOG.md
fi

echo "## ${NEW_VERSION} (`date +%Y-%m-%d`)" > $TEMPFILE

#
# Add the changes since the last version tag.
#
if [[ `git tag -l "v${CURRENT_VERSION}"` ]]
then
    echo -en "\nChanges:\n\n" >> $TEMPFILE
    git log --pretty=format:" - %s (%an)" "v${CURRENT_VERSION}...HEAD" >> $TEMPFILE
fi

echo "" >> $TEMPFILE
echo "" >> $TEMPFILE
cat CHANGELOG.md >> $TEMPFILE
mv $TEMPFILE CHANGELOG.md

#
# Ask user to update the CHANGELOG.md file.
# 
read -p "Please update the CHANGELOG.md file and press ENTER when finished."

#
# Add the VERSION and CHANGELOG.md files to git.
#
echo "Adding VERSION and CHANGELOG.md files to git..."
git add VERSION CHANGELOG.md

#
# Commit the changes.
#
echo "Committing the changes..."
git commit -m "Bump version to ${NEW_VERSION}." && echo -e "\033[32mSuccess: Changes committed.\033[0m" || echo -e "\033[31mError: Failed to commit changes.\033[0m"
git push origin && echo -e "\033[32mSuccess: Changes pushed to origin.\033[0m" || echo -e "\033[31mError: Failed to push changes to origin.\033[0m"

#
# Tag the current commit.
#
git tag -a $GIT_TAG -m "Tag version ${NEW_VERSION}." && echo -e "\033[32mSuccess: Tagged version ${NEW_VERSION}.\033[0m" || echo -e "\033[31mError: Failed to tag version ${NEW_VERSION}.\033[0m"
git push origin --tags && echo -e "\033[32mSuccess: Pushed tags to origin.\033[0m" || echo -e "\033[31mError: Failed to push tags to origin.\033[0m"

#
# Done.
#
echo -e "\033[32mDone.\033[0m"

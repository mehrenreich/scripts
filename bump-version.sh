#!/bin/bash
#
# Script to bump the version of a project.
#
# Most parts of the script are written by GitHub Copilot.
#
# Heavily inspired by https://gist.github.com/mareksuscak/1f206fbc3bb9d97dec9c. Thanks!
#


CURRENT_BRANCH=`git branch --show-current`
PROTECTED_BRANCH="main"
LATEST_HASH=`git log --pretty=format:'%h' -n 1`
TEMPFILE=`mktemp`
CURRENT_VERSION=""
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
BOLD="\033[1m"
RESET="\033[0m"


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
    echo -e "${RED}You are not on the ${PROTECTED_BRANCH} branch.${RESET}"
    echo -e "${RED}Exiting...${RESET}"
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
echo -e "Latest commit hash: ${BOLD}${LATEST_HASH}${RESET}"
echo -e "Current version: ${BOLD}${CURRENT_VERSION}${RESET}"
echo -en "Enter a version number [${BOLD}${SUGGESTED_NEW_VERSION}${RESET}]: "
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
    echo -e "${RED}New version is the same as the current version.${RESET}"
    echo -e "${RED}Exiting...${RESET}"
    exit 0
fi

#
# Check if the version string is valid by using regex
#
if [[ ! $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
then
    echo -e "${RED}Invalid version string.${RESET}"
    echo -e "${RED}Exiting...${RESET}"
    exit 0
fi

echo -e "${YELLOW}Will set new version to be ${NEW_VERSION}${RESET}"

#
# Set the git tag to "v<version>".
#
echo -e "${YELLOW}Tagging version ${NEW_VERSION}...${RESET}"
GIT_TAG="v${NEW_VERSION}"

#
# Check if that tag already exists.
#
if [[ `git tag -l "${GIT_TAG}"` ]]
then
    echo -e "${RED}Tag ${GIT_TAG} already exists.${RESET}"
    echo -e "${RED}Exiting...${RESET}"
    exit 0
fi

#
# Update the VERSION file.
#
echo -e "${YELLOW}Updating VERSION file...${RESET}"
echo "${NEW_VERSION}" > VERSION

#
# Update the CHANGELOG.md file.
#
if [[ -f CHANGELOG.md ]]
then
    echo -e "${YELLOW}Updating CHANGELOG.md file...${RESET}"
else
    echo -e "${YELLOW}Creating CHANGELOG.md file...${RESET}"
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
git commit -m "Bump version to ${NEW_VERSION}." && echo -e "${GREEN}Success: Changes committed.${RESET}" || echo -e "${RED}Error: Failed to commit changes.${RESET}"
git push origin && echo -e "${GREEN}Success: Changes pushed to origin.${RESET}" || echo -e "${RED}Error: Failed to push changes to origin.${RESET}"

#
# Tag the current commit.
#
git tag -a $GIT_TAG -m "Tag version ${NEW_VERSION}." && echo -e "${GREEN}Success: Tagged version ${NEW_VERSION}.${RESET}" || echo -e "${RED}Error: Failed to tag version ${NEW_VERSION}.${RESET}"
git push origin --tags && echo -e "${GREEN}Success: Pushed tags to origin.${RESET}" || echo -e "${RED}Error: Failed to push tags to origin.${RESET}"

#
# Done.
#
echo -e "${GREEN}Done.${RESET}"

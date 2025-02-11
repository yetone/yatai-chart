#!/usr/bin/env bash
set -e


# Use this scripot to update the Yatai image value in the `value.yaml` file and then make a commit to the
# `artifacthub-io-release` branch.

if [ "$#" -eq 1 ]; then
    YATAI_IMAGE=$1
else
    echo "Usage: $0 <YATAI_IMAGE>"
    exit 1
fi

GIT_ROOT=$(git rev-parse --show-toplevel)

# Checkout the `artifacthub-io-release` branch
echo "Checking out the artifacthub-io-release branch..."
git checkout artifacthub-io-release


# Update the values.yaml file
echo "Updating the value.yaml file with the new Yatai image..."
if [[ "$OSTYPE" =~ ^darwin ]]; then
    # Note
    # for Mac users who get an invalid command code C error... For in-place
    # replacements, BSD sed requires a file extension after the -i flag because it
    # saves a backup file with the given extension. For example: sed -i '.bak'
    # 's/find/replace/' /file.txt You can skip the backup by using an empty
    # string like so: sed -i '' 's/find/replace/' /file.txt –
    echo "Mac OS detected"
    sed -i '' "s/^  tag:.*$/  tag: $YATAI_IMAGE/" values.yaml
else
    echo "Linux OS detected"
    sed -i "s/^  tag:.*$/  tag: $YATAI_IMAGE/" values.yaml
fi

# generate index.yaml and .tgz file
echo "Generating index.yaml and .tgz file..."
make generate

# commit the changes
echo "Committing the changes..."
git add values.yaml index.yaml

# Find the .tgz file name and add it to the commit
TAR_FILE=$(find . -name "*.tgz")
git add "$TAR_FILE"

# commit the changes
git commit -m "Update Yatai image to $YATAI_IMAGE"

# push the changes
git push origin artifacthub-io-release

echo "Done!"


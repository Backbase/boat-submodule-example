#!/bin/sh

# Check if file exists
if [ -f "$1" ]; then
    echo "Processing $1"
else
    echo "File $1 doesn't exist. Abort"
    exit 1
fi

# Check if it is *.yaml file
if ! echo "$1" | grep -Eq "^.*\.yaml$"; then
  echo "Please provide *.yaml file"
  exit 1
fi

# Strip filename of dashes and extension, and making it lowercase
# Example: eBill-Service.yaml -> ebillservice
MODULE_NAME=$(echo "$1" | sed -r 's/-//g' | sed -r 's/\.yaml$//g' | tr '[:upper:]' '[:lower:]')
echo "Create temp directory $MODULE_NAME"

rm -rf "$MODULE_NAME" 2> /dev/null
mkdir "$MODULE_NAME"

echo "Copy $1 into temp directory"
cp "$1" "$MODULE_NAME/$1"

echo "Generate pom.xml"
cat android-pom-template.xml | sed -r "s/CLIENT_SPEC_PATH/$1/g" | sed -r "s/CLIENT_MODULE_NAME/$MODULE_NAME/g" | sed -r "s/CLIENT_PACKAGE_NAME/com.backbase.android.client.$MODULE_NAME/g" > "$MODULE_NAME/pom.xml"

echo "Generate clients based on specs"
cd "$MODULE_NAME" || exit 1

mvn boat:generate

# Make sure if android/src/main/java/com/backbase/android/client exists
if [ -d "../../android/src/main/java/com/backbase/android/client" ]; then
    echo "Clients directory exists"
else
    echo "Clients directory doesn't exists. Creating one..."
    mkdir -p ../../android/src/main/java/com/backbase/android/client
fi

# Remove current clients implementation
echo "Remove current client implementation from ../../android/src/main/java/com/backbase/android/client/$MODULE_NAME"
rm -rf "../../android/src/main/java/com/backbase/android/client/$MODULE_NAME" 2> /dev/null

# Copy newly generated clients implementation
echo "Copy newly generated clients implementation to ../../android/src/main/java/com/backbase/android/client/$MODULE_NAME"
cp -r "$MODULE_NAME/src/main/java/com/backbase/android/client/$MODULE_NAME" "../../android/src/main/java/com/backbase/android/client/"

# Return to initial directory
cd ..

# Remove temporary directory
echo "Clean up..."
rm -rf "$MODULE_NAME" 2> /dev/null

echo "Finished successfully."

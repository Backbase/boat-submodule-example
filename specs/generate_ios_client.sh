#!/bin/bash

echo "Enter API Client Name:"
read CLIENT_FILE_NAME
echo "Enter API Client Version:"
read CLIENT_VERSION

CLIENT_NAME="${CLIENT_FILE_NAME%-*}"
CLIENT_YAML_VERSION="${CLIENT_FILE_NAME##*-}"

mkdir -p "$CLIENT_NAME"

POM_FILE="$CLIENT_NAME/pom.xml"
CONFIG_FILE="$CLIENT_NAME/generator_config.yaml"

cat <<EOF > "$POM_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <artifactId>boat-swift-client</artifactId>
  <groupId>com.backbase.dbs</groupId>
  <version>0.1.0</version>
  <packaging>pom</packaging>
  <properties>
    <codegen.boat.version>0.17.50</codegen.boat.version>
    <clientName>$CLIENT_NAME</clientName>
    <clientVersion>$CLIENT_VERSION</clientVersion>
    <clientSpecPath>${CLIENT_NAME}-${CLIENT_YAML_VERSION}.yaml</clientSpecPath>
    <clientModuleName>$CLIENT_NAME</clientModuleName>
    <clientOutput>${CLIENT_NAME}</clientOutput>
  </properties>
  <build>
    <plugins>
      <plugin>
        <groupId>com.backbase.oss</groupId>
        <artifactId>boat-maven-plugin</artifactId>
        <version>\${codegen.boat.version}</version>
        <configuration>
            <generateSupportingFiles>true</generateSupportingFiles>
            <configurationFile>generator_config.yaml</configurationFile>
            <skipValidateSpec>true</skipValidateSpec>
            <inputSpec>\${project.basedir}/\${clientSpecPath}</inputSpec>
            <generatorName>boat-swift5</generatorName>
            <output>\${clientOutput}</output>
            <enablePostProcessFile>true</enablePostProcessFile>
            <additionalProperties>
                <additionalProperty>podVersion=\${clientVersion}</additionalProperty>
                <additionalProperty>projectName=\${clientModuleName}</additionalProperty>
                <additionalProperty>projectDescription=\${clientModuleName}</additionalProperty>
                <additionalProperty>podSummary=\${clientModuleName}</additionalProperty>
                <additionalProperty>podDescription=\${clientModuleName}</additionalProperty>
                <additionalProperty>validatable=false</additionalProperty>
            </additionalProperties>
            <input/>
            <model/>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
EOF

cat <<EOF > "$CONFIG_FILE"
podAuthors: Backbase B.V.
podHomepage: https://backbase.io/for-developers
podLicense: Backbase License
responseAs: Call
library: dbsDataProvider
files:
  api.mustache:
    templateType: API
    destinationFilename: .swift
  api_parameters.mustache:
    templateType: API
    destinationFilename: RequestParams.swift
  model.mustache:
    templateType: Model
    destinationFilename: .swift
  model_doc.mustache:
    templateType: ModelDocs
    destinationFilename: .md
  api_doc.mustache:
    templateType: APIDocs
    destinationFilename: .md
EOF

echo "Copy $CLIENT_NAME-$CLIENT_YAML_VERSION.yaml to /$CLIENT_NAME"
cp -r "$CLIENT_NAME-$CLIENT_YAML_VERSION.yaml" "$CLIENT_NAME/$CLIENT_NAME-$CLIENT_YAML_VERSION.yaml"

cd $CLIENT_NAME
mvn boat:generate

echo "Remove pom.xml, generator.yaml and "$CLIENT_NAME-$CLIENT_YAML_VERSION.yaml" files from temporary directory."
rm -rf "generator_config.yaml"
rm -rf "pom.xml"
rm -rf "$CLIENT_NAME-$CLIENT_YAML_VERSION.yaml"

cd ..

# Make sure that ../ios exists
mkdir -p ../ios

echo "Remove current client implementation from ../ios/$CLIENT_NAME"
rm -rf "../ios/$CLIENT_NAME" 2> /dev/null

echo "Copy newly generated clients implementation to ../ios/$CLIENT_NAME"
cp -r "$CLIENT_NAME" "../ios/"

echo "Remove temporary client files"
rm -rf "$CLIENT_NAME"

cd ..

PODFILE_PATH="../Podfile"

dir_name=$(basename "$PWD")
POD_ENTRY="pod '$CLIENT_NAME', :path => './$dir_name/ios/$CLIENT_NAME/$CLIENT_NAME'"

if grep -qF "$POD_ENTRY" "$PODFILE_PATH"; then
    echo "Pod entry already exists. Skipping..."
else
    sed -i '' "/abstract_target 'Common'/a \\
    $POD_ENTRY
    " "$PODFILE_PATH"
fi

cd ..

bundle exec pod install

echo "Finished successfully."

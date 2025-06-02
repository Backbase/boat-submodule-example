#!/bin/bash

echo "Enter API Client Name:"
read CLIENT_NAME
echo "Enter Client API yaml version:"
read CLIENT_YAML_VERSION
echo "Enter API Client Version:"
read CLIENT_VERSION
echo "Enter Folder Destination:"
read DEST_FOLDER

mkdir -p "$DEST_FOLDER"

POM_FILE="pom.xml"
CONFIG_FILE="generator_config.yaml"

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
    <clientOutput>${DEST_FOLDER}</clientOutput>
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

mvn boat:generate

# Prerequisites

Before running any of the scripts, ensure you have the following:  

- An OpenAPI spec YAML file  
- Java **version 21 or later**  
- Maven installed  

# Android OpenAPI Client Generator

To generate api and models for a single service .yaml file go to specs directory and run:

```sh
./generate_android_client.sh <YAML_FILE_NAME>
```
This will create kotlin files in `android/src/main/java/com/backbase/android/client` directory.

To use generated api and models in your main project we need to satisfy `android/build.gradle`. In `settings.gradle.kts` of your main project should be (if it’s not already there):

```kotlin
dependencyResolutionManagement {
    versionCatalogs {
        create("libs") {
            from("com.backbase.android.platform:catalog-third-parties:2025.01.01")
        }
        create("midTierLibs") {
            from("com.backbase.android.platform:catalog-mid-tier:2025.01.01")
        }
    }
}
```

Next include submodule/android as gradle module into `settings.gradle.kts`:

```kotlin
include(":custom-clients-submodule:android")
```

Now you can declare it as dependency in your retail (or any other) module `build.gradle.kts`:

```kotlin
dependencies {
    implementation(projects.customClientsSubmodule.android)
}
```

After gradle sync generated api and models should be available in your project.


# iOS OpenAPI Client Generator

There are two script allows you to generate a client API from an OpenAPI specification.

## Standalone generation of the client
 
 This will generate the client in a folder of your choice, without placing it in the directories of the submodule.

Run this command:

```sh
sh ios_client_generation.sh
```

After running the command, you will be prompted with a few questions to proceed with the generation:

- **Enter API Client Name**  
  Provide a name for the client. It should match the OpenAPI spec name but **without the version**.  
  - Example:  
    ```yaml
    QuickPaymentsApi-3.0.0.yaml → Client name: QuickPaymentsApi
    ```

- **Enter Client API YAML Version**  
  Specify the version of the YAML file.  
  - Example:  
    ```yaml
    QuickPaymentsApi-3.0.0.yaml → YAML version: 3.0.0
    ```

- **Enter API Client Version**  
  Define the version of the client.  
  - Example: `1.0.0`

- **Enter Folder Destination**  
  Specify the folder where the client will be generated.  
  - If the folder **does not exist**, it will be created automatically.

## Client in submodule

For building the client and placing all the files in correct directiories of submodule, follow the steps below: 

Run this command:

```sh
sh generate_ios_client.sh
```

After running the command, you will be prompted with a few questions to proceed with the generation:

- **Enter API Client Name**  
  Provide a name for the client. It should match the OpenAPI spec name. 
  - Example:  
    ```yaml
    QuickPaymentsApi-3.0.0.yaml
    ```

- **Enter API Client Version**  
  Define the version of the client.  
  - Example: `1.0.0`

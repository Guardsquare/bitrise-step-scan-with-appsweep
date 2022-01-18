# Upload release to AppSweep

The Step runs the AppSweep Gradle task to upload your app for security scanning to [AppSweep](https://appsweep.guardsquare.com). 

## How to use this Step

You can also add this step directly to your workflow in the [Bitrise Workflow Editor](https://devcenter.bitrise.io/steps-and-workflows/steps-and-workflows-index/).  
Alternatively, you can run is with the [bitrise CLI](https://github.com/bitrise-io/bitrise).

To use this Step, you need:

* A [Gradle Wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html) in your project. If it is in root folder, then it can be used automatically by this step. If it is located elsewhere, please specify its location in `GRADLEW_PATH`.
* The Gradle AppSweep plugin. If you have a common folder structre (in particular `./app/build.gradle` is your app's gradle file) then the plugin will be injected automatically. Otherwise you need to add the AppSweep plugin manually, by adding `id "com.guardsquare.appsweep" version "latest.release"` to the plugin section of your app's build.gradle script.
* An `APPSWEEP_API_KEY` must be set, you can generate it in the API Keys section of your project settings in the AppSweep UI. This key **SHOULD NOT** be checked into your repository, but set up as a [Bitrise Secret](https://devcenter.bitrise.io/en/builds/secrets.html).
* By default the `release` build will be scanned. If you want to change this, set `build_variant: debug` in your steps configuration.


## Configuration

The step can either be configured directly in the `bitrise.yml`, or in the visual step configuration in the Workflow Editor.
| Parameter         | Default     | Description |
|--------------|-----------|------------|
| appsweep_api_key| `APPSWEEP_API_KEY` secret key | Must be set to allow scanning of the app inside an AppSweep project. You can generate it in the API Keys section of your project settings in the AppSweep UI.| 
| build_variant | release | Set to `debug` to upload the debug version of your app, or to `release` to upload the release version. |
| project_location | `$PROJECT_LOCATION` | Set this to the location of your project inside your repository. |
| gradle_plugin_version | `0.1.7` | Set to particular numerical value or to `latest.release` (requires at least Gradle 7). |


## Example bitrise.yml step

```
- git::https://github.com/Guardsquare/bitrise-step-scan-with-appsweep.git@main:
    title: AppSweep
    inputs:
    - build_variant: debug
```

### Troubleshooting 

If the step fails because of **Task was not found in root project** it means that the plugin was not injected properly. Please add the gradle plugin manually to `build.gradle`. 

If the step fails with **The gradlew wrapper was not found. Please provide the correct project_location** that means that path to gradlew is not correct. Please remember that, the `project_location` must be point to the root of the repository which should contain `gradlew`.

If the step fails with **Required input APPSWEEP_API_KEY is empty** it means that AppSweep API key was not set. It can be set up as a [Bitrise Secret](https://devcenter.bitrise.io/en/builds/secrets.html), as an input or it can be exported as environmental variable. 

# Upload build to AppSweep

The Step runs uploads a release or debug build to [AppSweep](https://appsweep.guardsquare.com) for security scanning. It
supports iOS and Android builds.

For Android, the AppSweep Gradle plugin is used to upload your app. For iOS the, [Guardsquare CLI](https://appsweep.guardsquare.com/docs/ci/guardsquare-cli) is used for the upload.

## How to use this Step

You can also add this step directly to your workflow in the [Bitrise Workflow Editor](https://devcenter.bitrise.io/steps-and-workflows/steps-and-workflows-index/).  
Alternatively, you can run it with the [bitrise CLI](https://github.com/bitrise-io/bitrise).

To use this app, the `APPSWEEP_API_KEY` variable must be passed. You can generate it in the API Keys section of your project settings on the [AppSweep website](https://appsweep.guardsquare.com/) . This key **SHOULD NOT** be checked into your repository, but set up as a [Bitrise Secret](https://devcenter.bitrise.io/en/builds/secrets.html).

See below for the platform-specific configuration.

### Android

To use this Step, you need:

* A [Gradle Wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html) in your project. It is expected in the root folder.
* The Gradle AppSweep plugin. If you have a common folder structre (in particular `./app/build.gradle` is your app's gradle file) then the plugin will be injected automatically. Otherwise you need to add the AppSweep plugin manually, by adding `id "com.guardsquare.appsweep" version "latest.release"` to the plugin section of your app's build.gradle script.
* By default the `release` build will be scanned. If you want to change this, set `build_variant: debug` in your steps configuration.

### iOS

To configure in the path of your build, set either the path to the `.ipa` (`$BITRISE_IPA_PATH`) file or to the `xcarchive` directory (`$BITRISE_XCARCHIVE_PATH`, default value). Optionally, it is possible to set the path to the dSYM directory. This is useful if the archive does not contain debug information and you want AppSweep to perform in-depth analysis.

## Configuration

The step can either be configured directly in the `bitrise.yml`, or in the visual step configuration in the Workflow Editor.
| Platform | Parameter         | Default     | Description |
|----------|-------------------|-------------|-------------|
| both | appsweep_api_key| `APPSWEEP_API_KEY` secret key | Must be set to allow scanning of the app inside an AppSweep project. You can generate it in the API Keys section of your project settings in the AppSweep UI.| 
| Android | build_variant | release | Set to `debug` to upload the debug version of your app, or to `release` to upload the release version. |
| Android | project_location | `$PROJECT_LOCATION` | Set this to the location of your project inside your repository. Inside this directory, the build file should be accesible via path ./app/build.gradle and ./gradlew should be directly in the project_location. If your project has a traditional structure, the default value should be correct.|
| Android | gradle_plugin_version | `1.0.0` | Set to particular numerical value or to `latest.release` (requires at least Gradle 7). If the plugin is already configured in your repository then this option has no impact.|
| iOS | ios_archive_path | `$BITRISE_XCARCHIVE_PATH` | Path to either the IPA file or the xcarchive directory (not a zip file). |
| iOS | ios_dsyms_dir_path | `$BITRISE_DSYM_DIR_PATH` | Path to the dSYMs directory. Useful when the archive does not contain debug symbols. |

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

# Upload build to AppSweep

The step uploads a release or debug build to [AppSweep](https://appsweep.guardsquare.com) for security scanning. It supports iOS and Android apps.

The AppSweep Gradle plugin is used to upload your Android app, while the [Guardsquare CLI](https://appsweep.guardsquare.com/docs/ci/guardsquare-cli) is used for iOS.

## How to use this Step

You can also add this step directly to your workflow in the [Bitrise Workflow Editor](https://devcenter.bitrise.io/steps-and-workflows/steps-and-workflows-index/).  
Alternatively, you can run it with the [bitrise CLI](https://github.com/bitrise-io/bitrise).

The `APPSWEEP_API_KEY` variable must be set. You can generate it in the API Keys section of your project settings on the [AppSweep website](https://appsweep.guardsquare.com/) . This key **SHOULD NOT** be checked into your repository, but set up as a [Bitrise Secret](https://devcenter.bitrise.io/en/builds/secrets.html).

See below for the platform-specific configuration.

### Android

To use this step, you need:

* A [Gradle Wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html) in your project. It is expected in the root folder.
* The Gradle AppSweep plugin. If you have a common folder structure (in particular `./app/build.gradle` is your app's gradle file) then the plugin will be injected automatically. Otherwise you need to add the AppSweep plugin manually, by adding `id "com.guardsquare.appsweep" version "latest.release"` to the plugin section of your app's build.gradle script.
* By default, the `release` build will be scanned. If you want to change this, set `build_variant` to the desired variant in your step's configuration.

### iOS

Add this step after the build phase and the archive will be uploaded. No further configuration is needed when using the default bitrise build steps. 

If necessary, you can override the parameters of the step. In this case, make sure that the path to the debug symbols is set correctly to obtain detailed analysis results.

## Configuration

The step can either be configured directly in the `bitrise.yml`, or in the visual step configuration in the Workflow Editor.
| Platform | Parameter         | Default     | Description |
|----------|-------------------|-------------|-------------|
| both | appsweep_api_key| `APPSWEEP_API_KEY` secret key | Must be set to allow scanning of the app inside an AppSweep project. You can generate it in the API Keys section of your project settings in the AppSweep UI.| 
| Android | build_variant | release | Set to the desired build variant name for variants other than `release`. |
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

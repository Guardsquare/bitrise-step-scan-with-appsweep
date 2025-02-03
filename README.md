# Upload build to AppSweep

The step uploads a built app to [AppSweep](https://appsweep.guardsquare.com) for security scanning. It supports iOS and Android apps, and uses the [Guardsquare CLI](https://appsweep.guardsquare.com/docs/ci/guardsquare-cli) to upload the app.

## How to use this Step

You can also add this step directly to your workflow in the [Bitrise Workflow Editor](https://devcenter.bitrise.io/steps-and-workflows/steps-and-workflows-index/).  
Alternatively, you can run it with the [bitrise CLI](https://github.com/bitrise-io/bitrise).

The `APPSWEEP_API_KEY` variable must be set. You can generate it in the API Keys section of your project settings on the [AppSweep website](https://appsweep.guardsquare.com/) . This key **SHOULD NOT** be checked into your repository, but set up as a [Bitrise Secret](https://devcenter.bitrise.io/en/builds/secrets.html).

Add this step after the build phase and the app will be uploaded. No further configuration is needed when using the default bitrise build steps. 

If necessary, you can override the parameters of the step. In this case, make sure that the path to the mapping file (Android) and debug symbols (iOS) is set correctly to obtain detailed analysis results.

## Configuration

The step can either be configured directly in the `bitrise.yml`, or in the visual step configuration in the Workflow Editor.
| Platform | Parameter         | Default     | Description |
|----------|-------------------|-------------|-------------|
| both | appsweep_api_key| `APPSWEEP_API_KEY` secret key | Must be set to allow scanning of the app inside an AppSweep project. You can generate it in the API Keys section of your project settings in the AppSweep UI.| 
| Android | android_app_path | `$BITRISE_APK_PATH` | Path name to the built Android app. Can be an Android apk / aab. |
| Android | android_mappingfile_path | `$BITRISE_MAPPING_PATH` | Path to the obfuscation mapping file. E.g., ./app/build/outputs/mapping/debug/mapping.txt |
| Android | android_project_location | `$PROJECT_LOCATION` | Set this to the location of your project inside your repository. Inside this directory, the build file should be accesible at ./app/build.gradle and ./gradlew should be directly in the project_location. If your project has a traditional structure, the default value should be correct.|
| iOS | ios_archive_path | `$BITRISE_XCARCHIVE_PATH` | Path to either the IPA file or the xcarchive directory (not a zip file). |
| iOS | ios_dsyms_dir_path | `$BITRISE_DSYM_DIR_PATH` | Path to the dSYMs directory. Useful when the archive does not contain debug symbols. |

## Example bitrise.yml step

```
- git::https://github.com/Guardsquare/bitrise-step-scan-with-appsweep.git@main:
    title: AppSweep Scan
```

### Troubleshooting 

If the step fails with **Required input APPSWEEP_API_KEY is empty** it means that AppSweep API key was not set. It can be set up as a [Bitrise Secret](https://devcenter.bitrise.io/en/builds/secrets.html), as an input or it can be exported as environmental variable. 

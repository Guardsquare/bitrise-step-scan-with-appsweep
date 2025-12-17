# Upload build to AppSweep

The step uploads a built app to [AppSweep](https://appsweep.guardsquare.com) for security scanning. It supports iOS and Android apps, and uses the [Guardsquare CLI](https://appsweep.guardsquare.com/docs/ci/guardsquare-cli) to upload the app.

## How to use this Step

You can add this step directly to your workflow in the [Bitrise Workflow Editor](https://devcenter.bitrise.io/steps-and-workflows/steps-and-workflows-index/).  
Alternatively, you can run it with the [bitrise CLI](https://github.com/bitrise-io/bitrise).

Add this step after the build phase and the app will be uploaded. No further configuration is needed when using the default bitrise build steps.

If necessary, you can override the parameters of the step. In this case, make sure that the path to the mapping file (Android) and debug symbols (iOS) is set correctly to obtain detailed analysis results.

To authenticate, the preferred way is to use ssh agent authentication: You need to add a Service account public key to your team. The private key then needs to be added to your Bitrise workflow with the name `SSH_RSA_PRIVATE_KEY`. Then the step `Activate SSH key` will load this key, and the AppSweep Bitrise step will use it to authenticate.

For backwards compatibility it is also possible to use an `APPSWEEP_API_KEY` to authenticate.

## Configuration

The step can either be configured directly in the `bitrise.yml`, or in the visual step configuration in the Workflow Editor.
| Platform | Parameter         | Default     | Description |
|----------|-------------------|-------------|-------------|
| Android | android_app_path | `$BITRISE_APK_PATH` | Path name to the built Android app. Can be an Android apk / aab. |
| Android | android_mappingfile_path | `$BITRISE_MAPPING_PATH` | Path to the obfuscation mapping file. E.g., ./app/build/outputs/mapping/debug/mapping.txt |
| Android | android_project_location | `$PROJECT_LOCATION` | Set this to the location of your project inside your repository. Inside this directory, the build file should be accesible at ./app/build.gradle and ./gradlew should be directly in the project_location. If your project has a traditional structure, the default value should be correct.|
| iOS | ios_archive_path | `$BITRISE_XCARCHIVE_PATH` | Path to either the IPA file or the xcarchive directory (not a zip file). |
| iOS | ios_dsyms_dir_path | `$BITRISE_DSYM_DIR_PATH` | Path to the dSYMs directory. Useful when the archive does not contain debug symbols. |
| both | appsweep_api_key| `APPSWEEP_API_KEY` secret key | Used to authenticate your scan, if you are not using ssh agent authentication. |

## Example bitrise.yml step

```
- git::https://github.com/Guardsquare/bitrise-step-scan-with-appsweep.git@main:
    title: AppSweep Scan
```

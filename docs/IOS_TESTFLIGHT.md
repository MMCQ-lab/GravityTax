# Jelly Swing Arcade — iOS TestFlight delivery

This repository is configured for **Godot 4.7.2** and exports the iOS project with the `Jelly Swing Arcade` preset. The GitHub Actions workflow builds a signed App Store IPA only when manually run. It does **not** publish the app publicly.

## App identity

| Setting | Value |
| --- | --- |
| In-game name | Jelly Swing |
| App Store name | Jelly Swing Arcade |
| Bundle ID | `com.mmcqlab.jellyswing` |
| SKU | `MMCQLAB-JELLYSWING-001` |
| Marketing version | `1.0.0` |

Create this app record in App Store Connect before the first upload. Set the SKU exactly as listed above.

## Apple setup

1. In Apple Developer, create the App ID `com.mmcqlab.jellyswing`.
2. Create an **App Store** provisioning profile for that App ID and your Apple Distribution certificate.
3. Export the Apple Distribution certificate as a password-protected `.p12` file.
4. In App Store Connect, create **Jelly Swing Arcade** with the bundle ID and SKU above.
5. Create an App Store Connect API key with the **App Manager** role. Download its `.p8` key once and store it securely.
6. Add the repository secrets below in **GitHub → Settings → Secrets and variables → Actions**. Never commit any of these files or values.

## Required GitHub secrets

| Secret | What to store |
| --- | --- |
| `APPLE_TEAM_ID` | Your 10-character Apple Developer Team ID. |
| `APPLE_CERTIFICATE_BASE64` | Base64 of the Apple Distribution `.p12` certificate. |
| `APPLE_CERTIFICATE_PASSWORD` | Password used when exporting that `.p12`. |
| `APPLE_PROVISIONING_PROFILE_BASE64` | Base64 of the App Store `.mobileprovision` file. |
| `APPLE_PROVISIONING_PROFILE_NAME` | Provisioning profile **Name** shown in Apple Developer. |
| `KEYCHAIN_PASSWORD` | A random, workflow-only password for the temporary macOS keychain. |
| `APP_STORE_CONNECT_KEY_ID` | The API key ID from App Store Connect. |
| `APP_STORE_CONNECT_ISSUER_ID` | The issuer UUID from App Store Connect. |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64 of the App Store Connect API key `.p8` file. |

### Base64 commands

macOS:

```bash
base64 -i AppleDistribution.p12 | pbcopy
base64 -i JellySwing.mobileprovision | pbcopy
base64 -i AuthKey_ABC123DEFG.p8 | pbcopy
```

Linux:

```bash
base64 -w 0 AppleDistribution.p12
base64 -w 0 JellySwing.mobileprovision
base64 -w 0 AuthKey_ABC123DEFG.p8
```

## Run the first build

1. Commit and push the repository, including `.github/workflows/ios-testflight.yml`.
2. In GitHub, choose **Actions → iOS TestFlight → Run workflow**.
3. Leave **Upload the signed IPA** off for a signing-only build. Download and inspect the IPA artifact.
4. Run it again with upload enabled to send the IPA to App Store Connect. The IPA appears in TestFlight after Apple processes it.
5. Add internal testers in App Store Connect. This workflow never submits the app for App Review or public App Store release.

## Build numbers

The workflow uses `GitHub run number + build_number_offset` as `CFBundleVersion`, so each workflow build increments automatically. If App Store Connect already contains a larger build number, supply an offset when manually dispatching the workflow. The resulting number must always be larger than the latest uploaded build for this bundle ID.

## Local iOS export

Use Godot 4.7.2 with the matching export templates installed, select **Jelly Swing Arcade**, and export to an Xcode project on macOS. Signing still requires the Apple certificate and provisioning profile; no credentials are stored in this repository.

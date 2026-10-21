# Jelly Swing Arcade iOS AdMob

This branch vendors [godot-sdk-integrations/godot-admob v7.0](https://github.com/godot-sdk-integrations/godot-admob/releases/tag/v7.0), which supports Godot 4.7. The MIT license is in `addons/AdmobPlugin/LICENSE`. Its iOS static libraries are in `ios/plugins/`; its export plugin adds Google Mobile Ads SDK 12.14.0 through Swift Package Manager. No signing material is stored in the repository.

## Placements

| Placement | Format | Production ad unit |
| --- | --- | --- |
| Menu and results bottom banner | Anchored adaptive banner | `ca-app-pub-4782649901919643/3290909050` |
| Watch Ad for 10 coins | Rewarded | `ca-app-pub-4782649901919643/9954274346` |
| Every third finalized death | **Standard interstitial** | `ca-app-pub-4782649901919643/1977827386` |

The iOS AdMob App ID is `ca-app-pub-4782649901919643~3774299795`. The retired rewarded-interstitial unit is not configured or requested.

`ads/ad_manager.gd` owns the identifiers, consent gate, loading, retries, safe-area banner, reward callback and full-screen callbacks. `game.gd` owns the existing death cadence. A third death counts only once, and the game-over screen is already shown when the standard interstitial is offered. Missing inventory or a 90-second cooldown simply leaves the results screen visible. The interstitial never grants currency or a revive. Its next instance is preloaded after dismissal or display failure.

The existing Watch Ad button grants 10 coins only when the plugin emits `rewarded_ad_user_earned_reward`. It saves the existing wallet once. The existing ad-funded continue and chest reroll also use the rewarded callback on iOS. Closing a rewarded ad before the reward callback grants nothing. The local and web placeholder flows remain available for testing without the iOS SDK.

## Test ads and production switch

The committed default is **test ads**: `project.godot` has `ads/use_production_ads=false`, and `addons/AdmobPlugin/ios_export.cfg` has `is_real=false`. These select Google's official iOS demo App ID and demo banner, rewarded, and ordinary interstitial units. The TestFlight workflow uses these defaults. [Google's test ad guide](https://developers.google.com/admob/ios/test-ads) lists the demo units and explains device test mode.

For a later production release, deliberately set **both** `ads/use_production_ads=true` in `project.godot` and `is_real=true` in `addons/AdmobPlugin/ios_export.cfg`, then review the three production IDs above. The first switch changes the runtime ad units; the second changes the exported `GADApplicationIdentifier`. Do not flip only one. Register physical test devices in AdMob before testing production units. Do not click live ads during development.

## Export and TestFlight

The existing `.github/workflows/ios-testflight.yml` signing and upload steps are retained. One Ruby helper dependency (`xcodeproj`) is installed before Godot export because the plugin adds the GoogleMobileAds Swift package to the generated Xcode project. The workflow checks that the resulting project references `AdmobPlugin` and `GoogleMobileAds`, and that the generated Info.plist contains `GADApplicationIdentifier`, before archiving. `export_presets.cfg` enables the iOS native plugin. GitHub Actions must still resolve the Swift package and build/sign the archive on macOS; Windows cannot validate the final native link.

After a test IPA is uploaded, install it on a physical iPhone through TestFlight and verify:

1. The bottom banner appears on menus/results within the safe area and hides during gameplay.
2. Watch Ad grants exactly 10 coins after a reward is earned; closing early grants none. Retry when offline or no inventory is available.
3. The third, sixth, and ninth finalized deaths offer a **standard** interstitial at results. Rapid deaths respect the 90-second cooldown. Ads never show during a run and never grant a reward.
4. The consent flow appears where required, and declining personalization does not break gameplay. Inspect the native Info.plist and AdMob test-mode label.

## Privacy review before public release

The plugin requests UMP consent information before initializing ads or loading inventory. A required form is presented before ad requests; an unknown consent state suppresses ads. Configure and publish the appropriate privacy message in AdMob. The plugin's iOS exporter adds the App ID and Google SKAdNetwork identifiers. Review the generated Info.plist, Apple's tracking and privacy disclosures, the Google SDK privacy manifest, whether ATT is appropriate for the actual data flow, and whether the game's intended audience needs child-directed treatment. ATT is left disabled because this project has not established a tracking policy. A user-facing privacy-options control is not yet implemented; add one if your AdMob message requires it. Do not consider App Store privacy configuration complete until that review and device testing are done.

# App Store Connect: App Privacy answers (draft)

Draft answers for **App Store Connect → Jelly Swing Arcade → App Privacy**, based on what the game and its one SDK (Google Mobile Ads, via the AdMob plugin) do. This is a starting point, not legal advice. Re-check it against Google's current disclosure page before you submit:
https://developers.google.com/admob/ios/privacy/data-disclosure

## What the game itself collects

Nothing. Scores, coins, unlocked jellies and settings stay on the device (`user://gravity_tax_scores.cfg`). The game has no accounts, no analytics and no server.

## What Google Mobile Ads collects (per Google's disclosure page)

| App Store category | Data type | Purposes to tick | Linked to the user? | Used for tracking? |
|---|---|---|---|---|
| Location | Coarse location (estimated from IP address) | Third-Party Advertising, Analytics | No | See "Tracking" below |
| Identifiers | Device ID (IDFA only if the user allows tracking; otherwise app/developer-scoped IDs) | Third-Party Advertising, Analytics | No | See "Tracking" below |
| Usage Data | Advertising Data (ads seen/clicked) | Third-Party Advertising, Analytics | No | See "Tracking" below |
| Usage Data | Product Interaction (app launches, taps, video views) | Third-Party Advertising, Analytics | No | See "Tracking" below |
| Diagnostics | Crash Data | App Functionality, Analytics | No | No |
| Diagnostics | Performance Data (launch time, hangs, energy) | Third-Party Advertising, Analytics | No | See "Tracking" below |

Data Collected? **Yes** (because of the ad SDK).

## Tracking and the ATT prompt (a decision for you)

The game currently **does not** show Apple's App Tracking Transparency (ATT) prompt, and `NSUserTrackingUsageDescription` is not set. In that case iOS gives the ad SDK no IDFA. Google can still serve ads, including through Google's own consent tools.

- **Option A, no ATT (current):** answer "No" to *used to track*. Simplest choice, and no extra pop-up for players. Ads earn somewhat less.
- **Option B, add ATT:** show Apple's prompt before ads load, add `NSUserTrackingUsageDescription` (for example "Allows more relevant ads that keep Jelly Swing free."), and mark Device ID, Advertising Data and Product Interaction as *used for tracking*. More ad revenue when players allow it.

The plugin already has `request_tracking_authorization()`, so Option B is a small code change if you choose it.

## Consent (EU/UK)

Google's UMP consent flow already runs before any ad loads (`ads/ad_manager.gd`). Before launch:

1. In AdMob → Privacy & messaging, create and publish a GDPR message for the app.
2. The plugin does not expose UMP's "privacy options" form. If your published message requires players to be able to change their choice later, that entry point still needs adding.

## Other App Store Connect fields

- **Privacy Policy URL:** required. It must mention that ads are served by Google AdMob and link to https://policies.google.com/technologies/ads
- **Age rating:** the questionnaire asks about ads. If you set the age rating below 13, or target children, AdMob must be set to child-directed treatment, which isn't configured.
- **Export compliance:** already declared in the build (`ITSAppUsesNonExemptEncryption = false`).

# Jelly Swing Arcade (GravityTax): Release Readiness

**Studio:** MMCQ-Lab  **Bundle ID:** `com.mmcqlab.jellyswing`  **Engine:** Godot 4.7.2 (GL Compatibility)
**Audited:** 2026-10-20, on branch `release/readiness`, based on `main` @ `a19a8f0` (TestFlight build 12)
**Environment:** Linux cloud workspace. Godot 4.7.2 headless and Xvfb rendering were used. No Mac, no iPhone, and no App Store Connect access.

Status key: **PASS** = verified by tests or direct inspection · **NEEDS MANUAL TEST** = needs a device, TestFlight or App Store Connect · **BLOCKED** = cannot be done with current access · **FAIL** = a known problem remains

---

## 1. Summary of changes in this pass

| Area | Change |
|---|---|
| Save system | Scores, profile and settings are now written together in one atomic save, using a temp file, a swap and a `.bak` backup. A damaged save falls back to the backup. Invalid values are cleaned up: negative coins, unknown skin ids, a bad equipped skin. |
| Save bug | **Fixed:** `save_high_score()` used to rewrite the save file from scratch, which erased coins and unlocked jellies until `save_profile()` ran again. A crash or kill between the two would lose progress. A regression test now covers this. |
| Audio | Separate **Music** and **SFX** buses. Music and SFX volume sliders plus **Mute all**, saved between sessions. Closing an ad no longer un-mutes a player who chose mute. |
| Pause / lifecycle | Pause button during runs, and a pause menu (Resume / settings / Home). The game saves and auto-pauses when iOS backgrounds the app or the window loses focus. |
| Input | **Fixed:** lifting a finger without a matching press (for example the tap on Resume or a menu button) used to trigger an unwanted jump. Taps on the pause button no longer reach the jelly. |
| Settings | Settings button on the main menu. **Credits & Licenses** screen with the Godot MIT licence and Pixabay audio attribution. |
| Safe areas | HUD, shop header and settings button move below the notch / Dynamic Island. The banner sits above the home indicator. |
| Rarity colours | Common gray, Uncommon green, Rare blue, Epic purple, Legendary gold, used on jelly cards and chest labels. Chest labels now show every price (Rare and Legendary were missing theirs). |
| App icon | **Fixed:** iOS was using Godot's default robot icon (`icon.svg`). It now uses `images/app_icon_1024.png`, an opaque 1024×1024 version of the Jelly mascot art, for the project icon and the App Store 1024 icon. |
| Export compliance | Checked: Godot's iOS template already sets `ITSAppUsesNonExemptEncryption = false`, so no change was needed. |
| Texture memory | 15 textures authored at 1254–2172 px but drawn at 30–250 px are now imported with size caps. Estimated decoded texture memory for them drops from **~94 MB to ~13 MB**. Sprite scales are now calculated from the imported size, so everything looks the same on screen (checked visually). |
| Export size | 20 unused images (~28.6 MB: older jelly renders, sheets, previews) are **excluded from both iOS and Web exports**. The game package drops from **48–54 MB to 20 MB** (iOS and Web `.pck`, measured). They were not deleted. They are listed in §9 for your review. |
| CPU | Bot rope-cutting check: an O(n²) loop that called `get_children()` inside the loop was rewritten with a bounding-box pre-check. **1.53 ms → 0.17 ms per frame.** It matched the old logic on 900 randomized frames (0 mismatches). Average script frame time in Sky Climb, measured headless: 6.98 → 3.39 ms. |
| CI | New `validate` job runs before the iOS build: imports the project, checks that every `.gd` script parses, then runs the test suite. The iOS build only runs if validation passes. |
| Versioning | The marketing version now comes from `config/version="1.0.0"` in `project.godot`, and the workflow rejects anything that is not `x.y.z`. The build number stays `GITHUB_RUN_NUMBER + offset`, which only ever increases. |
| Tests | `tests/run_tests.gd`: 66 headless checks (see §7). They use a throwaway save file and never touch a real player save. |
| Character IP | Five skins that resembled Luffy, Spider-Man, the Creeper, Batman and Iron Man were kept but edited to be generic (§9). |
| iPad | Menus centre on wider screens, the HUD stays edge-anchored, and the menu art keeps its logo visible. Pop-up messages now sit below the leaderboard. |

Nothing has been committed or pushed. All changes are on the local `release/readiness` branch, waiting for approval.

---

## 2. Bugs discovered and fixed

| # | Bug | Impact | Status |
|---|---|---|---|
| 1 | `save_high_score()` overwrote the whole save file | Coins and jelly unlocks briefly erased; lost if the app was killed at that moment | **PASS** (fixed + regression test) |
| 2 | App icon was the Godot default logo | The TestFlight / App Store icon was Godot's | **PASS** (fixed; needs on-device confirmation) |
| 3 | Orphan finger-release caused a jump | Unwanted jump after Resume / overlay taps | **PASS** (fixed + test) |
| 4 | Ads un-muted audio a player had muted | Ignored player preference | **PASS** (fixed + test) |
| 5 | No pause; backgrounding the app mid-run kept the game running | Deaths while away and lost runs | **PASS** (fixed + test) |
| 6 | Rare/Legendary chest labels had no price | Confusing shop | **PASS** (fixed) |
| 7 | 1254 px sprites drawn at ~30 px with no mipmaps | ~80 MB of wasted texture memory, plus shimmering | **PASS** (fixed) |
| 8 | Garbled `â€¢` / `â€”` characters in-game (fixed in the earlier revamp) | Broken text | **PASS** |
| 9 | Black parts of the Midnight / Sushi / Pirate sprites keyed out as transparent (fixed earlier) | Holes in jellies | **PASS** |

---

## 3. Performance

| Requirement | Status | Notes |
|---|---|---|
| Per-frame allocations reduced | **PASS** (partial) | The worst offender is fixed (see §1). Other loops still call `get_children()` each frame. They are cheap (≤0.5 ms each, headless), so I left them alone. |
| Collision / physics cost | **PASS** | Headless script time per physics frame: Sky Climb 3.4 ms, Coin Run 6.3 ms, Tag 5.5 ms (desktop CPU). Drawing the world is throttled to 20 Hz. |
| Texture memory / oversized textures | **PASS** | See §1. |
| Redundant assets | **PASS** (excluded, not deleted) | See §9. |
| Particle effects | **PASS** | There are no particle systems. Effects are cheap procedural drawing. |
| Smooth 60 FPS on iPhone | **NEEDS MANUAL TEST** | Can't be measured without a device. Phones are roughly 2–4× slower than this workspace's CPU, so Coin Run (6.3 ms here) is the mode to watch on older iPhones. |
| Loading time / freezes | **NEEDS MANUAL TEST** | Startup loads the 50 jelly sprites on demand; the remaining preloads are now small. |
| Touch responsiveness | **NEEDS MANUAL TEST** | Logic is verified; feel needs a device. |
| Safe areas / notch | **PASS** (code) / **NEEDS MANUAL TEST** (device) | Uses `DisplayServer.get_display_safe_area()`. |
| Orientation | **PASS** | Portrait only (`window/handheld/orientation=1`). 720×1280 canvas with `expand`, so taller phones get extra space at the bottom. |

## 4. Jelly assets and rarity system

| Requirement | Status | Notes |
|---|---|---|
| All 50 skins implemented | **PASS** | `images/jelly_sprites/jelly_00..49.png`; a test loads all 50. |
| Five rarity tiers | **PASS** | 10 per tier (Common 0–9, Uncommon 10–19, Rare 20–29, Epic 30–39, Legendary 40–49). |
| Rarity colours (gray/green/blue/purple/gold) | **PASS** | `CuteStyle.RARITY_COLORS`. |
| Consistent size, no stretching | **PASS** | A test confirms every jelly renders at exactly 96 px on its long edge, with aspect ratio kept. |
| Transparent backgrounds | **PASS** | All 50 checked visually; three repaired earlier. |
| Squash/stretch animations preserved | **PASS** (inspection) | Untouched. |
| Skin selection UI | **PASS** | Rarity-tinted cards, equipped outline, locked jellies dimmed. |
| Unlocks and equipped skin persist | **PASS** | Test: save round-trip plus app restart. |
| Every skin obtainable | **PASS** | Test: every id is in an available chest pool (skin 0 is the default). |
| No paid random rewards | **PASS** | Chests cost **earned coins only**. There are no in-app purchases. |
| Design rule "no arms / legs / hands / feet" | **PASS** (owner exception) | The mascot (menu art and app icon) has arms. You reviewed it and accepted it as an exception. |

## 5. Save system

| Requirement | Status | Notes |
|---|---|---|
| High scores, settings, unlocks persist | **PASS** | Tests: round-trip for coins, skins, equipped skin, scores, volumes and mute. |
| Missing / invalid save handled | **PASS** | Tests: fresh install defaults; corrupt file recovers from `.bak`; bad values sanitized. |
| Existing player progress preserved | **PASS** | The same file and keys are used (`user://gravity_tax_scores.cfg`). Old saves load. A `meta/save_version` key was added. |
| Pending chest reward never lost | **PASS** | Tests: auto-claim on leaving the shop and after an app restart. |
| Save on app background | **PASS** (code) / **NEEDS MANUAL TEST** | `NOTIFICATION_APPLICATION_PAUSED` / `FOCUS_OUT`. |
| Achievements | **N/A** | The game has no achievements. |
| Missing asset crashes | **PASS** | A test loads every referenced resource. A Godot import of the whole project reports no errors. |

## 6. Audio

| Requirement | Status | Notes |
|---|---|---|
| All music / SFX load | **PASS** | New set: 2 music tracks + 11 SFX from Pixabay (incl. wheel spin, success, revive and button-tap cues), renamed by purpose (`music_1`, `jump`, `coin`…). Preloaded, no import errors. Volumes balanced from each file's measured loudness. |
| Music / SFX volume + mute, persisted | **PASS** | Tests. |
| Music loops | **PASS** (inspection) | `AudioStreamMP3.loop = true` on both tracks. |
| No overlapping / stacking SFX | **PASS** (inspection) | Each SFX player is stopped before it replays. |
| Browser audio starts after user interaction | **PASS** (inspection) / **NEEDS MANUAL TEST** | Music only starts from a mode button press (a user gesture), and Godot's web build resumes the AudioContext on input. |
| iOS interruptions / backgrounding | **NEEDS MANUAL TEST** | The game auto-pauses and saves; check calls, Control Center and the silent switch on a device. |
| Web vs. other platforms sound difference (earlier report) | **N/A** | The web version is being retired (§11). |

## 7. Automated test results

Command: `godot --headless --path . -s res://tests/run_tests.gd`, last run **66 passed, 0 failed** (exit code 0).

Covered: resource loading; fresh-install defaults; save round-trip; corrupt-save recovery; invalid-value sanitizing; score/profile save regression; 50-skin catalogue, tiers, obtainability and render size; death → lucky spin → coins → revive; revive odds (~5% over 20,000 spins); continue-via-ad once per run; ad countdown can't be skipped; ad mute / unmute; interstitial every 3rd game over; chest claim / reroll / one-reroll limit / auto-claim / restart recovery; pause freezes physics; volume sliders; resume; orphan-release guard; Home from pause; banner and pause button visibility.

Also run: full project import (no errors) and a `--check-only` parse of all 7 scripts (all pass). The CI validation step was dry-run locally, and it correctly fails on a deliberately broken script.

Visual check: menu, gameplay (all modes), lucky spin, game over, shop (all tabs), chest claim / reroll, settings, pause, credits and placeholder ads were rendered with Godot (OpenGL, Xvfb) and inspected.

## 8. iOS build and signing

| Requirement | Status | Notes |
|---|---|---|
| Bundle ID / signing / provisioning preserved | **PASS** | Untouched. The workflow still uses only GitHub secrets. |
| Signed IPA produced by CI | **PASS** | Run #12 (build 12) on `main` @ `a19a8f0`: archive, IPA export and App Store Connect upload all succeeded. |
| Upload accepted / processed by Apple | **NEEDS MANUAL TEST** | Check that build 12 appears in App Store Connect → TestFlight. |
| App icon | **PASS** (config) / **NEEDS MANUAL TEST** | Mascot icon set; confirm it on the home screen in the next build. |
| Launch screen | **PASS** (config) | MMCQ-Lab logo on a dark background (boot splash). There is no Godot branding. |
| Minimum iOS | **PASS** | 15.0. |
| Device family (iPhone + iPad) | **PASS** (layout) / **NEEDS MANUAL TEST** | Kept iPhone + iPad. On wide screens (an iPad gives a ~960 px canvas), menus, shop and game over now centre, right-hand HUD items stay at the right edge, and the menu art keeps its logo visible. Rendered and checked at 1536×2048 (iPad) and 720×1280 (iPhone). The export sets `UIRequiresFullScreen=true` with portrait-only iPad orientation, which App Store validation accepts. iPad screenshots are needed for the listing. |
| Unique increasing build numbers | **PASS** | `GITHUB_RUN_NUMBER + build_number_offset`. |
| Semantic version | **PASS** | `project.godot` `config/version`, validated in CI. |
| Permissions / usage descriptions | **PASS** | No camera, mic, photos, location or tracking is used, so no usage strings are needed. |
| Privacy manifest | **PASS** (config) | Godot generates `PrivacyInfo.xcprivacy` from the preset's privacy settings (file timestamp, boot time, disk space reasons; tracking off). The root `PrivacyInfo.xcprivacy` is not referenced by the export; keep it or delete it. |
| Third-party SDKs / data collection | **PASS** | There are none. The game collects no data and makes no network calls. |
| No committed secrets | **PASS** | No `.p12`, `.p8`, `.mobileprovision` or keys in git; `*.ipa` and build folders are ignored. |
| Local iOS export check | **PASS** | See the addendum below. |

## 9. Licensing and intellectual property

### Asset inventory

| Asset | Source | Licence | Status |
|---|---|---|---|
| All 13 audio files (`sounds/`) | Pixabay; title, author and page URL for each in `sounds/CREDITS.md` | Pixabay Content License | **PASS**: every page checked on 2026-10-20 shows "Free for use under the Pixabay Content License". Licence certificates for both music tracks are in `sounds/licenses/`. Credited in-game. |
| All images (jellies, chests, power-ups, bat, orb, menu art, logo) | Not documented (presumably generated or made for MMCQ-Lab) | Unknown | **NEEDS MANUAL TEST**: record how each was made and the tool's commercial terms |
| Fonts | Godot built-in default font (engine-bundled); `SystemFont` on iOS (Arial Rounded MT Bold, a system font, not redistributed) | Engine licence / OS | PASS |
| Godot Engine and bundled components | godotengine.org | MIT plus third-party notices | **PASS**: shown in Settings → Credits & Licenses |

### Designs that resembled protected characters (kept, made generic)

At your request the original jellies are kept, edited so they no longer read as specific characters:

| Skin slot | Was (resembled) | Now | What changed |
|---|---|---|---|
| #30 (Epic) | Straw Hat Jelly (Luffy, *One Piece*) | **Sun Hat Jelly** | Red hat band and bandana recoloured teal; name no longer references "Straw Hat" |
| #32 (Epic) | Web Hero Jelly (Spider-Man) | **Masked Hero Jelly** | Web pattern, red/blue colours and stripes removed; smooth teal jelly with a generic navy domino mask |
| #33 (Epic) | Pixel Crawler Jelly (Minecraft Creeper) | **Pixel Block Jelly** | Creeper face removed and replaced with a cute pixel face; green recoloured blue |
| #48 (Legendary) | Shadow Knight Jelly (dark bat-like cowl) | Shadow Knight Jelly | Black hood recoloured midnight teal |
| #43 (Legendary) | Cosmic Knight Jelly (Iron Man red/gold) | Cosmic Knight Jelly | Armour recoloured teal and pale gold |

The original images stay in git history. The source sprite sheet that still contains the old designs (`jelly_sprite_sheet_fixed.png`) is no longer referenced by the scene and is excluded from exports.

Lower-risk designs left as they are: #46 Star Mushroom (astronaut helmet with a star) and #47 Sky Knight (blue helmet with fins). Both read as generic. This is a judgement call, not legal advice.

### Unused assets (excluded from exports, not deleted)

`images/epic_*_jelly.png` (10), `images/food_*_jelly.png` (5), `rare_animal_jellies.png`, `jelly_skin_catalog.png`, `jelly_sprite_sheet.png`, `jelly_sprites_preview.png`, `cute cube face.png`: 20 files, about 28.6 MB. Nothing in code or scenes references them. Delete them from the repo once you're happy (`jelly_sprite_sheet_fixed.png` is the source for the jelly sprites, so keep that one).

## 10. Monetization readiness

| Requirement | Status | Notes |
|---|---|---|
| Ad integration | **PASS** (code) / **NEEDS MANUAL TEST** | Google AdMob via the godot-admob v7.0 plugin (MIT), added by Codex and merged in PR #4. On iPhone: bottom banner on the menu and results, rewarded ads (10 coins, continue, chest reroll) that grant only on the SDK's reward callback, and a standard interstitial after every 3rd non-win death with a 90 s cooldown. Placeholders remain only for PC/editor testing. No in-app purchases. |
| Ad SDK approved | **PASS** | You approved adding ads. Google's UMP consent runs before any ad request. |
| No deceptive mechanics | **PASS** | Rewards are only granted after the ad closes. The close button counts down 5 s, then can always be closed. Lucky-spin slice sizes match the real odds. Leaving the shop never loses a won chest jelly. |
| Placeholder ads in a store build | **PASS** | On iOS the placeholders never show; real AdMob units do. If an ad isn't ready, the player gets a short "Ad not ready yet" message instead of a dead button. |
| Test vs production ads | **NEEDS DECISION** | Builds use Google's **test** ads. For release, flip both `ads/use_production_ads` (project.godot) and `is_real` (addons/AdmobPlugin/ios_export.cfg); see `docs/ADMOB_IOS.md`. |
| Banner never covers buttons | **PASS** (test) / **NEEDS MANUAL TEST** | Menus make room for the real banner's measured height; a test simulates a taller adaptive banner. |
| Privacy requirements | **NEEDS DECISION** | Draft App Privacy answers in `docs/APP_STORE_PRIVACY.md`. Still open: decide on the ATT prompt, publish a GDPR message in AdMob, and add a privacy policy URL. Original checklist: | (1) Ad SDK privacy manifest + signature; (2) **App Tracking Transparency** prompt + `NSUserTrackingUsageDescription` if the SDK uses IDFA; (3) SKAdNetwork IDs in Info.plist; (4) App Privacy "nutrition label" updated for Identifiers / Usage Data / Diagnostics; (5) an age-rating review (a game this cute may attract kids, and serving personalized ads to children is restricted, so consider non-personalized ads); (6) a privacy policy URL, which App Store Connect requires anyway. |

## 11. GitHub Actions and deployment

| Requirement | Status | Notes |
|---|---|---|
| iOS build process preserved | **PASS** | Same steps; only `needs: validate` and the version read were added. |
| Validation before packaging | **PASS** | New `validate` job (Ubuntu): import, parse every script, run the tests. |
| Build numbers auto-increment | **PASS** | |
| No secrets in logs | **PASS** | Only non-secret ids are substituted; secrets come from `secrets.*`. |
| No automatic publishing | **PASS** | Manual `workflow_dispatch`; uploading to TestFlight is an explicit input, and nothing submits for App Store review. |
| GitHub Pages deployment preserved | **PASS** (unchanged) | Pages still serves the committed `index.*` web export from `main`. |
| Web build up to date | **N/A** | The web version is being retired. The committed `index.*` files (~95 MB) and the Pages site can be removed in a later clean-up. |

## 12. Remaining manual testing steps (device / TestFlight)

1. Install the next TestFlight build. Check the **app icon**, the launch screen, and that nothing sits under the notch or home indicator (HUD, shop title, banner).
2. Play each mode for 3+ minutes on the oldest iPhone you have. Watch for frame drops in **Coin Run**.
3. Audio: music loops; the volume sliders and mute work and stick after relaunch; a phone call, Control Center or a lock mid-run pauses the game and audio recovers; the silent switch behaves as you expect.
4. Background the app mid-run (swipe home), then return. You should see the pause menu with your run intact.
5. Force-quit during a chest spin and relaunch. The jelly should be in your collection and the coins spent.
6. Ad flows: continue, interstitial every 3rd game over, shop reward, chest reroll. Confirm the X only works after 5 s.
7. If you have an iPad (or the iPad simulator via a friend's Mac): check the centred menus and that the jelly collection and chests are tappable.
8. App Store Connect: build 12 processed; the encryption question should not appear (the plist already declares no non-exempt encryption); fill in the App Privacy section ("Data Not Collected" while there are no real ads).

## 13. Outstanding blockers before App Store submission

1. **Ads go-live**: switch to production ad units, answer App Privacy (draft in `docs/APP_STORE_PRIVACY.md`), decide on ATT, publish the AdMob GDPR message, and add a privacy policy URL.
2. **Image provenance**: document how the images were made, and confirm the tool's terms allow commercial use. (Sound licensing is done; see §9.)
3. **Store listing assets**: iPhone and iPad screenshots, description, keywords, support URL and privacy policy URL. Not in the repo.
4. **On-device verification** of everything marked NEEDS MANUAL TEST.

## 14. Release-readiness assessment

**Ready for TestFlight beta: yes.** Saves, settings, pause and backgrounding, chests and the death flow are covered by automated tests, and CI now blocks a broken build.

**Ready for App Store submission: not yet.** The character-IP risk is resolved and iPad is supported. Real ads are integrated (test units). What remains: the production-ads switch and privacy answers, image provenance, and store screenshots and listing text. None of these are code defects.

---

## Addendum: local export verification (Godot 4.7.2 official templates, Linux)

| Check | Result |
|---|---|
| iOS preset exports an Xcode project (`export_project_only=true`, matching CI) | **PASS**: export completed. The only warning was the expected ".ipa can only be built on macOS". |
| Exported `Info.plist` parses; portrait only; `ITSAppUsesNonExemptEncryption=false` | **PASS** |
| Display name / min iOS / device family in the Xcode project | "Jelly Swing Arcade" / 15.0 / `1,2` (iPhone + iPad, see §8) |
| App icon set generated | **PASS**: 16 sizes from the new mascot icon; the 1024 px icon is RGB with no alpha, as Apple requires. |
| Excluded art absent from the package | **PASS**: no references to the excluded files inside `JellySwing.pck`. |
| Package size | iOS `JellySwing.pck` **19.4 MB** (it was 48 MB). |
| Signed IPA / archive | **BLOCKED** locally (needs macOS); covered by the CI workflow. |

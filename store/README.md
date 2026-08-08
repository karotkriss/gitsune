# Store listing content (E15.5)

This directory holds the complete listing content for all three distribution channels: Google Play, the Apple App Store, and F-Droid.
It is the content to paste or wire into each store; actually creating store accounts and submitting is owned by the submission tasks (E15.1, E15.2, E15.3), not by this directory.

## Layout

- `play/` - Google Play main store listing text plus the Data safety questionnaire answers (`data-safety.md`).
- `play/graphics/` - the Play app icon (512 x 512) and feature graphic (1024 x 500), generated from the design system's brand mark; see `play/graphics/README.md` for sources and the regeneration command (the same script keeps the Android/iOS launcher icons in sync).
- `appstore/` - App Store Connect listing text plus the App Privacy answers (`app-privacy.md`).
- `fdroid/` - F-Droid listing text plus the anti-features declaration (`anti-features.md`); file names already match the fastlane layout (`title.txt`, `short_description.txt`, `full_description.txt`) that F-Droid reads from `fastlane/metadata/android/en-US/` once the submission task wires it up.
- `privacy-policy.md` - the privacy policy both Play and the App Store require a public URL for; publish it (e.g. repo file or project page) and paste the URL into both consoles.
- `screenshots/` - real app screens rendered at each store's required pixel dimensions; see below.

## Field limits the text was written against

Checked 2026-08 against the stores' current rules; re-check at submission time.

| Store | Field | Limit | File |
| --- | --- | --- | --- |
| Play | Title | 30 chars | `play/title.txt` |
| Play | Short description | 80 chars | `play/short_description.txt` |
| Play | Full description | 4000 chars | `play/full_description.txt` |
| App Store | Name | 30 chars | `appstore/name.txt` |
| App Store | Subtitle | 30 chars | `appstore/subtitle.txt` |
| App Store | Promotional text | 170 chars | `appstore/promotional_text.txt` |
| App Store | Description | 4000 chars | `appstore/description.txt` |
| App Store | Keywords | 100 chars, comma-separated | `appstore/keywords.txt` |
| F-Droid | Title | 50 chars | `fdroid/title.txt` |
| F-Droid | Summary | 80 chars | `fdroid/short_description.txt` |
| F-Droid | Description | 4000 chars | `fdroid/full_description.txt` |

Sources: [Play Console listing help](https://support.google.com/googleplay/android-developer/answer/9866151), [Apple product page reference](https://developer.apple.com/help/app-store-connect/reference/platform-version-information/), [F-Droid metadata docs](https://f-droid.org/docs/All_About_Descriptions_Graphics_and_Screenshots/).

## Screenshots

Every image is a real app screen (the same screens and fixture data the golden tests render), captured by `tool/store_screenshots_test.dart` with the app's real GitLab Sans/Mono fonts.
Regenerate the whole set with:

```sh
flutter test tool/store_screenshots_test.dart
```

| Set | Pixels | Store spec it matches |
| --- | --- | --- |
| `screenshots/play/phone/` | 1080 x 1920 | Play phone screenshots: 9:16, each side 320-3840 px, 2-8 images |
| `screenshots/appstore/iphone-6-9/` | 1290 x 2796 | App Store iPhone 6.9" display class |
| `screenshots/appstore/ipad-13/` | 2064 x 2752 | App Store iPad 13" display class (required because the iOS build targets iPad) |

F-Droid imposes no fixed screenshot dimensions and downscales for its catalog; reuse `screenshots/play/phone/` as `images/phoneScreenshots/` in the fastlane tree.

### Known gaps (for the submission tasks)

- **PNG alpha channel.** Flutter's PNG encoder always writes an (entirely opaque) alpha channel, and App Store Connect can reject screenshots with one. Before upload strip it, e.g. `magick mogrify -alpha off store/screenshots/appstore/*/*.png` (ImageMagick) or a few lines of Pillow (`uv run --with pillow python3 ...`, as `play/graphics/generate.py` does).
- **Play tablet screenshots.** Optional for listing, needed for tablet featuring; add a tablet profile to `tool/store_screenshots_test.dart` if wanted.

## Honesty constraints baked into the text

Keep these when editing the copy:

- **Notifications are near-real-time, never "instant push".** The baseline is conditional polling of the user's own instance, and the only faster paths are user-owned relays (`docs/decisions/0002-notification-architecture.md`). The copy must never promise delivery the architecture cannot make.
- **Privacy answers say "no data collected" because it is true**: no analytics or tracking dependencies exist, tokens live in platform secure storage, and the project operates no servers. If a dependency with any data collection is ever added, `play/data-safety.md` and `appstore/app-privacy.md` must change in the same PR.
- **"Independent project, not affiliated with GitLab Inc."** stays in every description.
- The F-Droid description says "free software only" about the `fdroid` flavor; the repository license itself is still TBD and must be decided (as its own ADR) before an F-Droid submission.

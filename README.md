# Warmap

Warmap is a private, local-first iOS relationship journal. It has no account
system and does not require a backend.

## MVP features

- Structured entries with time, person, place, rating, tags, and notes
- Person cards with entry count and average rating
- Search and filters by person, place, date, and rating
- Timeline and privacy-preserving map views
- App lock using Face ID, Touch ID, or device passcode
- Password-protected AES-GCM export and import

## Privacy model

- Data is stored locally with SwiftData.
- The app opts into `NSFileProtectionComplete`.
- Map coordinates are blurred by default.
- Export files are encrypted locally and never uploaded by the app.
- The app does not include analytics, ads, accounts, or network code.
- The map view may fetch map tiles from Apple's MapKit service. Record text and
  person data are not intentionally sent with those requests.

No app can guarantee secrecy on a compromised or unlocked device. iOS also
does not allow apps to fully prevent screenshots; Warmap obscures content while
screen capture is detected.

## Generate the Xcode project

On macOS, install [XcodeGen](https://github.com/yonaskolb/XcodeGen), then run:

```sh
xcodegen generate
open Warmap.xcodeproj
```

Select a development team in Xcode before running on a device.

## Build for Appetize from Windows

Appetize runs the iOS app in a browser, but it requires an iOS Simulator
`.app` bundle rather than a Windows `.exe` or an App Store `.ipa`.

The GitHub workflow at
`.github/workflows/appetize-build.yml` builds and packages the app on a macOS
runner. It runs automatically after changes reach `main`, and can also be
started manually from the repository's **Actions** tab.

After the workflow succeeds:

1. Open **Actions** → **Build Appetize iOS Package**.
2. Open the latest successful run.
3. Download the `Warmap-Appetize-...` artifact.
4. Extract the downloaded GitHub artifact once.
5. Upload the contained `Warmap-Appetize.zip` directly to
   [Appetize](https://appetize.io/upload).

Do not extract `Warmap-Appetize.zip` before uploading it to Appetize. The file
contains a universal iOS Simulator build for both `arm64` and `x86_64`.

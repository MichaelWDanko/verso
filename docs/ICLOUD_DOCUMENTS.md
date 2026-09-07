# Optional iCloud Drive documents

Verso uses ordinary UTF-8 Markdown files and SwiftUI FileDocument/DocumentGroup. Storage location is a per-document choice: local folders remain supported, and users can choose iCloud Drive in the native Open and Save panels. Verso must not move existing files into iCloud automatically.

## Current macOS support

The native panels provide access to user-selected iCloud Drive files when iCloud Drive is enabled on the Mac. Apple documents that this macOS workflow does not require the app-specific iCloud capability. The current build does not provision or access a dedicated Verso ubiquity container.

Saving a file locally is not proof it has uploaded. Cross-device propagation, downloaded-on-demand documents, offline changes, and conflicting edits have not been validated in Verso. Do not display a synced badge based only on a successful save.

## Future iOS integration

Use a SwiftUI document-based iOS app with the same Markdown content type and UTF-8 representation. Open files in place through the system document browser so the same iCloud Drive document can be used on Mac, iPhone, and iPad. Keep document serialization separate from the AppKit renderer when sharing code with iOS.

If a dedicated Verso folder is needed, provision one iCloud Documents container under the selected Apple Developer team and configure both app targets to use it. This requires the corresponding capabilities, entitlements, and provisioning profiles. A container identifier must be selected and registered before shipping; the current ad hoc build does not enable this feature.

Keep iCloud optional. Use the system document architecture for coordinated file access; do not add a polling sync service or mirror documents into a CloudKit database. Preserve conflicting versions and validate system conflict handling before distribution. Sharing with other people is a separate feature from syncing a user's own documents.

## Required validation before claiming sync support

- Save and reopen a synthetic Markdown file in iCloud Drive on a signed build.
- Open and edit that same file on a second device, then verify changes in both directions.
- Check offline edits, reconnection, eviction/download, rename, move, and deletion.
- Exercise simultaneous edits and recovery without silent loss of either version.
- Check local-only operation and unavailable or signed-out iCloud accounts.

## Apple references

- [DocumentGroup](https://developer.apple.com/documentation/SwiftUI/DocumentGroup)
- [Enable iCloud document storage](https://help.apple.com/xcode/mac/current/en.lproj/dev52452c426.html)
- [Manage iCloud containers](https://help.apple.com/xcode/mac/current/en.lproj/devcae40ccb9.html)

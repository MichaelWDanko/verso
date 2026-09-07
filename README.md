# Verso

A native Markdown reader and editor for macOS, built with SwiftUI and native TextKit editing.

Verso is an early prototype focused on a small footprint and ordinary document workflows. SwiftUI owns the document lifecycle and interface. An AppKit text view supplies editing, selection, undo, and find, with no web view, network requests, telemetry, or third-party dependencies.

## Current features

- Open `.md` and `.markdown` UTF-8 documents in individual windows.
- Read a rendered preview of headings, emphasis, inline code, fenced code, and HTTP links.
- Edit raw Markdown in a monospaced source view. New documents open in Source mode.
- Native save, autosave, find, and text editing commands.

Read mode is a preview; editing happens in Source mode. Marker-free rich text editing is not implemented. Unsupported Markdown remains visible; images, tables, nested formatting, and full CommonMark rendering are not implemented. Source is preserved independently of the reading preview. Switching views currently clears text undo history.

## Optional iCloud Drive storage

Choose iCloud Drive in the native Save or Open panel to work with documents there, or choose a local folder to keep them local. macOS manages iCloud Drive synchronization. Verso does not yet have a dedicated iCloud container or an iOS app, and cross-device sync has not been validated. See [the iCloud document design](docs/ICLOUD_DOCUMENTS.md) for the mobile integration path.

## Build and run

Requires macOS 14 or later and the Swift 6 toolchain (Xcode 16 or later).

```sh
swift test
./scripts/build-app.sh
open dist/Verso.app
```

Open `Package.swift` in Xcode to develop. Run the packaged app for document association and normal macOS app behavior. The build script creates an ad hoc signed app for local development, not a notarized distribution build.

## Efficiency

Rendering happens when entering Read mode or when its document content changes. There is no idle polling. The current renderer processes the whole document on the main thread; large-file latency and memory use need profiling before efficiency claims or release. Source mode avoids Markdown rendering while typing.

## Releases and contributions

GitHub Releases will host distributable builds once signing, notarization, accessibility, document safety, and performance have been validated. No production release is available yet. Use GitHub Issues for bugs and proposals.

Licensed under MIT. See [LICENSE](LICENSE).

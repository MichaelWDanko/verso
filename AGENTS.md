# Verso contributor guidance

Keep Verso native, local, and small. Prefer SwiftUI; use AppKit only for capabilities SwiftUI does not adequately provide. Preserve original Markdown independently of preview rendering. Do not add a browser runtime, network service, or polling loop without a concrete requirement.

Run `swift test`, `./scripts/build-app.sh`, and `git diff --check` for implementation changes. Exercise affected document workflows in the packaged macOS app. Treat measured performance, unit tests, runtime checks, and signed distribution as separate evidence.

README.md describes current behavior and limitations. GitHub Issues is the backlog. Never publish signing material or local user documents. Public releases require a verified Developer ID signed and notarized artifact.

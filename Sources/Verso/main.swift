import SwiftUI
import AppKit
import UniformTypeIdentifiers
import VersoCore

extension UTType {
    static let markdown = UTType(importedAs: "net.daringfireball.markdown", conformingTo: .plainText)
}

struct MarkdownDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.markdown, .plainText] }
    var source: String = ""
    init() {}
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let source = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadInapplicableStringEncoding)
        }
        self.source = source
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(source.utf8))
    }
}

enum EditorMode: String, CaseIterable, Identifiable {
    case read = "Read", source = "Source"
    var id: String { rawValue }
    var caption: String {
        switch self {
        case .read: "Reading preview"
        case .source: "Markdown source · UTF-8"
        }
    }
}

struct DocumentView: View {
    @Binding var document: MarkdownDocument
    @State private var mode: EditorMode = .read
    var body: some View {
        VStack(spacing: 0) {
            MarkdownTextView(source: $document.source, mode: mode)
            Divider()
            HStack {
                Text(mode.caption).font(.caption).foregroundStyle(.secondary)
                Spacer()
            }.padding(.horizontal, 16).padding(.vertical, 8)
        }
        .frame(minWidth: 460, minHeight: 320)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Document view", selection: $mode) {
                    ForEach(EditorMode.allCases) { mode in Text(mode.rawValue).tag(mode) }
                }.pickerStyle(.segmented).frame(width: 180)
            }
        }
        .onAppear { if document.source.isEmpty { mode = .source } }
    }
}

/// TextKit supplies native text editing and find while SwiftUI owns document state and layout.
struct MarkdownTextView: NSViewRepresentable {
    @Binding var source: String
    var mode: EditorMode
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        let text = NSTextView()
        text.isRichText = false
        text.allowsUndo = true
        text.usesFindBar = true
        text.isAutomaticQuoteSubstitutionEnabled = false
        text.isAutomaticDashSubstitutionEnabled = false
        text.isAutomaticTextReplacementEnabled = false
        text.isVerticallyResizable = true
        text.isHorizontallyResizable = false
        text.autoresizingMask = [.width]
        text.textContainer?.widthTracksTextView = true
        text.textContainerInset = NSSize(width: 36, height: 28)
        text.setAccessibilityLabel("Markdown document")
        text.delegate = context.coordinator
        scroll.documentView = text
        return scroll
    }
    func updateNSView(_ scroll: NSScrollView, context: Context) {
        context.coordinator.parent = self
        guard let text = scroll.documentView as? NSTextView else { return }
        let coordinator = context.coordinator
        if coordinator.mode != mode || coordinator.lastSource != source {
            if coordinator.mode != mode {
                text.undoManager?.removeAllActions()
            }
            coordinator.refresh(text)
        }
    }
    @MainActor final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownTextView
        var mode: EditorMode?
        var lastSource: String?
        var applying = false
        init(_ parent: MarkdownTextView) { self.parent = parent }
        func refresh(_ text: NSTextView) {
            guard !text.hasMarkedText() else { return }
            applying = true
            defer { applying = false }
            let selection = text.selectedRange()
            let rendered: NSAttributedString
            if parent.mode == .source {
                rendered = NSAttributedString(string: parent.source, attributes: [
                    .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular), .foregroundColor: NSColor.textColor
                ])
            } else {
                rendered = Markdown.render(parent.source)
            }
            text.isEditable = parent.mode != .read
            if text.string == rendered.string {
                text.textStorage?.beginEditing()
                rendered.enumerateAttributes(in: NSRange(location: 0, length: rendered.length)) { attributes, range, _ in
                    text.textStorage?.setAttributes(attributes, range: range)
                }
                text.textStorage?.endEditing()
            } else {
                text.textStorage?.setAttributedString(rendered)
            }
            let location = min(selection.location, rendered.length)
            text.setSelectedRange(NSRange(location: location, length: min(selection.length, rendered.length - location)))
            mode = parent.mode
            lastSource = parent.source
        }
        func textDidChange(_ notification: Notification) {
            guard !applying, let text = notification.object as? NSTextView, text.isEditable else { return }
            lastSource = text.string
            parent.source = text.string

        }
    }
}

@main
struct VersoApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            DocumentView(document: file.$document)
        }
        .defaultSize(width: 880, height: 680)
        .commands {
            CommandGroup(after: .textEditing) {
                Button("Find…") {
                    NSApp.sendAction(#selector(NSTextView.performFindPanelAction(_:)), to: nil,
                                     from: findItem())
                }.keyboardShortcut("f")
            }
        }
    }
    private func findItem() -> NSMenuItem {
        let item = NSMenuItem()
        item.tag = NSTextFinder.Action.showFindInterface.rawValue
        return item
    }
}

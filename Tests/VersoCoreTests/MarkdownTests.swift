import AppKit
import Testing
@testable import VersoCore

@Suite @MainActor struct MarkdownTests {
    @Test func styledEditingPreservesSource() {
        let source = "# Hello 🌱\r\n\n**bold** and *italic* `code`\n[site](https://example.com)\n| unknown | table |\n"
        #expect(Markdown.render(source, reading: false).string == source)
    }
    @Test func readingRemovesSupportedDelimiters() {
        #expect(Markdown.render("# Title\n**Bold** and *quiet*\n`code`", reading: true).string == "Title\nBold and quiet\ncode")
    }
    @Test func codeDoesNotInterpretMarkdown() {
        #expect(Markdown.render("```swift\n**literal**\n```\n`**also literal**`", reading: true).string == "\n**literal**\n\n**also literal**")
    }
    @Test func unicodeLinkAndUnknownSyntax() {
        #expect(Markdown.render("🌱 [Visit](https://example.com)\n![image](local.png)", reading: true).string == "🌱 Visit\n![image](local.png)")
    }
    @Test func emptyAndMalformedInput() {
        for source in ["", "**", "[broken](", "####### nope", "``"] {
            #expect(Markdown.render(source, reading: true).string == source)
        }
    }
}

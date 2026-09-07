import AppKit
import Testing
@testable import VersoCore

@Suite @MainActor struct MarkdownTests {
    @Test func readingRemovesSupportedDelimiters() {
        #expect(Markdown.render("# Title\n**Bold** and *quiet*\n`code`").string == "Title\nBold and quiet\ncode")
    }
    @Test func codeDoesNotInterpretMarkdown() {
        #expect(Markdown.render("```swift\n**literal**\n```\n`**also literal**`").string == "\n**literal**\n\n**also literal**")
    }
    @Test func unicodeLinkAndUnknownSyntax() {
        #expect(Markdown.render("🌱 [Visit](https://example.com)\n![image](local.png)").string == "🌱 Visit\n![image](local.png)")
    }
    @Test func emptyAndMalformedInput() {
        for source in ["", "**", "[broken](", "####### nope", "``"] {
            #expect(Markdown.render(source).string == source)
        }
    }
}

import AppKit

/// Presentation only. The original source is always the document's saved representation.
public enum Markdown {
    public static func render(_ source: String, reading: Bool) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        paragraph.paragraphSpacing = 6
        let result = NSMutableAttributedString(string: source, attributes: [
            .font: NSFont.systemFont(ofSize: 16), .foregroundColor: NSColor.textColor,
            .paragraphStyle: paragraph
        ])
        let ns = source as NSString
        var removals: [NSRange] = []
        var fenced = false
        var offset = 0
        for line in source.components(separatedBy: "\n") {
            let count = (line as NSString).length
            let range = NSRange(location: offset, length: count)
            defer { offset += count + 1 }
            if line.hasPrefix("```") {
                fenced.toggle()
                result.addAttributes([.font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular), .foregroundColor: NSColor.secondaryLabelColor], range: range)
                if reading { removals.append(range) }
                continue
            }
            if fenced {
                result.addAttributes([.font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular), .backgroundColor: NSColor.quaternaryLabelColor], range: range)
                continue
            }
            let heading = line.prefix(while: { $0 == "#" }).count
            if (1...6).contains(heading), line.dropFirst(heading).hasPrefix(" ") {
                result.addAttribute(.font, value: NSFont.systemFont(ofSize: CGFloat(30 - heading * 2), weight: .semibold), range: range)
                if reading { removals.append(NSRange(location: offset, length: heading + 1)) }
            }
            if line.hasPrefix("> ") {
                result.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: range)
                if reading { removals.append(NSRange(location: offset, length: 2)) }
            }
            // Deliberately bounded inline syntax. Unsupported Markdown remains visible.
            let patterns: [(String, [NSAttributedString.Key: Any], Int)] = [
                (#"`([^`\n]+)`"#, [.font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular), .backgroundColor: NSColor.quaternaryLabelColor], 1),
                (#"\*\*([^*\n]+)\*\*"#, [.font: NSFont.boldSystemFont(ofSize: 16)], 2),
                (#"(?<!\*)\*([^*\n]+)\*(?!\*)"#, [.font: NSFontManager.shared.convert(NSFont.systemFont(ofSize: 16), toHaveTrait: .italicFontMask)], 1)
            ]
            var occupied: [NSRange] = []
            for (pattern, attributes, delimiter) in patterns {
                let regex = try! NSRegularExpression(pattern: pattern)
                for match in regex.matches(in: source, range: range) {
                    guard !occupied.contains(where: { NSIntersectionRange($0, match.range).length > 0 }) else { continue }
                    occupied.append(match.range)
                    result.addAttributes(attributes, range: match.range)
                    if reading {
                        removals.append(NSRange(location: match.range.location, length: delimiter))
                        removals.append(NSRange(location: NSMaxRange(match.range) - delimiter, length: delimiter))
                    }
                }
            }
            let links = try! NSRegularExpression(pattern: #"(?<!!)\[([^\]\n]+)\]\((https?://[^\s)]+)\)"#)
            for match in links.matches(in: source, range: range) {
                guard !occupied.contains(where: { NSIntersectionRange($0, match.range).length > 0 }) else { continue }
                let label = match.range(at: 1)
                if let url = URL(string: ns.substring(with: match.range(at: 2))) {
                    result.addAttribute(.link, value: url, range: label)
                }
                if reading {
                    removals.append(NSRange(location: match.range.location, length: 1))
                    removals.append(NSRange(location: NSMaxRange(label), length: NSMaxRange(match.range) - NSMaxRange(label)))
                }
            }
        }
        for range in removals.sorted(by: { $0.location > $1.location }) {
            result.deleteCharacters(in: range)
        }
        return result
    }
}

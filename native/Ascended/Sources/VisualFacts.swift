import SwiftUI

struct VisualFact: Decodable, Identifiable {
    let id: String
    let name: String
    let aliases: [String]
    let asset: String?
    let symbol: String
    let category: String
    static let all = (try? ArkMap.load([VisualFact].self, name: "visual-facts")) ?? []
}
struct FactMatch: Identifiable {
    let fact: VisualFact
    let quantity: String?
    let metricValue: String?
    init(fact: VisualFact, quantity: String?, metricValue: String? = nil) { self.fact = fact; self.quantity = quantity; self.metricValue = metricValue }
    var id: String { fact.id }
}
enum VisualFacts {
    private static let patterns: [(VisualFact, [NSRegularExpression])] = VisualFact.all.map { fact in
        (fact, fact.aliases.sorted { $0.count > $1.count }.compactMap { alias in
            try? NSRegularExpression(pattern: "(?<![\\p{L}\\p{N}])" + NSRegularExpression.escapedPattern(for: alias) + "(?![\\p{L}\\p{N}])", options: .caseInsensitive)
        })
    }
    static func items(_ names: [String]) -> [FactMatch] {
        names.map { name in
            matches(name).first ?? FactMatch(fact: VisualFact(id: name, name: name, aliases: [name], asset: nil, symbol: "shippingbox.fill", category: "item"), quantity: nil)
        }
    }
    static func matches(_ text: String) -> [FactMatch] {
        let source = text as NSString
        var candidates: [(VisualFact, NSRange)] = []
        for (fact, expressions) in patterns {
            for regex in expressions {
                if let found = regex.firstMatch(in: text, range: NSRange(location: 0, length: source.length)) {
                    candidates.append((fact, found.range)); break
                }
            }
        }
        candidates.sort { $0.1.length == $1.1.length ? $0.0.id < $1.0.id : $0.1.length > $1.1.length }
        var chosen: [(VisualFact, NSRange)] = []
        for candidate in candidates where !chosen.contains(where: { NSIntersectionRange($0.1, candidate.1).length > 0 }) { chosen.append(candidate) }
        return chosen.sorted { $0.1.location < $1.1.location }.map { fact, range in
            let before = source.substring(to: range.location)
            let after = source.substring(from: NSMaxRange(range))
            let leading = before.range(of: "[0-9]+(?:[–-][0-9]+)?\\s*(?:×|x)?\\s*$", options: .regularExpression)
            let trailing = after.range(of: "^\\s*[×x]\\s*[0-9]+(?:[–-][0-9]+)?", options: .regularExpression)
            let words = before.range(of: "(?i)(một|hai)\\s*$", options: .regularExpression).map { String(before[$0]).trimmingCharacters(in: .whitespaces).lowercased() }
            let number = leading.map { String(before[$0]) } ?? trailing.map { String(after[$0]) } ?? words.map { $0 == "hai" ? "2" : "1" }
            let quantity = number?.filter { $0.isNumber || $0 == "–" || $0 == "-" }
            if ["hazard-hp", "hazard-melee", "hazard-level", "hazard-stamina"].contains(fact.id) {
                let value = after.range(of: "^\\s*(?:nền\\s*)?[0-9][0-9.,]*(?:k|%)?", options: .regularExpression).map { String(after[$0]).replacingOccurrences(of: "nền", with: "").trimmingCharacters(in: .whitespaces) }
                return FactMatch(fact: fact, quantity: nil, metricValue: value)
            }
            return FactMatch(fact: fact, quantity: quantity?.isEmpty == false ? quantity : nil)
        }
    }
    static func symbol(for label: String) -> String {
        let value = label.lowercased()
        if value.contains("health") || value.contains("hp") || value.contains("máu") { return "heart.fill" }
        if value.contains("stamina") { return "bolt.heart.fill" }
        if value.contains("damage") || value.contains("melee") { return "bolt.fill" }
        if value.contains("armor") || value.contains("saddle") { return "shield.fill" }
        if value.contains("oxygen") { return "lungs.fill" }
        if value.contains("food") || value.contains("ăn") { return "fork.knife" }
        if value.contains("weight") { return "scalemass.fill" }
        if value.contains("speed") { return "hare.fill" }
        if value.contains("torpor") { return "zzz" }
        if value.contains("tame") || value.contains("phương pháp") { return "hand.raised.fill" }
        if value.contains("level") { return "arrow.up.circle.fill" }
        return "square.grid.2x2.fill"
    }
}

struct FactPicture: View {
    let fact: VisualFact
    var body: some View {
        if let asset = fact.asset {
            if fact.category == "creature" || fact.category == "boss" { CreatureCutout(asset: asset) }
            else { Image(asset).resizable().scaledToFit() }
        } else { Image(systemName: fact.symbol).resizable().scaledToFit().padding(12).foregroundStyle(fact.symbol == "flame.fill" ? .orange : .cyan) }
    }
}
struct FactTile: View {
    let match: FactMatch
    private var creature: Bool { match.fact.category == "creature" || match.fact.category == "boss" }
    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                FactPicture(fact: match.fact).frame(width: 72, height: 64)
                if !creature {
                    if let value = match.metricValue { Text(value).font(.headline.bold()).padding(5).background(.black.opacity(0.8), in: Capsule()) }
                    else if let quantity = match.quantity { Text("×" + quantity).font(.headline.bold()).padding(5).background(.black.opacity(0.8), in: Capsule()) }
                }
            }
            if creature, let quantity = match.quantity { Text("×" + quantity).font(.caption.bold()).monospacedDigit() }
            Text(match.fact.name).font(.caption).lineLimit(2).multilineTextAlignment(.center)
        }.frame(width: 108, height: creature && match.quantity != nil ? 132 : 110).background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))
            .accessibilityElement(children: .combine).accessibilityIdentifier("fact-" + match.id)
    }
}
struct FactGrid: View {
    let matches: [FactMatch]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 108, maximum: 140), spacing: 10)], alignment: .leading, spacing: 10) {
            ForEach(matches) { FactTile(match: $0) }
        }
    }
}
struct VisualBrief: View {
    let text: String
    var symbol = "info.circle"
    var body: some View {
        let matches = VisualFacts.matches(text)
        VStack(alignment: .leading, spacing: 10) {
            if !matches.isEmpty {
                FactGrid(matches: matches)
                if text.localizedCaseInsensitiveContains("/ con") {
                    HStack(spacing: 5) { Text("/"); Image(systemName: "pawprint.fill"); Text("1") }
                        .font(.caption.bold()).foregroundStyle(.cyan).accessibilityElement(children: .ignore).accessibilityLabel("Số lượng cho mỗi Dino").accessibilityIdentifier("unit-per-dino")
                }
                if let condition = text.components(separatedBy: ". ").first(where: { sentence in
                    ["không", "cần", "nếu", "tùy", "giới hạn"].contains { sentence.localizedCaseInsensitiveContains($0) }
                }), condition.count > 25 {
                    Label(condition, systemImage: "exclamationmark.circle").font(.caption).foregroundStyle(.orange).fixedSize(horizontal: false, vertical: true)
                }
            }
            else { Label(String(text.split(separator: ".").first ?? Substring(text)), systemImage: symbol).font(.subheadline).lineLimit(2) }

        }
    }
}

struct GPSBadge: View {
    let coordinates: String
    private var numbers: [String] {
        guard let regex = try? NSRegularExpression(pattern: "[0-9]+\\.[0-9]+") else { return [] }
        let source = coordinates as NSString
        return regex.matches(in: coordinates, range: NSRange(location: 0, length: source.length)).map { source.substring(with: $0.range) }
    }
    var body: some View {
        HStack(spacing: 8) {
            if numbers.count == 2 {
                Image(systemName: "arrow.up.arrow.down").font(.caption)
                Text(numbers[0]).monospacedDigit()
                Divider().frame(height: 16)
                Image(systemName: "arrow.left.arrow.right").font(.caption)
                Text(numbers[1]).monospacedDigit()
            } else { Label(coordinates, systemImage: "water.waves") }
        }.font(.subheadline.weight(.semibold)).foregroundStyle(.cyan)
            .padding(.horizontal, 10).padding(.vertical, 7)
            .background(.cyan.opacity(0.08), in: RoundedRectangle(cornerRadius: 9))
            .fixedSize().accessibilityElement(children: .ignore)
            .accessibilityLabel(numbers.count == 2 ? "Vĩ độ \(numbers[0]), kinh độ \(numbers[1])" : coordinates)
            .accessibilityIdentifier("gps-" + numbers.joined(separator: "-"))
    }
}

struct VisualKitGroup: View {
    let text: String
    let token: String
    let checked: Binding<Bool>
    var body: some View {
        let matches = VisualFacts.matches(text).filter { $0.fact.category == "item" }
        if matches.isEmpty {
            Text(text).font(.caption).foregroundStyle(.secondary)
        } else {
            FactGrid(matches: matches.map { FactMatch(fact: $0.fact, quantity: nil) })
        }
    }
}

struct RoutePreparation: View {
    let items: [String]
    private var facts: [FactMatch] {
        var seen = Set<String>()
        return items.flatMap { VisualFacts.matches($0) }.filter {
            $0.fact.category == "item" && seen.insert($0.id).inserted
        }.map { FactMatch(fact: $0.fact, quantity: nil) }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chuẩn bị cho tuyến").font(.headline)
            FactGrid(matches: facts)
        }.cardStyle()
    }
}

struct VisualTeam: View {
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(text.components(separatedBy: "; hoặc ").enumerated()), id: \.offset) { index, option in
                if index > 0 { Text("Hoặc").font(.caption).foregroundStyle(.secondary) }
                let prepared = option.replacingOccurrences(of: "\\+\\s*(Yuty|Daeodon|pig)(?![\\p{L}])", with: "+ 1 $1", options: .regularExpression)
                VisualBrief(text: prepared)
            }
        }
    }
}

import SwiftUI

struct BuildCraftCatalogue:Decodable {
    let items:[BuildCraftItem];let processes:[BuildProcess]
    static let shared=(try? ArkMap.load(Self.self,name:"build-crafting")) ?? Self(items:[],processes:[])
    func item(_ id:String)->BuildCraftItem? { items.first {$0.id==id} }
}
struct BuildCraftItem:Decodable,Identifiable {
    let id,name,category:String;let asset:String?;let ingredients:[String:Int];let stations:[String];let recipeVerified:Bool
}
struct BuildProcess:Decodable,Identifiable {
    let name:String;let output:Int;let ingredients:[String:Int];let station:String
    var id:String {name}
}
struct BuildCraftStep:Identifiable {let name:String;var batches:Int;let recipe:BuildProcess;var id:String {name}}
enum BuildBill {
    static func ingredient(_ id:String)->[String:Int]? {
        if let item=BuildCraftCatalogue.shared.item(id) {return item.recipeVerified ? item.ingredients:nil}
        return StoneKit.shared.models.first {$0.id==id && !($0.ingredients.isEmpty)}?.ingredients
    }
    static func direct(_ pieces:[StonePlacement])->[String:Int] {
        var sum:[String:Int]=[:];for p in pieces {for (n,v) in ingredient(p.kind) ?? [:] {sum[n,default:0]+=v}};return sum
    }
    static func expand(_ direct:[String:Int])->(raw:[String:Int],steps:[BuildCraftStep]) {
        // Expand the deepest dependencies first so shared ingredients are combined before batch rounding.
        let recipes=BuildCraftCatalogue.shared.processes
        func depth(_ name:String,_ seen:Set<String>=[])->Int {
            guard !seen.contains(name),let r=recipes.first(where:{$0.name==name}) else {return 0}
            return 1+(r.ingredients.keys.map {depth($0,seen.union([name]))}.max() ?? 0)
        }
        var pending=direct;var raw:[String:Int]=[:];var steps:[String:BuildCraftStep]=[:]
        for _ in 0..<128 {
            guard let name=pending.keys.filter({depth($0)>0}).max(by:{depth($0)<depth($1)}),let recipe=recipes.first(where:{$0.name==name}),let count=pending.removeValue(forKey:name) else {break}
            let batches=(count+recipe.output-1)/recipe.output
            steps[name]=BuildCraftStep(name:name,batches:batches,recipe:recipe)
            for (key,n) in recipe.ingredients {pending[key,default:0]+=n*batches}
        }
        raw=pending
        return (raw,steps.values.sorted {$0.name<$1.name})
    }
}
struct BuildBillView:View {
    let pieces:[StonePlacement]
    @Environment(\.dismiss) private var dismiss
    private var counts:[String:Int] {Dictionary(pieces.map {($0.kind,1)},uniquingKeysWith:+)}
    var body:some View {
        let direct=BuildBill.direct(pieces);let expanded=BuildBill.expand(direct)
        NavigationStack {
            ScrollView {
                VStack(alignment:.leading,spacing:18) {
                    ForEach(counts.keys.sorted(),id:\.self) { id in
                        let n=counts[id] ?? 0;let model=StoneKit.shared.models.first {$0.id==id};let item=BuildCraftCatalogue.shared.item(id)
                        VStack(alignment:.leading,spacing:8) {
                            HStack {
                                if let asset=item?.asset ?? model?.asset {Image(asset).resizable().scaledToFit().frame(width:48,height:42)}
                                Text(item?.name ?? model?.name ?? id).font(.headline);Spacer();Text("×\(n)").monospacedDigit()
                            }
                            if let recipe=BuildBill.ingredient(id) {
                                materialStrip(recipe.mapValues {$0*n})
                                Label(item?.stations.first ?? "Inventory",systemImage:"hammer.fill").font(.caption).foregroundStyle(.secondary)
                            } else {Text("Recipe not verified").font(.caption).foregroundStyle(.orange)}
                        }.padding(12).background(Color.white.opacity(0.05),in:RoundedRectangle(cornerRadius:10)).accessibilityElement(children:.contain).accessibilityIdentifier("bill-piece-"+id)
                    }
                    Text("Crafting requirements").font(.headline)
                    materialStrip(direct,ids:true)
                    if !expanded.steps.isEmpty {
                        Text("Craft ingredients").font(.headline)
                        ForEach(expanded.steps) {step in
                            HStack(alignment:.top) {
                                VStack(alignment:.leading) {Text(step.name+" ×\(step.batches*step.recipe.output)").font(.headline);Text(step.recipe.station).font(.caption).foregroundStyle(.cyan)}
                                Spacer();materialStrip(step.recipe.ingredients.mapValues {$0*step.batches})
                            }.padding(12).background(Color.white.opacity(0.05),in:RoundedRectangle(cornerRadius:10)).accessibilityElement(children:.contain).accessibilityIdentifier("craft-step-"+step.name)
                        }
                        Text("Raw materials").font(.headline);materialStrip(expanded.raw)
                    }
                    Text("Standard engrams. Fuel, missing crafting stations and blueprint multipliers are excluded. Alternative ingredients use one equivalent option.").font(.caption).foregroundStyle(.secondary)
                    if pieces.contains(where:{BuildBill.ingredient($0.kind)==nil}) {Text("Totals exclude items with unverified recipes.").foregroundStyle(.orange).font(.caption)}
                }.padding(20)
            }.navigationTitle("Materials").navigationBarTitleDisplayMode(.inline).toolbar {Button("Done") {dismiss()}}
        }
    }
    private func materialStrip(_ amounts:[String:Int],ids:Bool=false)->some View {
        ScrollView(.horizontal) {HStack(spacing:8) {
            ForEach(amounts.keys.sorted(),id:\.self) {name in
                VStack(spacing:4) {
                    FactTile(match:VisualFacts.items([name])[0]).frame(width:100)
                    Text("×\(amounts[name] ?? 0)").monospacedDigit().font(.headline).accessibilityIdentifier(ids ? "builder-material-"+name:"ingredient-"+name).accessibilityValue(String(amounts[name] ?? 0))
                }
            }
        }}
    }
}

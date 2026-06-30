import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), mantra: "The baseline is steady.")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), mantra: "The baseline is steady.")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Read the mantra text written by the home_widget Flutter plugin
        let userDefaults = UserDefaults(suiteName: "group.com.stira.app")
        let mantra = userDefaults?.string(forKey: "stira_mantra") ?? "The baseline is steady."
        
        // This timeline just refreshes occasionally or when forced by Flutter
        let entry = SimpleEntry(date: Date(), mantra: mantra)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let mantra: String
}

struct StiraWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(red: 10/255, green: 10/255, blue: 14/255)
            VStack(alignment: .leading) {
                Text("Stira")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 142/255, green: 132/255, blue: 255/255).opacity(0.6))
                    .padding(.bottom, 4)
                
                Text(entry.mantra)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 220/255, green: 220/255, blue: 230/255))
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
        }
    }
}

@main
struct StiraWidget: Widget {
    let kind: String = "StiraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StiraWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Stira Sanctuary")
        .description("A quiet reminder of your baseline.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

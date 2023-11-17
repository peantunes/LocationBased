//
//  LastLocationWidget.swift
//  LastLocationWidget
//
//  Created by Pedro Antunes on 14/11/2023.
//

import WidgetKit
import SwiftUI
import MapKit

struct Provider: TimelineProvider {
    let baseCoordinates = LocationRegion.Coordinates(latitude: 51.13850488543663, longitude: 0.8320904067583412)
    func placeholder(in context: Context) -> MapEntry {
//        SimpleEntry(date: Date(), emoji: "😀")
        MapEntry(date: Date(), title: "Simple place", lastTimeEntry: Date()-3600, uiImage: UIImage(systemName: "map")!)
    }

    func getSnapshot(in context: Context, completion: @escaping (MapEntry) -> ()) {
        let entry = MapEntry(date: Date(), title: "Simple place", lastTimeEntry: Date()-3600, uiImage: UIImage(systemName: "map")!)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [MapEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let kvo = KeyValueStoreProvider()
        guard let data = kvo.data(forKey: "currentLocation"),
              let locationRegion = try? JSONDecoder().decode(LocationRegion.self, from: data) else {
            let timeline = Timeline(entries: [MapEntry(date: Date(), title: "Simple place", lastTimeEntry: Date()-3600, uiImage: UIImage(systemName: "map")!)], policy: .atEnd)
            completion(timeline)
            return
        }
        
        let mapSnapshotter = makeSnapshotter(for: locationRegion.coordinates,
                                             with: context.displaySize)
        
        mapSnapshotter.start { (snapshot, error) in
            guard let snapshot = snapshot else {
                return
            }
            
            let entry = MapEntry(date: Date(), title: locationRegion.name, lastTimeEntry: locationRegion.lastEvent ?? .now, uiImage: snapshot.image)
            entries.append(entry)
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
        

    }
    
    private func makeSnapshotter(for coordinates: LocationRegion.Coordinates, with size: CGSize)
    -> MKMapSnapshotter {
        let options = MKMapSnapshotter.Options()
        options.region = .init(center: .init(latitude: coordinates.latitude, longitude: coordinates.longitude), span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001))
        options.size = size
        
        // Force light mode snapshot
        options.traitCollection = UITraitCollection(traitsFrom: [
            options.traitCollection,
            UITraitCollection(userInterfaceStyle: .light)
        ])
        options.showsBuildings = true

        return MKMapSnapshotter(options: options)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct MapEntry: TimelineEntry {
    let date: Date
    let title: String
    let lastTimeEntry: Date
    let uiImage: UIImage
}

struct LastLocationWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack(alignment: .center) {
            Image(uiImage: entry.uiImage)
            Image(systemName: "mappin")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 30)
                .offset(y: -15)
                .foregroundStyle(Color.red)
            VStack {
                Spacer()
                Text(entry.title)
                    .bold()
                    .shadow(radius: 3)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct LastLocationWidget: Widget {
    let kind: String = "LastLocationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LastLocationWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LastLocationWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    LastLocationWidget()
} timeline: {
    MapEntry(date: Date(), title: "Simple Entry", lastTimeEntry: .now - 3850, uiImage: UIImage(systemName: "map")!)
}

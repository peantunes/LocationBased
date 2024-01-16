//
//  MonitorControlView.swift
//  LocationBased
//
//  Created by Pedro Antunes on 08/11/2023.
//

import SwiftUI

struct Location: Identifiable {
    let id: String
    let coordinates: (latitude: Double, longitude: Double)
    let name: String
    let address: String?
}

struct SearchResult: Identifiable {
    let id = UUID().uuidString
    let locations: [Location]
}

struct MonitorControlContentView: View {
    @ObservedObject private var monitorObserver: MonitorContentObserver
    @FocusState private var isFocused: Bool
    
    init(monitorObserver: MonitorContentObserver = MonitorContentObserver(engine: Engine.shared)) {
        self.monitorObserver = monitorObserver
    }
    
    var body: some View {
        VStack {
            Text("Current monitorred areas (\(monitorObserver.places.count))")
            List {
                ForEach(monitorObserver.places) { item in
                    MonitoredRegionCell(location: item)
                }
                .onDelete(perform: monitorObserver.delete(at:))
                
            }
            .refreshable {
                monitorObserver.refreshResults()
            }
            HStack {
                Text("Notifications (\(monitorObserver.localNotifications.count))")
                Spacer()
                Button {
                    monitorObserver.showDeliveredNotifications = true
                } label: {
                    Text("Delivered")
                }
            }
            List {
                ForEach(monitorObserver.localNotifications) { notif in
                    MonitoredRegionCell(location: LocationRegion(name: notif.title, coordinates: notif.region?.coordinates ?? .init(latitude: 0, longitude: 0), radius: notif.region?.radius ?? 0, lastEvent: nil, eventState: .unknown))
                }
                .onDelete(perform: monitorObserver.removeNotification(at:))
            }
            .refreshable {
                monitorObserver.refreshResults()
            }
            
            VStack {
                Text("Radius: \(monitorObserver.distance, format: .number)")
                Slider(value: $monitorObserver.distance, in: 10...monitorObserver.maximumDistance, step: 1)
                HStack {
                    TextField("places", text: $monitorObserver.searchText)
                        .focused($isFocused)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(search)
                    Button("search", action: search)
                    .buttonStyle(.bordered)
                }
            }
        }
        .sheet(item: $monitorObserver.searchResult, content: { results in
            List {
                ForEach(results.locations) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text(item.address ?? "-")
                                .foregroundStyle(Color.secondary)
                        }
                        Spacer()
                        Button("Add") {
                            monitorObserver.addPlace(place: item)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        })
        .sheet(isPresented: $monitorObserver.showDeliveredNotifications, content: {
            List {
                ForEach(monitorObserver.deliveredNotification) { notif in
                    MonitoredRegionCell(location: LocationRegion(name: notif.title, coordinates: notif.region?.coordinates ?? .init(latitude: 0, longitude: 0), radius: notif.region?.radius ?? 0, lastEvent: nil, eventState: .unknown))
                }
            }
        })
        .padding()
        .task {
            monitorObserver.askPermissions()
        }
        .onAppear {
            monitorObserver.refreshResults()
        }
    }
    
    private func search() {
        monitorObserver.searchPlaces(text: monitorObserver.searchText)
        isFocused = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    MonitorControlContentView()
}

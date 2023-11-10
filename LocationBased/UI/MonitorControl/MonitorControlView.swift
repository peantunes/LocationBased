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
    @State private var searchText = ""
    
    init(monitorObserver: MonitorContentObserver = MonitorContentObserver(engine: Engine.shared)) {
        self.monitorObserver = monitorObserver
    }
    
    var body: some View {
        VStack {
            Text("Current monitorred areas")
            List {
                ForEach(monitorObserver.places) { item in
                    MonitoredRegionCell(location: item)
                }
                .onDelete(perform: monitorObserver.delete(at:))
                
            }
            .refreshable {
                monitorObserver.refreshResults()
            }
            
            VStack {
                HStack {
                    TextField("places", text: $monitorObserver.searchText)
                        .textFieldStyle(.roundedBorder)
                    Button("search") {
                        monitorObserver.searchPlaces(text: searchText)
                    }
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
        .padding()
        .task {
            monitorObserver.askPermissions()
        }
        .onAppear {
            monitorObserver.refreshResults()
        }
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

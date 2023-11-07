//
//  ContentView.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import SwiftUI
import CoreLocation

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

struct ContentView: View {
    @StateObject private var engine = Engine.shared
    @State var monitoredPlaces: [LocationRegion] = []
    @State var search: String = ""
    @State var searchResult: SearchResult?
    
    let home = LocationRegion.Coordinates(latitude: 51.13850488543663, longitude: 0.8320904067583412)
    let station = LocationRegion.Coordinates(latitude: 51.14382014251429, longitude: 0.8763060637741393)
    
    var body: some View {
        VStack {
            Text("Current monitorred areas")
            List(monitoredPlaces, id:\.name) { item in
                VStack(alignment: .leading) {
                    Text(item.name)
                    Text("\(item.coordinates.latitude), \(item.coordinates.longitude)")
                        .foregroundStyle(Color.secondary)
                }
            }
            .refreshable {
                monitoredPlaces = engine.locationManagerProvider.currentMonitored()
            }
            VStack {
                HStack {
                    TextField("places", text: $search)
                    Button("search") {
                        engine.placeSearchProvider.searchBy(query: search, regionRestriction: SearchRegionRestriction.all) { result in
                            switch result {
                            case .success(let locations):
                                let searchLocations = locations.places.map(Location.init)
                                searchResult = SearchResult(locations: searchLocations)
                            case .failure:
                                print("no results")
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .sheet(item: $searchResult, content: { results in
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
                            Engine.shared.locationBasedService.monitorLocation(latitude: item.coordinates.latitude, longitude: item.coordinates.longitude, name: item.name)
                            searchResult = nil
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        })
        .padding()
        .task {
            
            Engine.shared.locationManagerProvider.requestAccess()
            
            Engine.shared.notificationProvider.requestPermission { result in
            }
            monitoredPlaces = engine.locationManagerProvider.currentMonitored()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Location {
    init(_ place: PlaceSearchLocation) {
        self.init(id: UUID().uuidString,
                  coordinates: (latitude: place.coordinate.latitude, longitude: place.coordinate.longitude),
                  name: place.name ?? "<no name>",
                  address: place.address)
    }
}

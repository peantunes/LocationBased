//
//  ContentView.swift
//  LocationBased
//
//  Created by Pedro Antunes on 06/11/2023.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    let home = LocationRegion.Coordinates(latitude: 51.13850488543663, longitude: 0.8320904067583412)
    let station = LocationRegion.Coordinates(latitude: 51.14382014251429, longitude: 0.8763060637741393)
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button {
                Engine.shared.notificationProvider.sendNotification(with: .init(title: "Going to background", body: "App now is dismissed"))
            } label: {
                Text("Send notification")
            }
        }
        .padding()
        .task {
            Engine.shared.locationManagerProvider.requestAccess()
            
            Engine.shared.notificationProvider.requestPermission { result in
                switch result {
                case .success:
                    localNotification()
                    
                    
                    Engine.shared.locationBasedService.monitorLocation(latitude: home.latitude, longitude: home.longitude, name: "Home sweet home")
                    Engine.shared.locationBasedService.monitorLocation(latitude: station.latitude, longitude: station.longitude, name: "Ashford International Station")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func localNotification() {
        Engine.shared.notificationProvider.sendNotification(
            with: .init(
                title: "Arrived Home",
                body: "You are home",
                region: .init(name: "Home 1",
                              coordinates: home,
                              radius: Engine.shared.locationManagerProvider.maximumDistance)))
        
        Engine.shared.notificationProvider.sendNotification(
            with: .init(
                title: "Simple AFK",
                body: "We arrived to the station",
                region: .init(name: "AFK 1",
                              coordinates: station,
                              radius: Engine.shared.locationManagerProvider.maximumDistance)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

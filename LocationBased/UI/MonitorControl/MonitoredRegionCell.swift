//
//  MonitoredRegionCell.swift
//  LocationBased
//
//  Created by Pedro Antunes on 08/11/2023.
//

import SwiftUI

struct MonitoredRegionCell: View {
    let location: LocationRegion
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(location.name)
                Spacer()
                Text(location.eventState.rawValue)
            }
            Text("\(location.coordinates.latitude), \(location.coordinates.longitude) - \(Int(location.radius))m")
                .foregroundStyle(Color.secondary)
            if let time = location.lastEvent {
                Text("\(time..<Date.now, format: .timeDuration)")
                    .foregroundStyle(Color.red)
            }
        }
    }
}

#Preview {
    MonitoredRegionCell(location: .init(name: "Simple", coordinates: .init(latitude: 0.0, longitude: 0.0), radius: 1.0, lastEvent: Date().addingTimeInterval(-3600), eventState: .unknown))
}

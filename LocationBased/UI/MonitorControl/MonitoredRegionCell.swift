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
            Text(location.name)
            Text("\(location.coordinates.latitude), \(location.coordinates.longitude)")
                .foregroundStyle(Color.secondary)
        }
    }
}

#Preview {
    MonitoredRegionCell(location: .init(name: "Simple", coordinates: .init(latitude: 0.0, longitude: 0.0), radius: 1.0, lastEvent: Date().addingTimeInterval(-3600)))
}

//
//  ListOfActivitiesView.swift
//  LocationBased
//
//  Created by Pedro Antunes on 23/05/2024.
//

import SwiftUI
import Charts

struct ListOfActivitiesView: View {
    @State private var activities: [ActivityInfo] = []
    @State private var startDate: Date = .init(timeIntervalSinceNow: -3600)
    @State private var endDate: Date = .now
    let engine: HasUserActivityProvider
    
    var body: some View {
        VStack {
            Chart(activities, id: \.startDate) { activity in
                PointMark(x: .value("time", activity.startDate), y: .value("Type", activity.type.name))
                    .foregroundStyle(by: .value("Type Color", activity.type.name))
            }
            .padding()
            List {
                ForEach(activities, id: \.startDate) { activity in
                    HStack {
                        Text(activity.type.image)
                        VStack {
                            HStack {
                                Text(activity.startDate.formatted(date: .abbreviated, time: .shortened))
                                Text(" - ")
                                Text(activity.confidence.rawValue)
                                
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            
                            Text(activity.type.name)
                        }
                        Spacer()
                    }
                }
            }
            HStack {
                
            }
        }
        .onAppear {
            loadContent()
        }
        VStack {
            DatePicker("From:", selection: $startDate)
            DatePicker("To:", selection: $endDate)
        }
        .padding()
        .onChange(of: startDate) { _ in
            loadContent()
        }
        .onChange(of: endDate) { _ in
            loadContent()
        }
    }
    
    func loadContent() {
        Task {
            activities = (try? await engine.userActivityProvider.historicData(from: startDate, to: endDate)) ?? []//?.filter { $0.type != .unknown } ?? []
        }
    }
}

extension ActivityInfo.ActivityType {
    var name: String {
        switch self {
        case .walking:
            return "Walking"
        case .automotive:
            return "Automotive"
        case .stationary:
            return "Stationary"
        case .cycling:
            return "Cycling"
        case .running:
            return "Running"
        case .unknown:
            return "Unknown"
        }
    }
    
    var value: Int {
        switch self {
        case .walking:
            return 2
        case .automotive:
            return 5
        case .stationary:
            return 1
        case .cycling:
            return 4
        case .running:
            return 3
        case .unknown:
            return 0
        }
    }
    
    var color: String {
        switch self {
        case .walking:
            return "Blue"
        case .automotive:
            return "Green"
        case .stationary:
            return "Red"
        case .cycling:
            return "Orange"
        case .running:
            return "Purple"
        case .unknown:
            return "Gray"
        }
    }
}

//#Preview {
//    ListOfActivitiesView()
//}

//
//  MapKitPlaceSearchProvider.swift
//  LocationBased
//
//  Created by Pedro Antunes on 07/11/2023.
//

import Foundation
import MapKit

public final class MapKitPlaceSearchProvider: PlaceSearchProvider {
    private var localSearch: MKLocalSearch?

    public func searchBy(query: String, regionRestriction: SearchRegionRestriction, completion: @escaping (Result<PlaceSearchResult, PlaceSearchError>) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
//        searchRequest.region = MKCoordinateRegion(regionRestriction)

        localSearch?.cancel() // cancel the previous call if it exists
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { (response, error) in
            guard error == nil else {
                completion(.failure(.unknown))
                //TODO: Log into new relic
                return
            }
            let placeSearchLocations = response?.mapItems.map(PlaceSearchLocation.init) ?? []
            guard !placeSearchLocations.isEmpty else {
                completion(.failure(.searchNotFound))
                return
            }

            completion(.success(PlaceSearchResult(queryString: query, places: placeSearchLocations)))
        }
    }
}

private extension PlaceSearchLocation {

    init(_ mapItem: MKMapItem) {
        self.init(name: mapItem.name,
                  address: mapItem.placemark.title,
                  coordinate: Coordinate(latitude: Double(mapItem.placemark.coordinate.latitude), longitude: Double(mapItem.placemark.coordinate.longitude)),
                  category: mapItem.pointOfInterestCategory?.category ?? .unknown)
    }
}

private extension MKPointOfInterestCategory {
    var category: PlaceSearchLocation.Category {
        switch self {
        case .airport:
            return .airport
        case .amusementPark:
            return .amusementPark
        case .aquarium:
            return .aquarium
        case .atm:
            return .atm
        case .bakery:
            return .bakery
        case .bank:
            return .bank
        case .beach:
            return .beach
        case .brewery:
            return .brewery
        case .cafe:
            return .cafe
        case .campground:
            return .campground
        case .carRental:
            return .carRental
        case .evCharger:
            return .evCharger
        case .fireStation:
            return .fireStation
        case .fitnessCenter:
            return .fitnessCenter
        case .foodMarket:
            return .foodMarket
        case .gasStation:
            return .gasStation
        case .hospital:
            return .hospital
        case .hotel:
            return .hotel
        case .laundry:
            return .laundry
        case .library:
            return .library
        case .marina:
            return .marina
        case .movieTheater:
            return .movieTheater
        case .museum:
            return .museum
        case .nationalPark:
            return .nationalPark
        case .nightlife:
            return .nightlife
        case .park:
            return .park
        case .parking:
            return .parking
        case .pharmacy:
            return .pharmacy
        case .police:
            return .police
        case .postOffice:
            return .postOffice
        case .publicTransport:
            return .publicTransport
        case .restroom:
            return .restroom
        case .restaurant:
            return .restaurant
        case .store:
            return .store
        case .school:
            return .school
        case .stadium:
            return .stadium
        case .theater:
            return .theater
        case .university:
            return .university
        case .winery:
            return .winery
        case .zoo:
            return .zoo
        default:
            return .unknown
        }
    }
}

private extension MKCoordinateRegion {

    init(_ regionRestriction: SearchRegionRestriction) {
        switch regionRestriction {
        case .coordinates(let latitude, let longitude, let latitudeDelta, let longitudeDelta):
            self.init(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(latitudeDelta), longitudeDelta: CLLocationDegrees(longitudeDelta)))
        case .all:
            self.init(MKMapRect.world)
        case .none:
            self.init()
        }
    }
}

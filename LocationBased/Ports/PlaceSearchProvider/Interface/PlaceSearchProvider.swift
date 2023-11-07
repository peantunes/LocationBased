import Foundation

public protocol HasPlaceSearchProvider {
    var placeSearchProvider: PlaceSearchProvider { get }
}

public protocol PlaceSearchProvider {
    func searchBy(query: String, regionRestriction: SearchRegionRestriction, completion: @escaping (Result<PlaceSearchResult, PlaceSearchError>) -> Void)
}

public enum SearchRegionRestriction {
    case coordinates(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double)
    case all
    case none
}

public struct PlaceSearchResult {
    public let queryString: String
    public let places: [PlaceSearchLocation]

    public init(queryString: String, places: [PlaceSearchLocation]) {
        self.queryString = queryString
        self.places = places
    }
}

public struct PlaceSearchLocation {

    public enum Category {
        case airport
        case amusementPark
        case aquarium
        case atm
        case bakery
        case bank
        case beach
        case brewery
        case cafe
        case campground
        case carRental
        case evCharger
        case fireStation
        case fitnessCenter
        case foodMarket
        case gasStation
        case hospital
        case hotel
        case laundry
        case library
        case marina
        case movieTheater
        case museum
        case nationalPark
        case nightlife
        case park
        case parking
        case pharmacy
        case police
        case postOffice
        case publicTransport
        case restroom
        case restaurant
        case store
        case school
        case stadium
        case theater
        case university
        case winery
        case zoo
        case unknown
    }

    public struct Coordinate {
        public let latitude: Double
        public let longitude: Double

        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    public let name: String?
    public let address: String?
    public let coordinate: Coordinate
    public let category: Category

    public init(name: String?, address: String?, coordinate: Coordinate, category: Category) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.category = category
    }
}

public enum PlaceSearchError: Error {
    case searchNotFound
    case unknown
}

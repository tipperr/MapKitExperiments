//
//  Location.swift
//  Maparron
//
//  Created by Ciaran Murphy on 5/12/24.
//

import Foundation
import MapKit
import Firebase
import FirebaseDatabase

struct Location: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var description: String
    var latitude: Double
    var longitude: Double
    var pinColor: String
    var visitStatus: VisitStatus
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID, name: String, description: String, latitude: Double, longitude: Double, pinColor: String, visitStatus: VisitStatus) {
            self.id = id
            self.name = name
            self.description = description
            self.latitude = latitude
            self.longitude = longitude
            self.pinColor = pinColor
            self.visitStatus = visitStatus
        }
    
    enum CodingKeys: String, CodingKey {
            case id, name, description, latitude, longitude, pinColor, visitStatus
        }
    
    enum VisitStatus: String, Codable, CaseIterable { // Enum to represent visit status
            case wantToVisit = "Want to visit"
            case visited = "Both Visited"
            case rachel = "Rachel Visited"
            case ciaran = "Ciarán Visited"
        }
    

    func toDictionary() -> [String: Any] {
            return [
                "id": id.uuidString,
                "name": name,
                "description": description,
                "latitude": latitude,
                "longitude": longitude,
                "pinColor": pinColor,
                "visitStatus": visitStatus.rawValue
            ]
        }
        
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(UUID.self, forKey: .id)
            self.name = try container.decode(String.self, forKey: .name)
            self.description = try container.decode(String.self, forKey: .description)
            self.latitude = try container.decode(Double.self, forKey: .latitude)
            self.longitude = try container.decode(Double.self, forKey: .longitude)
            self.pinColor = try container.decode(String.self, forKey: .pinColor)
            self.visitStatus = try container.decode(VisitStatus.self, forKey: .visitStatus) // Decode visit status enum
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(description, forKey: .description)
            try container.encode(latitude, forKey: .latitude)
            try container.encode(longitude, forKey: .longitude)
            try container.encode(pinColor, forKey: .pinColor)
            try container.encode(visitStatus, forKey: .visitStatus) // Encode visit status enum
        }
    
    #if DEBUG
    static let example = Location(
        id: UUID(),
        name: "Buckingham Palace",
        description: "Lit by over 40,000 lightbulbs.",
        latitude: 51.501,
        longitude: -0.141,
        pinColor: ".red",
        visitStatus: .visited
    )
    #endif
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}
 

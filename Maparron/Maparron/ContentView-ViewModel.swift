//
//  ContentView-ViewModel.swift
//  Maparron
//
//  Created by Ciaran Murphy on 5/12/24.
//

import CoreLocation
import Foundation
import MapKit
import Firebase
import FirebaseDatabase

extension ContentView {
    
    @Observable
    class ViewModel {
        private var databaseRef: DatabaseReference

        private(set) var locations: [Location]
        var selectedPlace: Location?
        
        
        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")
        
        init() {
            databaseRef = Database.database().reference()
            
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
            
            
        }
        
        
//        func save() {
//            do {
//                let data = try JSONEncoder().encode(locations)
//                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
//            } catch {
//                print("Unable to save data.")
//            }
//        }
        
        func fetchLocations() {
            databaseRef.child("locations").observeSingleEvent(of: .value) { snapshot in
                guard let data = snapshot.value as? [String: Any] else { return }
                
                var locationsArray: [Location] = []
                for (key, value) in data {
                    guard let locationData = value as? [String: Any] else { continue }
                    guard
                        let idString = locationData["id"] as? String,
                        let id = UUID(uuidString: idString),
                        let name = locationData["name"] as? String,
                        let description = locationData["description"] as? String,
                        let latitude = locationData["latitude"] as? Double,
                        let longitude = locationData["longitude"] as? Double,
                        let pinColor = locationData["pinColor"] as? String,
                        let visitStatusString = locationData["visitStatus"] as? String,
                        let visitStatus = Location.VisitStatus(rawValue: visitStatusString)
                    else {
                        continue
                    }
                    
                    let location = Location(id: id, name: name, description: description, latitude: latitude, longitude: longitude, pinColor: pinColor, visitStatus: visitStatus)
                    locationsArray.append(location)
                }
                DispatchQueue.main.async {
                    self.locations = locationsArray
                }
            }
        }

        
        func addLocation(at point: CLLocationCoordinate2D) {
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: point.latitude, longitude: point.longitude, pinColor: ".red", visitStatus: .wantToVisit)
            locations.append(newLocation)
            let locationDict = newLocation.toDictionary()
                if let idString = locationDict["id"] as? String {
                    databaseRef.child("locations").child(idString).setValue(locationDict) { error, _ in
                        if let error = error {
                                        print("Error adding location to Firebase: \(error)")
                        } else {
                            print("Location added successfully to Firebase")
                        }
                    }
                }
                fetchLocations()
            //save()
        }
        
        func update(location: Location){
            let idString = location.id.uuidString
            
            guard !idString.isEmpty else {
                    print("Error: Unable to convert location ID to string")
                    return
                }
            
            let locationDict = location.toDictionary()
            let locationRef = databaseRef.child("locations").child(idString)
                
            locationRef.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    locationRef.updateChildValues(locationDict) { error, _ in
                        if let error = error {
                            print("Error updating location in Firebase: \(error)")
                        } else {
                            print("Location updated successfully in Firebase")
                        }
                    }
                } else {
                    print("Location with ID \(idString) does not exist in Firebase")
                }
            }
            
//            let locationDict = location.toDictionary()
//                databaseRef.child("locations").child(idString).updateChildValues(locationDict) { error, _ in
//                    if let error = error {
//                        print("Error updating location in Firebase: \(error)")
//                    } else {
//                        print("Location updated successfully in Firebase")
//                    }
//                }
            
            
//                databaseRef.child("locations").child(idString).setValue(location.toDictionary()) { error, _ in
//                    if let error = error {
//                        print("Error updating location in Firebase: \(error)")
//                    } else {
//                        print("Location updated successfully in Firebase")
//                    }
//                }
            fetchLocations()
            }
//            guard let selectedPlace else { return }
//            if let index = locations.firstIndex(of: selectedPlace) {
//                locations[index] = location
//                //save()
//            }
        
        
        func deleteLocation(location: Location) {
            let idString = location.id.uuidString
            
            guard !idString.isEmpty else {
                    print("Error: Unable to convert location ID to string")
                    return
                }

                // Get a reference to the location node in the Firebase database
                let locationRef = databaseRef.child("locations").child(idString)

                // Remove the location node from the database
                locationRef.removeValue { error, _ in
                    if let error = error {
                        print("Error deleting location from Firebase: \(error)")
                    } else {
                        print("Location deleted successfully from Firebase")
                    }
                }

                // Update the local locations array
                if let index = locations.firstIndex(of: location) {
                    locations.remove(at: index)
                }
            
//                if let index = locations.firstIndex(of: location) {
//                    locations.remove(at: index)
//                    //save()
//                }
            }
        
    }
}
 

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
import UserNotifications

extension ContentView {
    
    //@Observable
    class ViewModel: ObservableObject {
        private var databaseRef: DatabaseReference

        @Published private(set) var locations: [Location]
        @Published var selectedPlace: Location?
        @Published var selectedFilter: Location.VisitStatus?
        
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
        
        var filteredLocations: [Location] { // Computed property for filtered locations
            guard let selectedFilter = selectedFilter else {
                return locations
            }
            return locations.filter { $0.visitStatus == selectedFilter }
        }
        
        var rachelVisitedCount: Int {
            locations.filter { ($0.visitStatus == .rachel) || ($0.visitStatus == .visited ) }.count
            }
            
        var ciaranVisitedCount: Int {
            locations.filter { ($0.visitStatus == .ciaran) ||  ($0.visitStatus == .visited )}.count
        }
            
        var bothVisitedCount: Int {
            locations.filter { $0.visitStatus == .visited }.count
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
            let newVisitStatus = selectedFilter ?? .wantToVisit
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: point.latitude, longitude: point.longitude, pinColor: ".red", visitStatus: newVisitStatus)
            locations.append(newLocation)
            let locationDict = newLocation.toDictionary()
                if let idString = locationDict["id"] as? String {
                    databaseRef.child("locations").child(idString).setValue(locationDict) { error, _ in
                        if let error = error {
                                        print("Error adding location to Firebase: \(error)")
                        } else {
                            print("Location added successfully to Firebase: \(idString)")
                            self.scheduleNotification(for: newLocation)
                        }
                    }
                }
                fetchLocations()
            //save()
        }
        
        func update(location: Location) {
            let idString = location.id.uuidString
            print("Updating location with ID: \(idString)") // Debugging statement

            guard !idString.isEmpty else {
                print("Error: Unable to convert location ID to string")
                return
            }

            let locationDict = location.toDictionary()
            let locationRef = databaseRef.child("locations").child(idString)

            locationRef.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    print("Location exists in Firebase, updating...") // Debugging statement
                    locationRef.updateChildValues(locationDict) { error, _ in
                        if let error = error {
                            print("Error updating location in Firebase: \(error)")
                        } else {
                            print("Location updated successfully in Firebase")
                            // Optionally update the local `locations` array
                            if let index = self.locations.firstIndex(where: { $0.id == location.id }) {
                                self.locations[index] = location
                            }
                        }
                    }
                } else {
                    print("Location with ID \(idString) does not exist in Firebase")
                }
            }
        }

        
//        func update(location: Location){
//                        
//            let idString = location.id.uuidString
//            
//            guard !idString.isEmpty else {
//                    print("Error: Unable to convert location ID to string")
//                    return
//                }
//            
//            let locationDict = location.toDictionary()
//            let locationRef = databaseRef.child("locations").child(idString)
//                
//            locationRef.observeSingleEvent(of: .value) { snapshot in
//                if snapshot.exists() {
//                    locationRef.updateChildValues(locationDict) { error, _ in
//                        if let error = error {
//                            print("Error updating location in Firebase: \(error)")
//                        } else {
//                            print("Location updated successfully in Firebase")
//                        }
//                    }
//                } else {
//                    print("Location with ID \(idString) does not exist in Firebase")
//                }
//            }
//            
////            let locationDict = location.toDictionary()
////                databaseRef.child("locations").child(idString).updateChildValues(locationDict) { error, _ in
////                    if let error = error {
////                        print("Error updating location in Firebase: \(error)")
////                    } else {
////                        print("Location updated successfully in Firebase")
////                    }
////                }
//            
//            
////                databaseRef.child("locations").child(idString).setValue(location.toDictionary()) { error, _ in
////                    if let error = error {
////                        print("Error updating location in Firebase: \(error)")
////                    } else {
////                        print("Location updated successfully in Firebase")
////                    }
////                }
//            fetchLocations()
//            }
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
        
        func scheduleNotification(for location: Location) {
                let content = UNMutableNotificationContent()
                content.title = "New Location Added"
                content.body = "A new location named \(location.name) has been added to the map."
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
        
        func requestNotificationPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    print("Notification permission granted.")
                } else {
                    if let error = error {
                        print("Notification permission denied: \(error)")
                    } else {
                        print("Notification permission denied.")
                    }
                }
            }
        }
        
    }
}
 

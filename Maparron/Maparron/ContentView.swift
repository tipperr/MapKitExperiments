//
//  ContentView.swift
//  Maparron
//
//  Created by Ciaran Murphy on 5/12/24.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41, longitude: -74),
            span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
    )
     
    var body: some View {
        
        MapReader{ proxy in
            Map(initialPosition: startPosition){
                ForEach(viewModel.locations){ location in
                    /*Marker(location.name, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))*/
                    Annotation(location.name, coordinate: location.coordinate){
                        Image(systemName: "star.circle")
                            .resizable()
                            .foregroundStyle(.red)
                            .frame(width: 44, height: 44)
                            .background(.white)
                            .clipShape(.circle)
                            .onLongPressGesture{
                                viewModel.selectedPlace = location
                            }
                    }
                }
            }
            .onTapGesture { position in
                if let coordinate = proxy.convert(position, from: .local){
                    viewModel.addLocation(at: coordinate)
                    //print("Tapped at \(coordinate)")
                    //Added to ViewModel
                    /*let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
                     
                     viewModel.locations.append(newLocation)*/
                }
            }
            .sheet(item: $viewModel.selectedPlace){ place in
                //Text(place.name)
//                EditView(location: place){ /*newLocation in*/
//                    viewModel.update(location: $0)
                    //viewModel.deleteLocation(location: $0)
                    //                    //Added to ViewModel
                    //                    /*if let index = viewModel.locations.firstIndex(of: place) {
                    //                     viewModel.locations[index] = newLocation
                    //                     }*/
                    //
                    //                }
                    
                    EditView(location: place, onSave: { updatedLocation in
                        viewModel.update(location: updatedLocation)
                    }, onDelete: {
                        viewModel.deleteLocation(location: place)
                    })

                    
                }
                
            }
            
        }
    
    
    
}

#Preview {
    ContentView()
}

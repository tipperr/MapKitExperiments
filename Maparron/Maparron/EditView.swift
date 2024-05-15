//
//  EditView.swift
//  Maparron
//
//  Created by Ciaran Murphy on 5/12/24.
//

import SwiftUI

struct EditView: View {
    enum LoadingState {
        case loading, loaded, failed
    }
    
    @Environment(\.dismiss) var dismiss
    var location: Location
    
    @State private var name: String
    @State private var description: String
    //@State private var pinColor: Color = .red
    @State private var visitStatus: Location.VisitStatus
    
    var onSave: (Location) -> Void
    var onDelete: (() -> Void)?
    
    //@State private var loadingState = LoadingState.loading
    //@State private var pages = [Page]()
    
    var body: some View {
        NavigationStack{
            Form {
                Section {
                    TextField("Place name", text: $name)
                    Picker("Status", selection: $visitStatus) {
                        ForEach(Location.VisitStatus.allCases, id: \.self) { status in
                            Text(status.rawValue)
                        }
                    }
                    TextField("Description", text: $description)
                    //ColorPicker("Pin Color", selection: $pinColor)
                }
                
            }
            .navigationTitle("Place Details")
            .toolbar{
                Button("Save"){
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    newLocation.visitStatus = visitStatus
                    
                    onSave(newLocation)
                    dismiss()
                }
                Button("Delete", role: .destructive) {
                                    onDelete?() // Call onDelete closure
                                    dismiss()
                                }
                .foregroundStyle(.red)
            }

        } 
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void, onDelete: (() -> Void)? = nil) {
        self.location = location
        self.onSave = onSave
        self.onDelete = onDelete
        self._visitStatus = State(initialValue: location.visitStatus)
        //self.pinColor = pinColor
        
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    
}

#Preview {
    EditView(location: .example) { _ in }
}

//
//  SavedLocationDetailView.swift
//  ClassProject
//
//  Created by Derek McCants on 10/20/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct SavedLocationDetailView: View {
    @ObservedObject
    var locationList : SavedLocationViewModel
    @State var location : SavedLocation
    @State var displayedLocation : MKCoordinateRegion
    func MainMap() -> some View {
        return Map(coordinateRegion: $displayedLocation)
    }
    
    init(locationList : SavedLocationViewModel, location: SavedLocation) {
        _locationList = ObservedObject(initialValue: locationList)
        _location = State(initialValue: location)
        _displayedLocation = State(initialValue: location.region)
    }
    
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
}

struct SavedLocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SavedLocationDetailView(locationList: SavedLocationViewModel(), location: SavedLocation())
    }
}

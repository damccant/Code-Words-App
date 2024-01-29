//
//  QuickConvertView.swift
//  ClassProject
//
//  Created by Derek McCants on 10/21/23.
//

import SwiftUI
import MapKit

struct QuickConvertView: View {
    @State var loc : SavedLocation = SavedLocation()
    @State var live = false
    @State var showLiveWarning = false
    @State var locName : String = ""
    @State var locNameUpdate = false
    @State var words : String = ""
    @State var wordsUpdate = false
    @State var longitude : String = ""
    @State var latitude : String = ""
    @State var coordsUpdate = false
    @State var region : MKCoordinateRegion = MKCoordinateRegion()
    @State var regionUpdate = false
    func clearAllUpdateButtons() {
        locNameUpdate = false
        wordsUpdate = false
        coordsUpdate = false
        regionUpdate = false
    }
    func updateFromName() {
        // TODO: geo coding
        locNameUpdate = false
    }
    func updateFromWords() {
        loc.getFromWords(words: words) {
            self.longitude = String(loc.longitude)
            self.latitude = String(loc.latitude)
            self.region = loc.region
            clearAllUpdateButtons()
        }
    }
    func updateFromCoords() {
        if let long = Double(self.longitude), let lat = Double(self.latitude) {
            if long >= -180 && long <= 180 && lat >= -90 && lat <= 90 {
                loc.longitude = long
                loc.latitude = lat
                loc.getWords() {
                    self.words = loc.words
                }
                self.region = loc.region
            }
        }
        clearAllUpdateButtons()
    }
    func updateFromRegion() {
        loc.longitude = region.center.longitude
        loc.latitude = region.center.latitude
        loc.getWords() {
            self.words = loc.words
        }
        self.longitude = String(loc.longitude)
        self.latitude = String(loc.latitude)
        clearAllUpdateButtons()
    }
    var body: some View {
        let locNameBinding = Binding<String>(get: {
            return locName
        }, set: {
            self.locName = $0
            locNameUpdate = true
            if live {
                updateFromName()
            }
        })
        let wordsBinding = Binding<String>(get: {
            return words
        }, set: {
            self.words = $0
            wordsUpdate = true
            if live {
                updateFromWords()
            }
        })
        let longitudeBinding = Binding<String>(get: {
            return longitude
        }, set: {
            self.longitude = $0
            coordsUpdate = true
            if live {
                updateFromCoords()
            }
        })
        let latitudeBinding = Binding<String>(get: {
            return latitude
        }, set: {
            self.latitude = $0
            coordsUpdate = true
            if live {
                updateFromCoords()
            }
        })
        let regionBinding = Binding<MKCoordinateRegion>(get: {
            return region
        }, set: {
            // sometimes MapKit calls this even when we havent moved
            // so make sure we actually moved
            let new = $0
            regionUpdate = new.center.latitude != self.region.center.latitude || new.center.longitude != self.region.center.longitude
            self.region = $0
            if live && regionUpdate {
                updateFromRegion()
            }
        })
        VStack {
            HStack {
                TextField("Search (E.g., Mill Cue Club)", text: locNameBinding)
                if(locNameUpdate && !live) {
                    Spacer()
                    Button("Update") {
                        updateFromName()
                    }
                }
            }
            HStack {
                TextField("Code words", text: wordsBinding)
                    .onSubmit {
                        updateFromWords()
                    }
                if(wordsUpdate && !live)
                {
                    Spacer()
                    Button("Update") {
                        updateFromWords()
                    }
                }
            }
            HStack {
                TextField("Longitude", text: longitudeBinding)
                Spacer()
                TextField("Latitude", text: latitudeBinding)
                if(coordsUpdate && !live) {
                    Spacer()
                    Button("Update") {
                        updateFromCoords()
                    }
                }
            }
            VStack {
                Map(coordinateRegion: regionBinding)
                if(regionUpdate && !live) {
                    Button("Update from Map") {
                        updateFromRegion()
                    }
                }
            }
            Toggle("Live Update", isOn: $live)
                .onChange(of: live) { value in
                    if value {
                        showLiveWarning = true
                    }
                }
                .alert("Warning: Live view is still buggy and consumes a LOT of system resources, you have been warned!", isPresented: $showLiveWarning) {
                    Button("Cancel", role: .cancel) {live = false}
                    Button("OK", role: .cancel) {}
                }
        }.padding()
    }
}

#Preview {
    QuickConvertView()
}

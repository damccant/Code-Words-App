//
//  ContentView.swift
//  ClassProject
//
//  Created by Derek McCants on 19-10-2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        /*TabView {
            SavedLocationsView()
                .tabItem {
                    Label("Saved Locations", systemImage: "folder")
                }
        }*/
        QuickConvertView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

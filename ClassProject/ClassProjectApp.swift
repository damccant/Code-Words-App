//
//  ClassProjectApp.swift
//  ClassProject
//
//  Created by Derek McCants on 19-10-2023.
//

import SwiftUI

@main
struct ClassProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

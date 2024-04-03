//
//  PigmentoApp.swift
//  Pigmento
//
//  Created by Roland Kajatin on 31/03/2024.
//

import SwiftUI

@main
struct PigmentoApp: App {
    private let hapticsManager = HapticsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(hapticsManager)
        }
    }
}

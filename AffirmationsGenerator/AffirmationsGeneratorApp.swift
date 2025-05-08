//
//  AffirmationsGeneratorApp.swift
//  AffirmationsGenerator
//
//  Created by Angelo Milonas on 5/5/25.
//

import SwiftUI

@main
struct AffirmationsGeneratorApp: App {
    init() {
            UIView.appearance().overrideUserInterfaceStyle = .dark
        }
    
    var body: some Scene {
        WindowGroup {
            ContentInputView()
        }
    }
}

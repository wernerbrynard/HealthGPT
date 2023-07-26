//
//  MainTabView.swift
//  HealthGPT
//
//  Created by Werner Brynard on 2023/07/23.
//

import HealthKit
import OpenAI
import SpeziFHIR
import SpeziSecureStorage
import SwiftUI


// Placeholder for Profile view
struct OverviewView: View {
    var body: some View {
        Text("Health")
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            // Chat tab
            HealthGPTView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Ask")
                }
            
            // Overview tab with health stats
            OverviewView()
                .tabItem {
                    Image(systemName: "heart.fill") // Updated to heart.fill for Health
                    Text("Health")
                }

//            // Settings tab
//            SettingsView()
//                .tabItem {
//                    Image(systemName: "gearshape.fill")
//                    Text("Settings")
//                }
        }
    }
}

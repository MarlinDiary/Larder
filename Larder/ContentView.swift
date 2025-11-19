//
//  ContentView.swift
//  Larder
//
//  Created by Marlin on 18/11/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PlanView()
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                }

            RecipeView()
                .tabItem {
                    Label("Recipes", systemImage: "book.pages")
                }

            GroceryView()
                .tabItem {
                    Label("Groceries", systemImage: "cart")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}

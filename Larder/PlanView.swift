//
//  PlanView.swift
//  Larder
//
//  Created by Marlin on 18/11/2025.
//

import SwiftUI

struct PlanView: View {
    @State private var activeDateForRecipeSheet: Date?
    @State private var plannedRecipes: [Date: [Recipe]] = PlanView.loadSavedPlans()

    private var upcomingDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<30).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(upcomingDates, id: \.self) { date in
                    planSection(for: date)
                }
            }
            .listSectionSeparator(.hidden)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .navigationTitle(
                Text("Meal Plan")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
            )
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: {}) {
                            Label("Add to Groceries", systemImage: "cart.badge.plus")
                        }

                        Divider()

                        Button(action: {}) {
                            Label("Scan Fridge", systemImage: "camera.viewfinder")
                        }

                        Button(action: {}) {
                            Label("Generate Recipes", systemImage: "wand.and.stars")
                        }

                        Divider()

                        Button(action: {}) {
                            Label("Display Calories", systemImage: "flame")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .menuOrder(.fixed)
                }
            }
#endif
            .sheet(
                isPresented: Binding(
                    get: { activeDateForRecipeSheet != nil },
                    set: { newValue in
                        if !newValue {
                            activeDateForRecipeSheet = nil
                        }
                    }
                )
            ) {
                if let date = activeDateForRecipeSheet {
                    RecipeView(showsDismissButton: true) { recipe in
                        plannedRecipes[date, default: []].append(recipe)
                        activeDateForRecipeSheet = nil
                    }
                } else {
                    EmptyView()
                }
            }
            .onChange(of: plannedRecipes) { _, newValue in
                PlanView.save(plans: newValue)
            }
        }
    }

    private static let storageKey = "mealPlan.savedRecipes"
    private static let storageFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func loadSavedPlans() -> [Date: [Recipe]] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let stored = try? JSONDecoder().decode([String: [Recipe]].self, from: data)
        else { return [:] }

        var result: [Date: [Recipe]] = [:]
        let calendar = Calendar.current
        for (key, value) in stored {
            if let date = storageFormatter.date(from: key) {
                result[calendar.startOfDay(for: date)] = value
            }
        }
        return result
    }

    private static func save(plans: [Date: [Recipe]]) {
        var storageDictionary: [String: [Recipe]] = [:]
        let calendar = Calendar.current
        for (date, recipes) in plans {
            let normalized = calendar.startOfDay(for: date)
            let key = storageFormatter.string(from: normalized)
            storageDictionary[key] = recipes
        }
        if let data = try? JSONEncoder().encode(storageDictionary) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func sectionHeader(for date: Date) -> some View {
        HStack {
            Text(planDateFormatter.string(from: date))
                .font(.headline)

            Spacer()

            Menu {
                Button(action: {
                    activeDateForRecipeSheet = date
                }) {
                    Label("Recipe", systemImage: "plus.circle")
                }

                Button(action: {}) {
                    Label("Scan Fridge", systemImage: "camera")
                }

                Button(action: {}) {
                    Label("Random Recipe", systemImage: "wand.and.sparkles")
                }
            } label: {
                Image(systemName: "plus")
            }
            .menuOrder(.fixed)
            .menuStyle(.button)
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .padding(.leading, 8)
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func planSection(for date: Date) -> some View {
        Section(header: sectionHeader(for: date)) {
            if let recipes = plannedRecipes[date], !recipes.isEmpty {
                ForEach(recipes) { recipe in
                    NavigationLink(value: recipe) {
                        PlanRecipeRow(recipe: recipe)
                    }
                    .listRowSeparator(.hidden, edges: .all)
                }
            } else {
                PlanEmptyRow()
                    .listRowSeparator(.hidden, edges: .all)
            }
        }
    }
}

private struct PlanRecipeRow: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 12) {
            Image(recipe.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(recipe.title)
                .font(.headline)

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

private struct PlanEmptyRow: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "fork.knife")
                .font(.title)
                .foregroundStyle(Color.secondary.opacity(0.4))
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private let planDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "d MMM"
    return formatter
}()

#Preview {
    PlanView()
}

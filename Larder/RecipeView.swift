//
//  RecipeView.swift
//  Larder
//
//  Created by Marlin on 18/11/2025.
//

import SwiftUI

#if canImport(UIKit)
private let recipeDetailBackground = Color(uiColor: .systemGroupedBackground)
#elseif canImport(AppKit)
private let recipeDetailBackground = Color(nsColor: .windowBackgroundColor)
#else
private let recipeDetailBackground = Color.gray.opacity(0.1)
#endif

struct RecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Namespace private var recipeNamespace
    private let recipes = Recipe.sampleData
    private let showsDismissButton: Bool
    private let onRecipeSelected: ((Recipe) -> Void)?

    init(showsDismissButton: Bool = false, onRecipeSelected: ((Recipe) -> Void)? = nil) {
        self.showsDismissButton = showsDismissButton
        self.onRecipeSelected = onRecipeSelected
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(recipes) { recipe in
                        if let onRecipeSelected {
                            Button {
                                onRecipeSelected(recipe)
                            } label: {
                                RecipeCardView(recipe: recipe, namespace: recipeNamespace)
                            }
                            .buttonStyle(.plain)
                        } else {
                            NavigationLink(value: recipe) {
                                RecipeCardView(recipe: recipe, namespace: recipeNamespace)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .navigationTitle(
                Text("All Recipes")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
            )
#if os(iOS)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }

                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                    }
                }

                if showsDismissButton {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
#endif
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe, namespace: recipeNamespace)
            }
        }
    }
}
// MARK: - Components

private var gridColumns: [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
}

private struct RecipeCardView: View {
    let recipe: Recipe
    let namespace: Namespace.ID

    var body: some View {
        Image(recipe.imageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .aspectRatio(4.0 / 3.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(titleOverlay, alignment: .topLeading)
#if os(iOS)
            .matchedTransitionSource(id: recipe.id, in: namespace)
#endif
    }

    private var titleOverlay: some View {
        Text(recipe.title)
            .font(.headline)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.7), radius: 6, x: 0, y: 2)
            .padding(12)
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe
    let namespace: Namespace.ID?
    @State private var isPresentingStepPlayback = false

    init(recipe: Recipe, namespace: Namespace.ID? = nil) {
        self.recipe = recipe
        self.namespace = namespace
    }

    var body: some View {
        List {
            imageSection
            ingredientsSection
            methodSection
        }
        .applyInsetGroupedStyle
        .scrollContentBackground(.hidden)
        .background(recipeDetailBackground)
        .listSectionSeparator(.hidden, edges: .all)
        .listRowSeparator(.hidden, edges: .all)
        .navigationTitle(recipe.title)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    isPresentingStepPlayback = true
                } label: {
                    Image(systemName: "play.fill")
                }
            }
        }
        .maybeZoomTransition(namespace: namespace, recipeID: recipe.id)
#endif
#if os(iOS)
        .fullScreenCover(isPresented: $isPresentingStepPlayback) {
            StepPlaybackView(steps: recipe.steps)
        }
#endif
    }

    @ViewBuilder
    private var imageSection: some View {
        Section {
            Image(recipe.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(4.0 / 3.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden, edges: .all)
        }
    }

    @ViewBuilder
    private var ingredientsSection: some View {
        Section("Ingredients") {
            ForEach(recipe.ingredients, id: \.self) { ingredient in
                IngredientRow(text: ingredient)
                    .listRowSeparator(.hidden, edges: .all)
            }
        }
    }

    @ViewBuilder
    private var methodSection: some View {
        Section("Method") {
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                MethodRow(index: index + 1, text: step)
                    .listRowSeparator(.hidden, edges: .all)
            }
        }
    }
}

private struct StepPlaybackView: View {
    let steps: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if !steps.isEmpty {
                    Text("Step \(currentStep + 1) of \(steps.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ProgressView(value: Double(currentStep + 1), total: Double(steps.count))
                        .progressViewStyle(.linear)
                        .animation(.easeInOut(duration: 0.25), value: currentStep)
                }

                TabView(selection: $currentStep) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        stepCard(step: step, number: index + 1)
                            .tag(index)
                    }
                }
#if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .always))
#endif
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        advance()
                    } label: {
                        Image(systemName: currentStep < steps.count - 1 ? "arrow.right" : "checkmark")
                    }
                    .disabled(steps.isEmpty)
                }
            }
            .navigationTitle("Cooking Steps")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
        }
#if os(iOS)
#endif
    }

    private func advance() {
        guard !steps.isEmpty else { return }
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            dismiss()
        }
    }

    private func stepCard(step: String, number: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Step \(number)")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(step)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}

private struct IngredientRow: View {
    let text: String

    var body: some View {
        highlightedIngredientText(from: text)
            .font(.subheadline)
    }
}

private struct MethodRow: View {
    let index: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

private func highlightedIngredientText(from text: String) -> Text {
    var attributed = AttributedString()
    var currentSegment = ""
    var currentIsNumber: Bool?

    func flushCurrent() {
        guard !currentSegment.isEmpty else { return }
        var segment = AttributedString(currentSegment)
        if currentIsNumber == true {
            segment.foregroundColor = .blue
        }
        attributed.append(segment)
        currentSegment = ""
    }

    for character in text {
        let isNumberCharacter = character.isNumber || numericHighlightCharacters.contains(character)
        if currentIsNumber == nil {
            currentIsNumber = isNumberCharacter
        }
        if isNumberCharacter != currentIsNumber {
            flushCurrent()
            currentIsNumber = isNumberCharacter
        }
        currentSegment.append(character)
    }

    flushCurrent()

    if attributed.characters.isEmpty {
        return Text(text)
    }

    return Text(attributed)
}

private let numericHighlightCharacters: Set<Character> = Set("/.½⅓⅔¼¾⅛⅜⅝⅞")

#if os(iOS)
private extension View {
    @ViewBuilder
    var applyInsetGroupedStyle: some View {
        self.listStyle(.insetGrouped)
    }
}
#else
private extension View {
    @ViewBuilder
    var applyInsetGroupedStyle: some View {
        self
    }
}
#endif

#if os(iOS)
private extension View {
    @ViewBuilder
    func maybeZoomTransition(namespace: Namespace.ID?, recipeID: UUID) -> some View {
        if let namespace {
            self.navigationTransition(.zoom(sourceID: recipeID, in: namespace))
        } else {
            self
        }
    }
}
#endif

struct Recipe: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let imageName: String
    let ingredients: [String]
    let steps: [String]

    init(
        id: UUID = UUID(),
        title: String,
        imageName: String,
        ingredients: [String],
        steps: [String]
    ) {
        self.id = id
        self.title = title
        self.imageName = imageName
        self.ingredients = ingredients
        self.steps = steps
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, imageName, ingredients, steps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedID = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        let title = try container.decode(String.self, forKey: .title)
        let imageName = try container.decode(String.self, forKey: .imageName)
        let ingredients = try container.decode([String].self, forKey: .ingredients)
        let steps = try container.decode([String].self, forKey: .steps)

        self.init(
            id: decodedID,
            title: title,
            imageName: imageName,
            ingredients: ingredients,
            steps: steps
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(steps, forKey: .steps)
    }
}

extension Recipe {
    static let sampleData: [Recipe] = [
        Recipe(
            title: "Homemade Granola",
            imageName: "1046ab29-6462-4b3b-93a2-85b1e7e70207",
            ingredients: [
                "3 cups old-fashioned rolled oats",
                "1 cup nuts (almonds, walnuts, pecans)",
                "1/2 cup seeds (pumpkin, sunflower)",
                "1/2 tsp salt",
                "1 tsp cinnamon",
                "1/2 cup maple syrup or honey",
                "1/3 cup melted coconut oil",
                "1 tsp vanilla extract",
                "1/2 cup dried fruit (cranberries, raisins)"
            ],
            steps: [
                "Preheat oven to 300°F (150°C) and line a large baking sheet with parchment paper.",
                "In a large bowl, mix oats, nuts, seeds, salt, and cinnamon.",
                "In a small bowl, whisk together maple syrup or honey, melted coconut oil, and vanilla.",
                "Pour the wet mixture over the dry ingredients and stir until everything is evenly coated.",
                "Spread the mixture in an even layer on the prepared baking sheet.",
                "Bake for 20-25 minutes, stirring halfway through, until golden brown.",
                "Let cool completely on the tray so it crisps up.",
                "Once cool, mix in dried fruit and store in an airtight container."
            ]
        ),
        Recipe(
            title: "Lemon Herb Chicken",
            imageName: "21ef6983-7dac-4aea-b2e5-dbef750ff0da",
            ingredients: [
                "4 chicken breasts or thighs",
                "Juice and zest of 2 lemons",
                "3 tbsp olive oil",
                "4 garlic cloves, minced",
                "1 tbsp fresh rosemary, chopped",
                "1 tbsp fresh thyme",
                "Salt and pepper"
            ],
            steps: [
                "Whisk together lemon juice, zest, olive oil, garlic, herbs, salt, and pepper.",
                "Add chicken and marinate for at least 30 minutes or overnight.",
                "Preheat grill or oven to 400°F (200°C).",
                "Cook chicken 6-8 minutes per side until internal temp reaches 165°F.",
                "Let rest 5 minutes and serve with extra lemon wedges."
            ]
        ),
        Recipe(
            title: "Roasted Veggie Pasta",
            imageName: "2f9662a2-1bdb-42cb-8255-2b6359812421",
            ingredients: [
                "400 g pasta (penne or fusilli)",
                "Assorted vegetables (zucchini, bell peppers, cherry tomatoes, eggplant)",
                "Olive oil, salt, pepper, Italian herbs",
                "Parmesan or feta (optional)"
            ],
            steps: [
                "Preheat oven to 425°F (220°C).",
                "Chop vegetables into bite-sized pieces and toss with oil, salt, pepper, and herbs.",
                "Roast on a sheet pan for 20-25 minutes until caramelized.",
                "Cook pasta in salted water until al dente and reserve 1/2 cup pasta water.",
                "Toss pasta with roasted veggies and a splash of pasta water.",
                "Top with cheese and fresh basil."
            ]
        ),
        Recipe(
            title: "Coconut Curry Soup",
            imageName: "3ae44cc7-0737-44f9-932e-e6218893f2da",
            ingredients: [
                "1 tbsp oil",
                "1 onion, diced",
                "3 garlic cloves, minced",
                "1 tbsp ginger",
                "2-3 tbsp red or green curry paste",
                "1 can coconut milk",
                "4 cups vegetable or chicken broth",
                "Vegetables (carrots, bell pepper, broccoli)",
                "Protein (chicken, shrimp, tofu)",
                "Lime, cilantro"
            ],
            steps: [
                "Heat oil and sauté onion, garlic, and ginger until soft.",
                "Stir in curry paste and cook 1 minute.",
                "Pour in coconut milk and broth and bring to a simmer.",
                "Add vegetables and protein and cook until everything is tender.",
                "Season with lime juice, fish sauce if using, and salt.",
                "Serve with cilantro and lime wedges."
            ]
        ),
        Recipe(
            title: "Berry Yogurt Bowl",
            imageName: "77831200-69de-4c34-96f5-bbe0f405a97c",
            ingredients: [
                "1 cup Greek or plain yogurt",
                "Mixed fresh berries (strawberries, blueberries, raspberries)",
                "1-2 tbsp honey or maple syrup",
                "Granola or nuts for topping"
            ],
            steps: [
                "Spoon yogurt into a bowl and sweeten if desired.",
                "Top generously with fresh berries.",
                "Finish with granola or nuts plus optional chia, coconut, or nut butter."
            ]
        ),
        Recipe(
            title: "Grilled Salmon",
            imageName: "a2a75101-f6e5-4e65-b462-0f8bc17cdf15",
            ingredients: [
                "4 salmon fillets",
                "2 tbsp olive oil",
                "Juice of 1 lemon",
                "2 garlic cloves, minced",
                "Fresh dill or parsley",
                "Salt and pepper"
            ],
            steps: [
                "Pat salmon dry and season with salt and pepper.",
                "Mix oil, lemon juice, garlic, and herbs; brush over salmon.",
                "Marinate 10-15 minutes.",
                "Grill skin-side down 4-5 minutes, flip and cook 3-4 minutes more.",
                "Serve with herbs and lemon."
            ]
        ),
        Recipe(
            title: "Avocado Toast Deluxe",
            imageName: "d1b6ea6c-b763-452c-9021-0bc8bdb8ad8f",
            ingredients: [
                "Good sourdough or whole-grain bread",
                "Ripe avocados",
                "Toppings: poached egg, cherry tomatoes, radish, feta, chili flakes, everything seasoning, microgreens"
            ],
            steps: [
                "Toast bread until golden.",
                "Mash avocado with salt, pepper, and citrus juice.",
                "Spread on toast and pile on toppings like radish, tomatoes, feta, egg, and chili flakes.",
                "Finish with olive oil."
            ]
        ),
        Recipe(
            title: "Hearty Beef Stew",
            imageName: "f93467c0-dd33-4c2d-8978-e19756bea0f9",
            ingredients: [
                "2 lbs beef chuck, cubed",
                "Flour, salt, pepper",
                "Onion, carrots, potatoes, celery",
                "Garlic, tomato paste",
                "Beef broth, red wine (optional)",
                "Bay leaves, thyme"
            ],
            steps: [
                "Coat beef cubes in flour, salt, and pepper.",
                "Brown beef in batches and set aside.",
                "Sauté onion, carrots, celery, and garlic.",
                "Stir in tomato paste and cook 2 minutes.",
                "Deglaze with wine if using, then add broth.",
                "Return beef, add potatoes and herbs, and simmer 2-2.5 hours until tender.",
                "Adjust seasoning and serve with crusty bread."
            ]
        )
    ]
}
#Preview {
    RecipeView()
}

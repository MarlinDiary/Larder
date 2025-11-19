//
//  GroceryView.swift
//  Larder
//
//  Created by Marlin on 18/11/2025.
//

import SwiftUI

struct GroceryView: View {
    @State private var items: [GroceryItem] = GroceryItem.sampleData
    @State private var isPresentingNewItemSheet = false
    @State private var newItemName = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if items.isEmpty {
                        placeholderRow
                    } else {
                        ForEach(items.indices, id: \.self) { index in
                            GroceryRow(item: $items[index], deleteAction: {
                                remove(items[index])
                            })
                            .listRowSeparator(.hidden, edges: .all)
                        }
                    }
                }
            }
            .conditionalListStyle
            .navigationTitle("Groceries")
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    addButton
                }
#else
                ToolbarItem {
                    addButton
                }
#endif
            }
            .sheet(isPresented: $isPresentingNewItemSheet) {
                NavigationStack {
                    Form {
                        Section("Item name") {
                            TextField("e.g. Fresh basil", text: $newItemName)
                                .autocorrectionDisabled()
                        }
                    }
                    .navigationTitle("New Item")
#if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
#endif
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingNewItemSheet = false
                            }
                        }

                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                addNewItem()
                            }
                            .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
            }
        }
    }

    private var addButton: some View {
        Button {
            newItemName = ""
            isPresentingNewItemSheet = true
        } label: {
            Image(systemName: "plus")
        }
    }

    private var placeholderRow: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart.badge.plus")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Your grocery list is empty")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowSeparator(.hidden, edges: .all)
    }

private func addNewItem() {
    let trimmed = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    items.append(GroceryItem(name: trimmed))
        isPresentingNewItemSheet = false
    }

    private func remove(_ item: GroceryItem) {
        guard let index = items.firstIndex(of: item) else { return }
        items.remove(at: index)
    }
}

private extension View {
    @ViewBuilder
    var conditionalListStyle: some View {
#if os(iOS)
        self.listStyle(.insetGrouped)
#else
        self
#endif
    }
}

private struct GroceryItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var isCompleted: Bool = false

    static let sampleData: [GroceryItem] = [
        GroceryItem(name: "Whole wheat bread"),
        GroceryItem(name: "Cherry tomatoes"),
        GroceryItem(name: "Greek yogurt"),
        GroceryItem(name: "Fresh basil", isCompleted: true)
    ]
}

private struct GroceryRow: View {
    @Binding var item: GroceryItem
    var deleteAction: () -> Void

    var body: some View {
        HStack {
            Button {
                item.isCompleted.toggle()
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isCompleted ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)

            Text(item.name)
                .strikethrough(item.isCompleted, color: .secondary)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)

            Spacer()
        }
#if os(iOS)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: deleteAction) {
                Image(systemName: "trash")
            }
        }
#endif
        .padding(.vertical, 4)
    }
}

#Preview {
    GroceryView()
}

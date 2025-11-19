//
//  SettingsView.swift
//  Larder
//
//  Created by Marlin on 18/11/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        Text("Customize your cuisine preferences here.")
                    } label: {
                        Label {
                            Text("Dietary Preferences")
                        } icon: {
                            Image(systemName: "fork.knife")
                                .foregroundStyle(.pink)
                        }
                    }

                    NavigationLink {
                        Text("Specify any ingredients you want to avoid.")
                    } label: {
                        Label {
                            Text("Allergens & Restrictions")
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                        }
                    }

                    NavigationLink {
                        Text("Set your dietary goals such as weight loss or maintenance.")
                    } label: {
                        Label {
                            Text("Diet Goals")
                        } icon: {
                            Image(systemName: "target")
                                .foregroundStyle(.green)
                        }
                    }

                }

                Section {
                    NavigationLink {
                        Text("Decide how many calories you want to eat per day.")
                    } label: {
                        Label {
                            Text("Calorie Intake")
                        } icon: {
                            Image(systemName: "flame")
                                .foregroundStyle(.red)
                        }
                    }

                    NavigationLink {
                        Text("Manage your weekly or monthly grocery budget.")
                    } label: {
                        Label {
                            Text("Grocery Budget")
                        } icon: {
                            Image(systemName: "wallet.pass")
                                .foregroundStyle(.teal)
                        }
                    }

                    NavigationLink {
                        Text("Track macro ratios like protein, carbs, and fats.")
                    } label: {
                        Label {
                            Text("Macro Balance")
                        } icon: {
                            Image(systemName: "chart.pie")
                                .foregroundStyle(.purple)
                        }
                    }
                }

                Section {
                    NavigationLink {
                        Text("Adjust notifications or other global app preferences.")
                    } label: {
                        Label {
                            Text("General")
                        } icon: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(.gray)
                        }
                    }

                    NavigationLink {
                        Text("Choose light, dark, or auto appearance.")
                    } label: {
                        Label {
                            Text("Appearance")
                        } icon: {
                            Image(systemName: "paintpalette")
                                .foregroundStyle(.blue)
                        }
                    }

                    NavigationLink {
                        Text("Manage notifications for reminders and cooking timers.")
                    } label: {
                        Label {
                            Text("Notifications")
                        } icon: {
                            Image(systemName: "bell.badge")
                                .foregroundStyle(.yellow)
                        }
                    }

                    NavigationLink {
                        Text("Control data syncing, backups, or export options.")
                    } label: {
                        Label {
                            Text("Data & Sync")
                        } icon: {
                            Image(systemName: "icloud")
                                .foregroundStyle(.indigo)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

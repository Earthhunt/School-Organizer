//
//  AddTermView.swift
//  School Organizer
//

import SwiftUI
import SwiftData

struct AddTermView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var gradeSystem: GradeSystem = .grades16

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("z.B. Klasse 10 oder Q1", text: $name)
                }

                Section("Notensystem") {
                    Picker("System", selection: $gradeSystem) {
                        ForEach(GradeSystem.allCases) { system in
                            Text(system.title).tag(system)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Neuer Stundenplan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Erstellen") { save() }
                        .disabled(name.isEmpty)
                }
            }
        }
    }

    private func save() {
        let term = Term(name: name, gradeSystem: gradeSystem)
        modelContext.insert(term)
        dismiss()
    }
}

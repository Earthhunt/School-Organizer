import SwiftUI
import SwiftData

struct TeachersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GlobalTeacher.name) private var teachers: [GlobalTeacher]
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddTeacher = false
    
    var body: some View {
        NavigationStack {
            List {
                if teachers.isEmpty {
                    ContentUnavailableView("Keine Lehrer", systemImage: "person.2", description: Text("Lege deine globalen Lehrer an."))
                } else {
                    ForEach(teachers) { teacher in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(teacher.name).font(.headline)
                                if let subject = teacher.primarySubject {
                                    Text(subject).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteTeachers)
                }
            }
            .navigationTitle("Lehrer verwalten")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Zurück") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddTeacher = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAddTeacher) {
                AddTeacherView()
            }
        }
    }
    
    private func deleteTeachers(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(teachers[index]) }
    }
}

struct AddTeacherView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var primarySubject = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name (z.B. Frau Müller)", text: $name)
                TextField("Hauptfach (optional)", text: $primarySubject)
            }
            .navigationTitle("Neuer Lehrer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        modelContext.insert(GlobalTeacher(name: name, primarySubject: primarySubject.isEmpty ? nil : primarySubject))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

import SwiftUI
import SwiftData

struct SubjectsView: View {
    let term: Term
    var onBack: () -> Void // Funktion zum Zurückkehren
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSubject = false
    
    var body: some View {
        NavigationStack {
            List {
                if term.subjects.isEmpty {
                    ContentUnavailableView("Keine Fächer", systemImage: "book.closed", description: Text("Lege zuerst deine Fächer an, um sie im Stundenplan oder bei Klausuren auszuwählen."))
                } else {
                    ForEach(term.subjects) { subject in
                        HStack {
                            Circle()
                                .fill(Color(hex: subject.colorHex))
                                .frame(width: 12, height: 12)
                            Text(subject.name)
                                .font(.headline)
                            Spacer()
                            ColorPicker("", selection: Binding(
                                get: { Color(hex: subject.colorHex) },
                                set: { subject.colorHex = $0.toHex() }
                            ))
                            .labelsHidden()
                        }
                    }
                    .onDelete(perform: deleteSubjects)
                }
            }
            .navigationTitle("Fächer verwalten")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Zurück") {
                        onBack() // Geht zurück zu den Einstellungen
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddSubject = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSubject) {
                AddSubjectView(term: term)
            }
        }
    }
    
    private func deleteSubjects(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(term.subjects[index])
        }
    }
}

struct AddSubjectView: View {
    let term: Term
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var color = Color.blue
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Fachname (z.B. Mathe)", text: $name)
                ColorPicker("Farbe", selection: $color)
            }
            .navigationTitle("Neues Fach")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        let new = Subject(name: name, colorHex: color.toHex(), term: term)
                        modelContext.insert(new)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else { return "#4F8EF7" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

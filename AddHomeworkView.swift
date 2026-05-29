import SwiftUI
import SwiftData

struct AddHomeworkView: View {
    let term: Term
    var homeworkToEdit: Homework? = nil
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var subject = ""
    @State private var colorHex = "#4F8EF7"
    @State private var details = "" // GEFIXED: war 'task'
    @State private var dueDate = Calendar.current.startOfDay(for: .now)
    @State private var notes = ""
    @State private var isDone = false // GEFIXED: war 'isCompleted'
    
    private var isEditing: Bool { homeworkToEdit != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Fach") {
                    if !term.subjects.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(term.subjects) { sub in
                                    Button {
                                        subject = sub.name
                                        colorHex = sub.colorHex
                                    } label: {
                                        Text(sub.name)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color(hex: sub.colorHex).opacity(subject == sub.name ? 0.5 : 0.2))
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    TextField("Fachname", text: $subject)
                }
                
                Section("Aufgabe") {
                    TextField("Was muss erledigt werden?", text: $details)
                    DatePicker("Fällig am", selection: $dueDate, displayedComponents: .date)
                    Toggle("Erledigt", isOn: $isDone)
                }
                
                Section("Notizen") {
                    TextField("Zusatzinfos...", text: $notes, axis: .vertical)
                        .lineLimit(2...6)
                }
                
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            deleteHomework()
                        } label: {
                            Label("Hausaufgabe löschen", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Hausaufgabe bearbeiten" : "Neue Hausaufgabe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
                        .disabled(subject.isEmpty || details.isEmpty)
                }
            }
            .onAppear(perform: loadIfEditing)
        }
    }
    
    private func loadIfEditing() {
        guard let hw = homeworkToEdit else { return }
        subject = hw.subject
        colorHex = hw.colorHex
        details = hw.details
        dueDate = hw.dueDate
        notes = hw.notes
        isDone = hw.isDone
    }
    
    private func save() {
        if let hw = homeworkToEdit {
            hw.subject = subject
            hw.colorHex = colorHex
            hw.details = details
            hw.dueDate = dueDate
            hw.notes = notes
            hw.isDone = isDone
        } else {
            let new = Homework(
                subject: subject,
                colorHex: colorHex,
                details: details,
                notes: notes,
                dueDate: dueDate,
                isDone: isDone,
                term: term
            )
            modelContext.insert(new)
        }
        dismiss()
    }
    
    private func deleteHomework() {
        if let hw = homeworkToEdit {
            modelContext.delete(hw)
        }
        dismiss()
    }
}

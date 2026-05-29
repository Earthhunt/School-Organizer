//
//  AddExamView.swift
//  School Organizer
//

import SwiftUI
import SwiftData

struct AddExamView: View {
    let term: Term
    var examToEdit: Exam? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var subject = ""
    @State private var colorHex = lessonColors[0]
    @State private var topic = ""
    @State private var date = Calendar.current.startOfDay(for: .now)
    @State private var notes = ""

    private var isEditing: Bool { examToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Fach") {
                    if !term.subjects.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(term.subjects, id: \.name) { sub in
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
                    TextField("Fach (z.B. Mathe)", text: $subject)
                }

                Section("Thema") {
                    TextField("z.B. Analysis", text: $topic)
                }

                Section("Datum") {
                    DatePicker("Klausur am", selection: $date, displayedComponents: .date)
                }

                Section("Notizen") {
                    TextField("z.B. Taschenrechner mitbringen …", text: $notes, axis: .vertical)
                        .lineLimit(2...6)
                }

                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            deleteExam()
                        } label: {
                            Label("Klausur löschen", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Klausur bearbeiten" : "Neue Klausur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
                        .disabled(subject.isEmpty)
                }
            }
            .onAppear(perform: loadIfEditing)
        }
    }

    private func loadIfEditing() {
        guard let exam = examToEdit else { return }
        subject = exam.subject
        colorHex = exam.colorHex
        topic = exam.topic
        date = exam.date
        notes = exam.notes
    }

    private func save() {
        if let exam = examToEdit {
            exam.subject = subject
            exam.colorHex = colorHex
            exam.topic = topic
            exam.date = date
            exam.notes = notes
        } else {
            let new = Exam(
                subject: subject,
                colorHex: colorHex,
                topic: topic,
                date: date,
                notes: notes,
                term: term
            )
            modelContext.insert(new)
        }
        dismiss()
    }

    private func deleteExam() {
        if let exam = examToEdit {
            modelContext.delete(exam)
        }
        dismiss()
    }
}

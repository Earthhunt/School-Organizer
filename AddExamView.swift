import SwiftUI
import SwiftData

struct AddExamView: View {
    let term: Term
    var examToEdit: Exam? = nil
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var subject = ""
    @State private var colorHex = "#4F8EF7"
    @State private var topic = ""
    @State private var date = Calendar.current.startOfDay(for: .now)
    @State private var notes = ""
    
    @State private var status: ExamStatus = .notStarted
    @State private var gradeString = ""
    @State private var weight: Double = 10.0
    
    private var isEditing: Bool { examToEdit != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basis Infos") {
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
                    TextField("Thema (z.B. Analysis)", text: $topic)
                }
                
                Section("Termin & Status") {
                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                    
                    Picker("Lernstatus", selection: $status) {
                        ForEach(ExamStatus.allCases, id: \.self) { s in
                            Label(s.rawValue, systemImage: s.icon)
                                .tag(s)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Bewertung") {
                    HStack {
                        Text("Note")
                        Spacer()
                        TextField("z.B. 2,0", text: $gradeString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Gewichtung (%)")
                        Spacer()
                        HStack(spacing: 10) {
                            Text("\(Int(weight))%")
                                .font(.system(.body, design: .monospaced))
                                .frame(width: 40)
                            
                            Stepper("", value: $weight, in: 1...100, step: 1)
                                .labelsHidden()
                        }
                        .frame(width: 120)
                    }
                }
                
                Section("Notizen") {
                    TextField("z.B. Taschenrechner mitbringen...", text: $notes, axis: .vertical)
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
        status = exam.status
        weight = exam.weight
        if let g = exam.grade {
            gradeString = String(g)
        }
    }
    
    private func save() {
        let finalGrade = Double(gradeString.replacingOccurrences(of: ",", with: "."))
        
        if let exam = examToEdit {
            exam.subject = subject
            exam.colorHex = colorHex
            exam.topic = topic
            exam.date = date
            exam.notes = notes
            exam.status = status
            exam.weight = weight
            exam.grade = finalGrade
        } else {
            let new = Exam(
                subject: subject,
                colorHex: colorHex,
                topic: topic,
                date: date,
                notes: notes,
                term: term
            )
            new.status = status
            new.weight = weight
            new.grade = finalGrade
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

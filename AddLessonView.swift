import SwiftUI
import SwiftData

struct AddLessonView: View {
    let term: Term
    var lessonToEdit: Lesson? = nil
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var subject = ""
    @State private var colorHex = "#4F8EF7"
    @State private var room = ""
    @State private var teacher = "" // NEU: Pflichtfeld aus Modell
    @State private var weekday = 1 // NEU: Pflichtfeld aus Modell (1=Mo, 5=Fr)
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    private var isEditing: Bool { lessonToEdit != nil }
    
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
                
                Section("Details") {
                    TextField("Raum (z.B. 102)", text: $room)
                    TextField("Lehrer", text: $teacher)
                    
                    Picker("Wochentag", selection: $weekday) {
                        ForEach(1...5, id: \.self) { day in
                            Text(Lesson.weekdayNames[day]).tag(day)
                        }
                    }
                }
                
                Section("Zeit") {
                    DatePicker("Start", selection: $startTime)
                    DatePicker("Ende", selection: $endTime)
                }
                
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            deleteLesson()
                        } label: {
                            Label("Lektion löschen", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Lektion bearbeiten" : "Neue Lektion")
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
        guard let lesson = lessonToEdit else { return }
        subject = lesson.subject
        colorHex = lesson.colorHex
        room = lesson.room
        teacher = lesson.teacher
        weekday = lesson.weekday
        startTime = lesson.startTime
        endTime = lesson.endTime
    }
    
    private func save() {
        if let lesson = lessonToEdit {
            lesson.subject = subject
            lesson.colorHex = colorHex
            lesson.room = room
            lesson.teacher = teacher
            lesson.weekday = weekday
            lesson.startTime = startTime
            lesson.endTime = endTime
        } else {
            let new = Lesson(
                subject: subject,
                room: room,
                teacher: teacher,
                weekday: weekday,
                startTime: startTime,
                endTime: endTime,
                colorHex: colorHex,
                term: term
            )
            modelContext.insert(new)
        }
        dismiss()
    }
    
    private func deleteLesson() {
        if let lesson = lessonToEdit {
            modelContext.delete(lesson)
        }
        dismiss()
    }
}

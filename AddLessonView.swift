//
//  AddLessonView.swift
//  School Organizer
//
//  Hinzufügen ODER Bearbeiten einer Schulstunde (inkl. Löschen).
//

import SwiftUI
import SwiftData

struct AddLessonView: View {
    let term: Term
    var lessonToEdit: Lesson? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var subject = ""
    @State private var room = ""
    @State private var teacher = ""
    @State private var weekday = 1
    @State private var startTime = defaultTime(hour: 8, minute: 0)
    @State private var endTime = defaultTime(hour: 8, minute: 45)
    @State private var colorHex = lessonColors[0]

    private var isEditing: Bool { lessonToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Fach") {
                    TextField("z.B. Mathe", text: $subject)
                    TextField("Raum (optional)", text: $room)
                    TextField("Lehrer:in (optional)", text: $teacher)
                }

                Section("Wann?") {
                    Picker("Wochentag", selection: $weekday) {
                        ForEach(1...5, id: \.self) { day in
                            Text(Lesson.weekdayNames[day]).tag(day)
                        }
                    }
                    DatePicker("Beginn", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("Ende", selection: $endTime, displayedComponents: .hourAndMinute)
                }

                Section("Farbe") {
                    HStack {
                        ForEach(lessonColors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: colorHex == hex ? 3 : 0)
                                )
                                .onTapGesture {
                                    colorHex = hex
                                }
                        }
                    }
                }

                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            deleteLesson()
                        } label: {
                            Label("Stunde löschen", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Stunde bearbeiten" : "Neue Stunde")
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
        room = lesson.room
        teacher = lesson.teacher
        weekday = lesson.weekday
        startTime = lesson.startTime
        endTime = lesson.endTime
        colorHex = lesson.colorHex
    }

    private func save() {
        if let lesson = lessonToEdit {
            lesson.subject = subject
            lesson.room = room
            lesson.teacher = teacher
            lesson.weekday = weekday
            lesson.startTime = startTime
            lesson.endTime = endTime
            lesson.colorHex = colorHex
        } else {
            let newLesson = Lesson(
                subject: subject,
                room: room,
                teacher: teacher,
                weekday: weekday,
                startTime: startTime,
                endTime: endTime,
                colorHex: colorHex,
                term: term
            )
            modelContext.insert(newLesson)
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

func defaultTime(hour: Int, minute: Int) -> Date {
    Calendar.current.date(
        bySettingHour: hour, minute: minute, second: 0, of: Date()
    ) ?? Date()
}

//
//  DashboardView.swift
//  School Organizer
//

import SwiftUI
import SwiftData
import Combine

struct DashboardView: View {
    let term: Term
    @Binding var selection: TermSection?

    @State private var now = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var todayLessons: [Lesson] {
        guard let day = Lesson.todayWeekday else { return [] }
        return term.sortedLessons.filter { $0.weekday == day }
    }

    private var currentLesson: Lesson? {
        todayLessons.first { $0.isNow }
    }

    private var nextLesson: Lesson? {
        let cal = Calendar.current
        let nowMin = cal.component(.hour, from: now) * 60 + cal.component(.minute, from: now)
        return todayLessons.first {
            let s = cal.dateComponents([.hour, .minute], from: $0.startTime)
            return (s.hour ?? 0) * 60 + (s.minute ?? 0) > nowMin
        }
    }

    private var openHomeworks: [Homework] {
        term.homeworks.filter { !$0.isDone }.sorted { $0.dueDate < $1.dueDate }
    }
    private var overdueCount: Int {
        term.homeworks.filter { $0.isOverdue }.count
    }

    private var nextExam: Exam? {
        term.exams.filter { !$0.isPast }.sorted { $0.date < $1.date }.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(greeting)
                        .font(.largeTitle.bold())
                    Text(now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                currentNextCard
                statsRow

                if !todayLessons.isEmpty {
                    Button { selection = .timetable } label: {
                        sectionHeader("Heute", icon: "calendar", chevron: true)
                    }
                    .buttonStyle(.plain)

                    ForEach(todayLessons) { lesson in
                        Button { selection = .timetable } label: {
                            LessonMiniRow(lesson: lesson, highlight: lesson.isNow)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button { selection = .homework } label: {
                    sectionHeader("Offene Hausaufgaben", icon: "checklist", chevron: true)
                }
                .buttonStyle(.plain)

                if openHomeworks.isEmpty {
                    Text("Alles erledigt! 🎉")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(openHomeworks.prefix(5)) { hw in
                        Button { selection = .homework } label: {
                            HomeworkMiniRow(homework: hw)
                        }
                        .buttonStyle(.plain)
                    }
                    if openHomeworks.count > 5 {
                        Button("Alle \(openHomeworks.count) anzeigen") {
                            selection = .homework
                        }
                        .font(.subheadline)
                    }
                }

                if let exam = nextExam {
                    Button { selection = .exams } label: {
                        sectionHeader("Nächste Klausur", icon: "pencil.and.outline", chevron: true)
                    }
                    .buttonStyle(.plain)

                    Button { selection = .exams } label: {
                        ExamMiniRow(exam: exam)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Heute")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { now = $0 }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: now)
        switch hour {
        case 5..<11: return "Guten Morgen 👋"
        case 11..<17: return "Hallo 👋"
        case 17..<22: return "Guten Abend 👋"
        default: return "Hi 👋"
        }
    }

    @ViewBuilder
    private var currentNextCard: some View {
        if let lesson = currentLesson {
            Button { selection = .timetable } label: {
                infoCard(tag: "JETZT", lesson: lesson, tagColor: .green)
            }
            .buttonStyle(.plain)
        } else if let lesson = nextLesson {
            Button { selection = .timetable } label: {
                infoCard(tag: "ALS NÄCHSTES", lesson: lesson, tagColor: .blue)
            }
            .buttonStyle(.plain)
        } else if Lesson.todayWeekday == nil {
            calloutCard(text: "Wochenende – kein Unterricht. Genieß die freie Zeit! 😎")
        } else {
            calloutCard(text: "Keine weiteren Stunden heute. 🏠")
        }
    }

    private func infoCard(tag: String, lesson: Lesson, tagColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tag)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(tagColor)
                    .clipShape(Capsule())
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            Text(lesson.subject)
                .font(.title2.bold())
            HStack(spacing: 16) {
                Label(lesson.timeRangeString, systemImage: "clock")
                if !lesson.room.isEmpty { Label(lesson.room, systemImage: "mappin.and.ellipse") }
                if !lesson.teacher.isEmpty { Label(lesson.teacher, systemImage: "person") }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: lesson.colorHex).opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func calloutCard(text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.secondary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            Button { selection = .timetable } label: {
                statCard(value: "\(todayLessons.count)", label: "Stunden heute",
                         color: .blue, icon: "calendar")
            }
            .buttonStyle(.plain)

            Button { selection = .homework } label: {
                statCard(value: "\(openHomeworks.count)", label: "Offene HAs",
                         color: .orange, icon: "checklist")
            }
            .buttonStyle(.plain)

            Button { selection = .homework } label: {
                statCard(value: "\(overdueCount)", label: "Überfällig",
                         color: overdueCount > 0 ? .red : .green, icon: "exclamationmark.circle")
            }
            .buttonStyle(.plain)
        }
    }

    private func statCard(value: String, label: String, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(.title.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func sectionHeader(_ title: String, icon: String, chevron: Bool = false) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
            Spacer()
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
    }
}

struct LessonMiniRow: View {
    let lesson: Lesson
    var highlight: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: lesson.colorHex))
                .frame(width: 5, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.subject).font(.subheadline.bold())
                Text(lesson.timeRangeString + (lesson.room.isEmpty ? "" : " · \(lesson.room)"))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if highlight {
                Text("jetzt")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(.green).clipShape(Capsule())
            }
        }
        .padding(10)
        .background(highlight ? Color.green.opacity(0.12) : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct HomeworkMiniRow: View {
    let homework: Homework

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle")
                .foregroundStyle(Color(hex: homework.colorHex))
            VStack(alignment: .leading, spacing: 2) {
                Text(homework.subject).font(.subheadline.bold())
                if !homework.details.isEmpty {
                    Text(homework.details).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            Spacer()
            Text(homework.dueDescription)
                .font(.caption2)
                .foregroundStyle(homework.isOverdue ? .red : .secondary)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ExamMiniRow: View {
    let exam: Exam

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: exam.colorHex))
                .frame(width: 5, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(exam.subject).font(.subheadline.bold())
                Text(exam.topic.isEmpty
                     ? exam.date.formatted(.dateTime.day().month())
                     : exam.topic)
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(exam.countdownText)
                .font(.caption2.bold())
                .foregroundStyle(exam.daysUntil <= 2 ? .red : .blue)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

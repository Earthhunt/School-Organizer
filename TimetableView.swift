//
//  TimetableView.swift
//  School Organizer
//
//  Wochen-Grid mit roter "Jetzt"-Linie.
//

import SwiftUI
import SwiftData
import Combine

struct TimetableView: View {
    let term: Term

    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var lessonToEdit: Lesson?

    @State private var now = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private let hourHeight: CGFloat = 80
    private let timeColumnWidth: CGFloat = 56
    private let headerHeight: CGFloat = 36

    private var lessons: [Lesson] { term.sortedLessons }

    var body: some View {
        Group {
            if lessons.isEmpty {
                ContentUnavailableView(
                    "Noch keine Stunden",
                    systemImage: "calendar.badge.plus",
                    description: Text("Tippe oben rechts auf +, um deine erste Schulstunde hinzuzufügen.")
                )
            } else {
                gridView
            }
        }
        .navigationTitle("Stundenplan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddLessonView(term: term)
        }
        .sheet(item: $lessonToEdit) { lesson in
            AddLessonView(term: term, lessonToEdit: lesson)
        }
        .onReceive(timer) { now = $0 }
    }

    private var gridView: some View {
        let range = dayRange()
        let firstHour = range.first ?? 8
        let totalHeight = CGFloat(range.count) * hourHeight
        let nowOffset = currentTimeOffset(firstHour: firstHour, range: range)

        return ScrollView(.vertical) {
            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: headerHeight)
                    ZStack(alignment: .topTrailing) {
                        Color.clear.frame(width: timeColumnWidth, height: totalHeight)
                        ForEach(Array(range.enumerated()), id: \.offset) { idx, hour in
                            Text(String(format: "%02d:00", hour))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(height: 12)
                                .offset(y: CGFloat(idx) * hourHeight - 6)
                                .padding(.trailing, 6)
                        }
                        if let y = nowOffset {
                            Text(now.formatted(.dateTime.hour().minute()))
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4).padding(.vertical, 1)
                                .background(.red)
                                .clipShape(Capsule())
                                .offset(y: y - 8)
                        }
                    }
                }

                ForEach(1...5, id: \.self) { day in
                    VStack(spacing: 0) {
                        Text(Lesson.weekdayNames[day])
                            .font(.headline)
                            .foregroundStyle(day == Lesson.todayWeekday ? Color.red : .primary)
                            .frame(height: headerHeight)

                        ZStack(alignment: .top) {
                            ForEach(Array(range.enumerated()), id: \.offset) { idx, _ in
                                Divider()
                                    .offset(y: CGFloat(idx) * hourHeight)
                            }

                            ForEach(lessons.filter { $0.weekday == day }) { lesson in
                                LessonCard(lesson: lesson)
                                    .frame(height: cardHeight(lesson))
                                    .offset(y: cardOffset(lesson, firstHour: firstHour))
                                    .onTapGesture {
                                        lessonToEdit = lesson
                                    }
                                    .contextMenu {
                                        Button {
                                            lessonToEdit = lesson
                                        } label: {
                                            Label("Bearbeiten", systemImage: "pencil")
                                        }
                                        Button(role: .destructive) {
                                            modelContext.delete(lesson)
                                        } label: {
                                            Label("Löschen", systemImage: "trash")
                                        }
                                    }
                            }

                            if day == Lesson.todayWeekday, let y = nowOffset {
                                NowLine()
                                    .offset(y: y)
                            }
                        }
                        .frame(height: totalHeight, alignment: .top)
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) { Divider() }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            .padding(.bottom, 20)
        }
    }

    private func dayRange() -> [Int] {
        let cal = Calendar.current
        let startHours = lessons.map { cal.component(.hour, from: $0.startTime) }
        let endHours = lessons.map { lesson -> Int in
            let h = cal.component(.hour, from: lesson.endTime)
            let m = cal.component(.minute, from: lesson.endTime)
            return m > 0 ? h + 1 : h
        }
        let minHour = min(startHours.min() ?? 8, 8)
        let maxHour = max(endHours.max() ?? 16, 16)
        return Array(minHour...maxHour)
    }

    private func cardHeight(_ lesson: Lesson) -> CGFloat {
        let minutes = lesson.endTime.timeIntervalSince(lesson.startTime) / 60
        return max(CGFloat(minutes) / 60 * hourHeight, 24)
    }

    private func cardOffset(_ lesson: Lesson, firstHour: Int) -> CGFloat {
        let cal = Calendar.current
        let h = cal.component(.hour, from: lesson.startTime)
        let m = cal.component(.minute, from: lesson.startTime)
        let minutesFromTop = (h - firstHour) * 60 + m
        return CGFloat(minutesFromTop) / 60 * hourHeight
    }

    private func currentTimeOffset(firstHour: Int, range: [Int]) -> CGFloat? {
        let cal = Calendar.current
        let h = cal.component(.hour, from: now)
        let m = cal.component(.minute, from: now)
        guard h >= firstHour, h <= (range.last ?? 16) else { return nil }
        let minutesFromTop = (h - firstHour) * 60 + m
        return CGFloat(minutesFromTop) / 60 * hourHeight
    }
}

struct NowLine: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.red)
                .frame(height: 2)
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .offset(x: -2)
        }
    }
}

struct LessonCard: View {
    let lesson: Lesson

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(lesson.subject)
                .font(.subheadline.bold())
                .lineLimit(1)
            if !lesson.room.isEmpty {
                Text(lesson.room)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !lesson.teacher.isEmpty {
                Text(lesson.teacher)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: lesson.colorHex).opacity(0.25))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color(hex: lesson.colorHex))
                .frame(width: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 3)
        .contentShape(Rectangle())
    }
}

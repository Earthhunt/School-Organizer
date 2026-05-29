//
//  TermView.swift
//  School Organizer
//

import SwiftUI
import SwiftData

struct TermView: View {
    let term: Term

    @Environment(\.dismiss) private var dismiss
    @State private var selection: TermSection? = .today

    var body: some View {
        NavigationSplitView {
            List(TermSection.allCases, selection: $selection) { section in
                NavigationLink(value: section) {
                    Label(section.title, systemImage: section.icon)
                }
            }
            .navigationTitle(term.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        } detail: {
            switch selection ?? .today {
            case .today:
                DashboardView(term: term, selection: $selection)
            case .timetable:
                TimetableView(term: term)
            case .homework:
                HomeworkView(term: term)
            case .exams:
                PlaceholderView(title: "Klausuren", icon: "pencil.and.outline",
                                text: "Kommt in Etappe 5.")
            case .grades:
                PlaceholderView(title: "Noten", icon: "graduationcap",
                                text: "Kommt in Etappe 4 (System: \(term.gradeSystem.title)).")
            case .settings:
                PlaceholderView(title: "Einstellungen", icon: "gearshape",
                                text: "Term-Einstellungen kommen später.")
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

enum TermSection: String, CaseIterable, Identifiable {
    case today, timetable, homework, exams, grades, settings
    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:     return "Heute"
        case .timetable: return "Stundenplan"
        case .homework:  return "Hausaufgaben"
        case .exams:     return "Klausuren"
        case .grades:    return "Noten"
        case .settings:  return "Einstellungen"
        }
    }
    var icon: String {
        switch self {
        case .today:     return "sun.max"
        case .timetable: return "calendar"
        case .homework:  return "checklist"
        case .exams:     return "pencil.and.outline"
        case .grades:    return "graduationcap"
        case .settings:  return "gearshape"
        }
    }
}

struct PlaceholderView: View {
    let title: String
    let icon: String
    let text: String
    var body: some View {
        ContentUnavailableView(title, systemImage: icon, description: Text(text))
            .navigationTitle(title)
    }
}

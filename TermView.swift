import SwiftUI
import SwiftData

struct TermView: View {
    let term: Term
    @Environment(\.dismiss) private var dismiss
    @State private var selection: TermSection? = .today
    
    // NEU: Enum für alle Verwaltungs-Ansichten
    enum ManagementView {
        case subjects, teachers, rooms
    }
    @State private var activeManagementView: ManagementView? = nil
    
    var body: some View {
        NavigationSplitView {
            List(TermSection.allCases, selection: $selection) { section in
                NavigationLink(value: section) {
                    Label(section.title, systemImage: section.icon)
                }
            }
            .navigationTitle(term.name)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selection) { _, _ in
                activeManagementView = nil // Schließt Verwaltung bei Tab-Wechsel
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                }
            }
        } detail: {
            if let management = activeManagementView {
                switch management {
                case .subjects:
                    SubjectsView(term: term, onBack: { activeManagementView = nil })
                case .teachers:
                    TeachersView(onBack: { activeManagementView = nil })
                case .rooms:
                    RoomsView(onBack: { activeManagementView = nil })
                }
            } else {
                NavigationStack {
                    switch selection ?? .today {
                    case .today: DashboardView(term: term, selection: $selection)
                    case .timetable: TimetableView(term: term)
                    case .homework: HomeworkView(term: term)
                    case .exams: ExamView(term: term)
                    case .grades: GradesView(term: term)
                    case .settings:
                        SettingsView(term: term, onManage: { view in
                            activeManagementView = view
                        })
                    }
                }
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
        case .today: return "Heute"
        case .timetable: return "Stundenplan"
        case .homework: return "Hausaufgaben"
        case .exams: return "Klausuren"
        case .grades: return "Noten"
        case .settings: return "Einstellungen"
        }
    }
    var icon: String {
        switch self {
        case .today: return "sun.max"
        case .timetable: return "calendar"
        case .homework: return "checklist"
        case .exams: return "pencil.and.outline"
        case .grades: return "graduationcap"
        case .settings: return "gearshape"
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

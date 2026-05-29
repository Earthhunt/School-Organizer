import Foundation
import SwiftData

@Model
class Term {
    var name: String
    var gradeSystemRaw: String
    var createdAt: Date
    
    // Verbindung zu den Fächern
    @Relationship(deleteRule: .cascade, inverse: \Subject.term)
    var subjects: [Subject] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Lesson.term)
    var lessons: [Lesson] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Homework.term)
    var homeworks: [Homework] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Exam.term)
    var exams: [Exam] = []
    
    init(name: String, gradeSystem: GradeSystem = .grades16, createdAt: Date = .now) {
        self.name = name
        self.gradeSystemRaw = gradeSystem.rawValue
        self.createdAt = createdAt
    }
}

extension Term {
    var gradeSystem: GradeSystem {
        get { GradeSystem(rawValue: gradeSystemRaw) ?? .grades16 }
        set { gradeSystemRaw = newValue.rawValue }
    }
    
    var sortedLessons: [Lesson] {
        lessons.sorted { $0.startTime < $1.startTime }
    }
}

enum GradeSystem: String, CaseIterable, Identifiable {
    case grades16
    case points15
    var id: String { rawValue }
    var title: String {
        switch self {
        case .grades16: return "Noten 1–6"
        case .points15: return "Punkte 0–15"
        }
    }
}

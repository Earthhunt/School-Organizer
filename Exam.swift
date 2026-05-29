import Foundation
import SwiftData

enum ExamStatus: String, Codable, CaseIterable {
    case notStarted = "Nicht gestartet"
    case learning = "Lerne gerade"
    case ready = "Bereit!"
    
    var icon: String {
        switch self {
        case .notStarted: return "circle"
        case .learning: return "pencil.and.outline"
        case .ready: return "checkmark.circle.fill"
        }
    }
    
    var colorName: String {
        switch self {
        case .notStarted: return "gray"
        case .learning: return "orange"
        case .ready: return "green"
        }
    }
}

@Model
class Exam {
    var subject: String
    var colorHex: String
    var topic: String
    var date: Date
    var notes: String
    var createdAt: Date
    var term: Term?
    
    var status: ExamStatus = ExamStatus.notStarted
    var grade: Double?
    var weight: Double = 10.0
    
    @Relationship(deleteRule: .cascade)
    var attachments: [Attachment]? = []
    
    init(subject: String,
         colorHex: String = "#4F8EF7",
         topic: String = "",
         date: Date,
         notes: String = "",
         createdAt: Date = .now,
         term: Term? = nil) {
        self.subject = subject
        self.colorHex = colorHex
        self.topic = topic
        self.date = date
        self.notes = notes
        self.createdAt = createdAt
        self.term = term
    }
}

extension Exam {
    var isPast: Bool {
        date < Calendar.current.startOfDay(for: .now)
    }
    
    var daysUntil: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let examDay = cal.startOfDay(for: date)
        return cal.dateComponents([.day], from: today, to: examDay).day ?? 0
    }
    
    var countdownText: String {
        let d = daysUntil
        switch d {
        case 0: return "Heute!"
        case 1: return "Morgen"
        case let x where x > 1: return "In \(x) Tagen"
        case -1: return "Gestern"
        default: return "Vor \(-d) Tagen"
        }
    }
}

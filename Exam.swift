//
//  Exam.swift
//  School Organizer
//

import Foundation
import SwiftData

@Model
class Exam {
    var subject: String
    var colorHex: String
    var topic: String
    var date: Date
    var notes: String
    var createdAt: Date

    var term: Term?

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

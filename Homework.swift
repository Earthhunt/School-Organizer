//
//  Homework.swift
//  School Organizer
//

import Foundation
import SwiftData

@Model
class Homework {
    var subject: String
    var colorHex: String
    var details: String
    var notes: String
    var dueDate: Date
    var isDone: Bool
    var createdAt: Date

    var term: Term?

    @Relationship(deleteRule: .cascade, inverse: \Attachment.homework)
    var attachments: [Attachment] = []

    init(subject: String,
         colorHex: String = "#4F8EF7",
         details: String,
         notes: String = "",
         dueDate: Date,
         isDone: Bool = false,
         createdAt: Date = .now,
         term: Term? = nil) {
        self.subject = subject
        self.colorHex = colorHex
        self.details = details
        self.notes = notes
        self.dueDate = dueDate
        self.isDone = isDone
        self.createdAt = createdAt
        self.term = term
    }
}

extension Homework {
    var isOverdue: Bool {
        !isDone && dueDate < Calendar.current.startOfDay(for: .now)
    }

    var dueDescription: String {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let due = cal.startOfDay(for: dueDate)
        let days = cal.dateComponents([.day], from: today, to: due).day ?? 0

        if isDone { return "Erledigt" }
        switch days {
        case 0: return "Heute fällig"
        case 1: return "Morgen fällig"
        case let d where d > 1: return "In \(d) Tagen"
        case -1: return "Überfällig seit gestern"
        default: return "Überfällig seit \(-days) Tagen"
        }
    }
}

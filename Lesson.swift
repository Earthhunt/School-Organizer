//
//  Lesson.swift
//  School Organizer
//

import Foundation
import SwiftData

@Model
class Lesson {
    var subject: String
    var room: String
    var teacher: String
    var weekday: Int
    var startTime: Date
    var endTime: Date
    var colorHex: String
    var term: Term?

    init(subject: String,
         room: String,
         teacher: String,
         weekday: Int,
         startTime: Date,
         endTime: Date,
         colorHex: String = "#4F8EF7",
         term: Term? = nil) {
        self.subject = subject
        self.room = room
        self.teacher = teacher
        self.weekday = weekday
        self.startTime = startTime
        self.endTime = endTime
        self.colorHex = colorHex
        self.term = term
    }
}

extension Lesson {
    static let weekdayNames = ["", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"]

    var weekdayName: String {
        guard weekday >= 1 && weekday <= 5 else { return "?" }
        return Lesson.weekdayNames[weekday]
    }

    var timeRangeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return "\(f.string(from: startTime)) – \(f.string(from: endTime))"
    }
}

// Hilfen rund um den heutigen Wochentag
extension Lesson {
    // Heutiger Wochentag als 1=Mo ... 5=Fr (oder nil am Wochenende)
    static var todayWeekday: Int? {
        let cal = Calendar.current
        let w = cal.component(.weekday, from: .now) // 1=So,2=Mo,...,7=Sa
        let mapped = w - 1                            // Mo=1 ... Sa=6, So=0
        return (1...5).contains(mapped) ? mapped : nil
    }

    // Läuft diese Stunde gerade JETZT?
    var isNow: Bool {
        guard weekday == Lesson.todayWeekday else { return false }
        let cal = Calendar.current
        let now = cal.dateComponents([.hour, .minute], from: .now)
        let nowMin = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        let s = cal.dateComponents([.hour, .minute], from: startTime)
        let e = cal.dateComponents([.hour, .minute], from: endTime)
        let sMin = (s.hour ?? 0) * 60 + (s.minute ?? 0)
        let eMin = (e.hour ?? 0) * 60 + (e.minute ?? 0)
        return nowMin >= sMin && nowMin < eMin
    }
}

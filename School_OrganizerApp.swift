//
//  School_OrganizerApp.swift
//  School Organizer
//

import SwiftUI
import SwiftData

@main
struct School_OrganizerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Term.self, Lesson.self, Homework.self, Attachment.self])
    }
}

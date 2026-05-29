import Foundation
import SwiftData

@Model
class GlobalTeacher {
    var name: String
    var primarySubject: String? // Optionales Hauptfach
    
    init(name: String, primarySubject: String? = nil) {
        self.name = name
        self.primarySubject = primarySubject
    }
}

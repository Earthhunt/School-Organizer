import Foundation
import SwiftData
import SwiftUI

@Model
class Subject {
    var name: String
    var colorHex: String
    var term: Term?
    
    init(name: String, colorHex: String = "#4F8EF7", term: Term? = nil) {
        self.name = name
        self.colorHex = colorHex
        self.term = term
    }
}

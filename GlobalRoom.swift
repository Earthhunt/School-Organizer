import Foundation
import SwiftData

@Model
class GlobalRoom {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

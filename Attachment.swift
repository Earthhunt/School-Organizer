//
//  Attachment.swift
//  School Organizer
//

import Foundation
import SwiftData

enum AttachmentType: String, Codable {
    case image
    case file
}

@Model
class Attachment {
    var filename: String
    @Attribute(.externalStorage) var data: Data
    var typeRaw: String
    var createdAt: Date

    var homework: Homework?

    init(filename: String,
         data: Data,
         type: AttachmentType,
         createdAt: Date = .now,
         homework: Homework? = nil) {
        self.filename = filename
        self.data = data
        self.typeRaw = type.rawValue
        self.createdAt = createdAt
        self.homework = homework
    }

    var type: AttachmentType {
        AttachmentType(rawValue: typeRaw) ?? .file
    }
}

//
//  Color+Hex.swift
//  School Organizer
//
//  Damit wir Farben als Text speichern können ("#FF0000" = rot).
//

import SwiftUI

extension Color {
    // Erzeugt eine Color aus einem Hex-String wie "#4F8EF7"
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
        let r, g, b: UInt64
        if hexString.count == 6 {
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        } else {
            r = 79; g = 142; b = 247   // Standard-Blau, falls was schiefgeht
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

// Eine kleine Auswahl an Farben, die der Nutzer für Fächer aussuchen kann
let lessonColors: [String] = [
    "#4F8EF7", // Blau
    "#F77F4F", // Orange
    "#4FCF7F", // Grün
    "#CF4F9F", // Pink
    "#9F4FCF", // Lila
    "#F7C84F"  // Gelb
]

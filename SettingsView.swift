import SwiftUI

struct SettingsView: View {
    let term: Term
    var onManage: (TermView.ManagementView) -> Void
    
    var body: some View {
        List {
            Section("Diesen Plan anpassen") {
                Button {
                    onManage(.subjects)
                } label: {
                    Label("Fächer verwalten", systemImage: "book.closed.fill")
                        .foregroundStyle(.primary)
                }
            }
            
            Section("Globale Bibliothek") {
                Button {
                    onManage(.teachers)
                } label: {
                    Label("Lehrer-Verzeichnis", systemImage: "person.2.fill")
                        .foregroundStyle(.primary)
                }
                
                Button {
                    onManage(.rooms)
                } label: {
                    Label("Raum-Verzeichnis", systemImage: "door.left.hand.open")
                        .foregroundStyle(.primary)
                }
            }
            
            Section("App-Einstellungen") {
                Text("Hier kommen später allgemeine Einstellungen hin.")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .navigationTitle("Einstellungen")
    }
}

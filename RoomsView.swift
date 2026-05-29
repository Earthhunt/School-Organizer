import SwiftUI
import SwiftData

struct RoomsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GlobalRoom.name) private var rooms: [GlobalRoom]
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddRoom = false
    
    var body: some View {
        NavigationStack {
            List {
                if rooms.isEmpty {
                    ContentUnavailableView("Keine Räume", systemImage: "door.left.hand.open", description: Text("Lege deine globalen Räume an."))
                } else {
                    ForEach(rooms) { room in
                        Text(room.name).font(.headline)
                    }
                    .onDelete(perform: deleteRooms)
                }
            }
            .navigationTitle("Räume verwalten")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Zurück") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddRoom = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAddRoom) {
                AddRoomView()
            }
        }
    }
    
    private func deleteRooms(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(rooms[index]) }
    }
}

struct AddRoomView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Raumname (z.B. 102)", text: $name)
            }
            .navigationTitle("Neuer Raum")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        modelContext.insert(GlobalRoom(name: name))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

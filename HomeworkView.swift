//
//  HomeworkView.swift
//  School Organizer
//

import SwiftUI
import SwiftData

struct HomeworkView: View {
    let term: Term

    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var homeworkToEdit: Homework?

    private var openItems: [Homework] {
        term.homeworks.filter { !$0.isDone }.sorted { $0.dueDate < $1.dueDate }
    }
    private var doneItems: [Homework] {
        term.homeworks.filter { $0.isDone }.sorted { $0.dueDate > $1.dueDate }
    }

    var body: some View {
        Group {
            if term.homeworks.isEmpty {
                ContentUnavailableView(
                    "Keine Hausaufgaben",
                    systemImage: "checklist",
                    description: Text("Tippe oben rechts auf +, um eine Hausaufgabe hinzuzufügen.")
                )
            } else {
                List {
                    if !openItems.isEmpty {
                        Section("Offen") {
                            ForEach(openItems) { hw in
                                row(hw)
                            }
                        }
                    }
                    if !doneItems.isEmpty {
                        Section("Erledigt") {
                            ForEach(doneItems) { hw in
                                row(hw)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Hausaufgaben")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddHomeworkView(term: term)
        }
        .sheet(item: $homeworkToEdit) { hw in
            AddHomeworkView(term: term, homeworkToEdit: hw)
        }
    }

    private func row(_ hw: Homework) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { hw.isDone.toggle() }
            } label: {
                Image(systemName: hw.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(hw.isDone ? Color.green : Color(hex: hw.colorHex))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(hw.subject)
                    .font(.headline)
                    .foregroundStyle(hw.isDone ? .secondary : .primary)
                if !hw.details.isEmpty {
                    Text(hw.details)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .strikethrough(hw.isDone)
                }
                Text(hw.dueDescription)
                    .font(.caption)
                    .foregroundStyle(hw.isOverdue ? .red : .secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture { homeworkToEdit = hw }
        .contextMenu {
            Button {
                homeworkToEdit = hw
            } label: {
                Label("Bearbeiten", systemImage: "pencil")
            }
            Button(role: .destructive) {
                modelContext.delete(hw)
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(hw)
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
}

//
//  ContentView.swift
//  School Organizer
//
//  EBENE 1: Startbildschirm mit Liste aller Terms.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: [SortDescriptor(\Term.createdAt)])
    private var terms: [Term]

    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTerm = false

    var body: some View {
        NavigationStack {
            Group {
                if terms.isEmpty {
                    ContentUnavailableView(
                        "Keine Stundenpläne",
                        systemImage: "books.vertical",
                        description: Text("Tippe auf +, um deinen ersten Stundenplan anzulegen (z.B. „Klasse 10“ oder „Q1“).")
                    )
                } else {
                    List {
                        ForEach(terms) { term in
                            NavigationLink(value: term) {
                                TermRow(term: term)
                            }
                        }
                        .onDelete(perform: deleteTerms)
                    }
                }
            }
            .navigationTitle("Meine Stundenpläne")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTerm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Term.self) { term in
                TermView(term: term)
            }
            .sheet(isPresented: $showingAddTerm) {
                AddTermView()
            }
        }
    }

    private func deleteTerms(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(terms[index])
        }
    }
}

struct TermRow: View {
    let term: Term

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "calendar")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(term.name)
                    .font(.headline)
                Text("\(term.lessons.count) Stunden · \(term.gradeSystem.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

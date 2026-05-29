//
//  AddHomeworkView.swift
//  School Organizer
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddHomeworkView: View {
    let term: Term
    var homeworkToEdit: Homework? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var subject = ""
    @State private var colorHex = lessonColors[0]
    @State private var details = ""
    @State private var notes = ""
    @State private var dueDate = Calendar.current.startOfDay(for: .now)

    @State private var pendingAttachments: [Attachment] = []

    @State private var photoItems: [PhotosPickerItem] = []
    @State private var showingFileImporter = false
    @State private var previewAttachment: Attachment?

    private var isEditing: Bool { homeworkToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Fach") {
                    if !term.subjects.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(term.subjects, id: \.name) { sub in
                                    Button {
                                        subject = sub.name
                                        colorHex = sub.colorHex
                                    } label: {
                                        Text(sub.name)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color(hex: sub.colorHex).opacity(subject == sub.name ? 0.5 : 0.2))
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    TextField("Fach (z.B. Mathe)", text: $subject)
                }

                Section("Aufgabe") {
                    TextField("z.B. Buch S. 30–32 lesen", text: $details, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section("Notizen") {
                    TextField("Zusätzliche Notizen …", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Fällig am") {
                    DatePicker("Datum", selection: $dueDate, displayedComponents: .date)
                }

                Section("Anhänge") {
                    ForEach(pendingAttachments) { att in
                        AttachmentRow(attachment: att)
                            .contentShape(Rectangle())
                            .onTapGesture { previewAttachment = att }
                    }
                    .onDelete { offsets in
                        pendingAttachments.remove(atOffsets: offsets)
                    }

                    PhotosPicker(selection: $photoItems, maxSelectionCount: 5, matching: .images) {
                        Label("Bild hinzufügen", systemImage: "photo")
                    }

                    Button {
                        showingFileImporter = true
                    } label: {
                        Label("Datei hinzufügen", systemImage: "doc")
                    }
                }

                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            deleteHomework()
                        } label: {
                            Label("Hausaufgabe löschen", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Hausaufgabe bearbeiten" : "Neue Hausaufgabe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
                        .disabled(subject.isEmpty)
                }
            }
            .onAppear(perform: loadIfEditing)
            .onChange(of: photoItems) { _, newItems in
                Task { await loadPhotos(newItems) }
            }
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.pdf, .plainText, .data],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
            .sheet(item: $previewAttachment) { att in
                AttachmentPreview(attachment: att)
            }
        }
    }

    private func loadIfEditing() {
        guard let hw = homeworkToEdit else { return }
        subject = hw.subject
        colorHex = hw.colorHex
        details = hw.details
        notes = hw.notes
        dueDate = hw.dueDate
        pendingAttachments = hw.attachments
    }

    private func save() {
        let hw: Homework
        if let existing = homeworkToEdit {
            hw = existing
            hw.subject = subject
            hw.colorHex = colorHex
            hw.details = details
            hw.notes = notes
            hw.dueDate = dueDate
        } else {
            hw = Homework(
                subject: subject,
                colorHex: colorHex,
                details: details,
                notes: notes,
                dueDate: dueDate,
                term: term
            )
            modelContext.insert(hw)
        }
        hw.attachments = pendingAttachments
        for att in pendingAttachments { att.homework = hw }
        dismiss()
    }

    private func deleteHomework() {
        if let hw = homeworkToEdit {
            modelContext.delete(hw)
        }
        dismiss()
    }

    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let name = "Bild_\(Int(Date().timeIntervalSince1970)).jpg"
                let att = Attachment(filename: name, data: data, type: .image)
                await MainActor.run { pendingAttachments.append(att) }
            }
        }
        await MainActor.run { photoItems = [] }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result else { return }
        for url in urls {
            let needsStop = url.startAccessingSecurityScopedResource()
            defer { if needsStop { url.stopAccessingSecurityScopedResource() } }
            if let data = try? Data(contentsOf: url) {
                let att = Attachment(filename: url.lastPathComponent, data: data, type: .file)
                pendingAttachments.append(att)
            }
        }
    }
}

struct AttachmentRow: View {
    let attachment: Attachment

    var body: some View {
        HStack(spacing: 12) {
            if attachment.type == .image, let uiImage = UIImage(data: attachment.data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 44, height: 44)
            }
            Text(attachment.filename)
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
        }
    }
}

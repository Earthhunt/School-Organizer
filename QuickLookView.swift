//
//  QuickLookView.swift
//  School Organizer
//
//  Zeigt einen Anhang (Bild/PDF/Datei) in der iOS-Vollvorschau (QuickLook).
//

import SwiftUI
import QuickLook

struct AttachmentPreview: View {
    let attachment: Attachment

    @Environment(\.dismiss) private var dismiss
    @State private var fileURL: URL?

    var body: some View {
        NavigationStack {
            Group {
                if let url = fileURL {
                    QuickLookPreview(url: url)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(attachment.filename)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
        .onAppear(perform: writeTempFile)
    }

    private func writeTempFile() {
        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent(attachment.filename)
        do {
            try attachment.data.write(to: url, options: .atomic)
            fileURL = url
        } catch {
            print("Konnte temporäre Datei nicht schreiben: \(error)")
        }
    }
}

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator { Coordinator(url: url) }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: QLPreviewController, context: Context) {
        context.coordinator.url = url
        controller.reloadData()
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        var url: URL
        init(url: URL) { self.url = url }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController,
                               previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}

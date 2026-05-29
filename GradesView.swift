import SwiftUI
import SwiftData

struct GradesView: View {
    let term: Term
    @Query(sort: \Exam.date) private var allExams: [Exam]
    
    // Nur Klausuren dieses Terms, die bereits eine Note haben
    var gradedExams: [Exam] {
        allExams.filter { $0.term?.id == term.id && $0.grade != nil }
    }
    
    // NEU: Erstellt eine Liste aller Fächer, die mindestens eine Note haben
    var subjectsWithGrades: [(name: String, colorHex: String)] {
        var seen = Set<String>()
        var result: [(String, String)] = []
        
        for exam in gradedExams {
            if !seen.contains(exam.subject) {
                seen.insert(exam.subject)
                result.append((exam.subject, exam.colorHex))
            }
        }
        return result
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if gradedExams.isEmpty {
                    ContentUnavailableView(
                        "Noch keine Noten",
                        systemImage: "graduationcap",
                        description: Text("Trage in deinen Klausuren Noten ein, um deinen Durchschnitt zu sehen.")
                    )
                } else {
                    List {
                        Section("Mein Durchschnitt pro Fach") {
                            // FIX: Wir iterieren jetzt über die Fächer, die tatsächlich Noten haben
                            ForEach(subjectsWithGrades, id: \.name) { subject in
                                GradeRow(subject: subject, exams: examsForSubject(subject.name), gradeSystem: term.gradeSystem)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notenübersicht")
        }
    }
    
    private func examsForSubject(_ subjectName: String) -> [Exam] {
        gradedExams.filter { $0.subject == subjectName }
    }
}

struct GradeRow: View {
    let subject: (name: String, colorHex: String)
    let exams: [Exam]
    let gradeSystem: GradeSystem
    
    var averageGrade: Double {
        guard !exams.isEmpty else { return 0.0 }
        var totalWeightedGrade = 0.0
        var totalWeight = 0.0
        
        for exam in exams {
            if let grade = exam.grade {
                totalWeightedGrade += grade * exam.weight
                totalWeight += exam.weight
            }
        }
        return totalWeight > 0 ? totalWeightedGrade / totalWeight : 0.0
    }
    
    var gradeColor: Color {
        if averageGrade == 0 { return .gray }
        if gradeSystem.title.contains("15") || gradeSystem.title.contains("Punkt") {
            if averageGrade >= 11.0 { return .green }
            if averageGrade >= 7.0 { return .orange }
            return .red
        } else {
            if averageGrade <= 2.0 { return .green }
            if averageGrade <= 3.5 { return .orange }
            return .red
        }
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: subject.colorHex))
                .frame(width: 10, height: 10)
            
            Text(subject.name)
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("Schnitt:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(String(format: "%.2f", averageGrade))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundStyle(gradeColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(gradeColor.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

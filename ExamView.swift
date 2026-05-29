import SwiftUI
import SwiftData

struct ExamView: View {
    let term: Term
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddExam = false
    @State private var examToEdit: Exam? = nil
    
    @Query(sort: \Exam.date) private var allExams: [Exam]
    
    var termExams: [Exam] {
        allExams.filter { $0.term?.id == term.id }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if termExams.isEmpty {
                    ContentUnavailableView(
                        "Keine Klausuren",
                        systemImage: "pencil.and.outline",
                        description: Text("Tippe auf +, um deine erste Klausur einzutragen.")
                    )
                } else {
                    List {
                        Section("Kommende Klausuren") {
                            ForEach(termExams.filter { !$0.isPast }) { exam in
                                ExamRow(exam: exam)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        examToEdit = exam
                                    }
                            }
                            .onDelete(perform: deleteExams)
                        }
                        
                        Section("Vergangene Klausuren") {
                            ForEach(termExams.filter { $0.isPast }) { exam in
                                ExamRow(exam: exam)
                                    .opacity(0.8)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        examToEdit = exam
                                    }
                            }
                            .onDelete(perform: deleteExams)
                        }
                    }
                }
            }
            .navigationTitle("Klausuren")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        examToEdit = nil
                        showingAddExam = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExam) {
                AddExamView(term: term)
            }
            .sheet(item: $examToEdit) { exam in
                AddExamView(term: term, examToEdit: exam)
            }
        }
    }
    
    private func deleteExams(at offsets: IndexSet) {
        for index in offsets {
            let exam = termExams[index]
            modelContext.delete(exam)
        }
    }
}

struct ExamRow: View {
    let exam: Exam
    
    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: exam.colorHex))
                .frame(width: 4, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(exam.subject)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Image(systemName: exam.status.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: exam.status.colorName == "green" ? "#34C759" : (exam.status.colorName == "orange" ? "#FF9500" : "#8E8E93")))
                }
                
                Text(exam.topic)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if let grade = exam.grade {
                    Text("Note: \(String(format: "%.1f", grade))")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
                
                Text("\(Int(exam.weight))%")
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .foregroundStyle(.secondary)
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(exam.date, format: .dateTime.day().month().year())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(exam.countdownText)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(exam.isPast ? Color.gray.opacity(0.2) : Color.blue.opacity(0.15))
                    .foregroundStyle(exam.isPast ? Color.secondary : Color.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 6)
    }
}

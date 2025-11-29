import SwiftUI

enum TaskStatus: String, CaseIterable {
    case todo
    case doing
    case done

    mutating func next() {
        switch self {
        case .todo: self = .doing
        case .doing: self = .done
        case .done: self = .todo
        }
    }

    var iconName: String {
        switch self {
        case .todo: return "circle"
        case .doing: return "clock.fill"
        case .done: return "checkmark.circle.fill"
        }
    }
}

struct TaskItem: Identifiable {
    let id: UUID
    var title: String
    var details: String
    var imageName: String
    var status: TaskStatus

    init(title: String, details: String, imageName: String, status: TaskStatus) {
        self.id = UUID()
        self.title = title
        self.details = details
        self.imageName = imageName
        self.status = status
    }
}

struct ContentView: View {
    @State private var tasks: [TaskItem] = [
        TaskItem(title: "Zrobic zakupy", details: "Mleko, chleb, jajka", imageName: "cart.fill", status: .todo),
        TaskItem(title: "Silownia", details: "FBW", imageName: "dumbbell.fill", status: .doing),
        TaskItem(title: "Nauka", details: "Nauka SwiftUI", imageName: "book.fill", status: .todo),
        TaskItem(title: "Posprzatac", details: "Odkurzanie", imageName: "sparkles", status: .done)
    ]

    @State private var showingAddAlert = false
    @State private var newTitle = ""
    @State private var newDetails = ""

    private var canAdd: Bool {
        !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks.indices, id: \.self) { index in
                    let task = tasks[index]

                    Button {
                        toggleStatus(at: index)
                    } label: {
                        HStack(spacing: 12) {
                            // Ikonka "zadania" (z 3.5)
                            Image(systemName: task.imageName)
                                .font(.system(size: 22))
                                .frame(width: 34, height: 34)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 6) {
                                Text(task.title)
                                    .font(.headline)

                                Text(task.details)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            // Ikonka statusu (żeby było widać, że zmiana działa)
                            Image(systemName: task.status.iconName)
                                .font(.system(size: 18))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteTasks)
            }
            .navigationTitle("Lista zadań")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        newTitle = ""
                        newDetails = ""
                        showingAddAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .alert("Dodaj zadanie", isPresented: $showingAddAlert) {
                TextField("Tytul", text: $newTitle)
                TextField("Opis", text: $newDetails)

                Button("Add") {
                    addTask()
                }
                .disabled(!canAdd)

                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Nowe zadanie startuje ze statusem TODO.")
            }
        }
    }

    private func toggleStatus(at index: Int) {
        tasks[index].status.next()
    }

    private func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    private func addTask() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let details = newDetails.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty else { return }

        let item = TaskItem(
            title: title,
            details: details.isEmpty ? "Brak opisu" : details,
            imageName: "checkmark.seal.fill",
            status: .todo
        )
        tasks.append(item)
    }
}

#Preview {
    ContentView()
}

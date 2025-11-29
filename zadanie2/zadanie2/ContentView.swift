import SwiftUI

struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    let details: String
    let iconName: String
}

struct ContentView: View {
    @State private var tasks: [TaskItem] = [
        TaskItem(title: "Zrobic zakupy", details: "Mleko, chleb, jajka", iconName: "cart.fill"),
        TaskItem(title: "Silownia", details: "FBW", iconName: "dumbbell.fill"),
        TaskItem(title: "Nauka", details: "Nauka SwiftUI", iconName: "book.fill"),
        TaskItem(title: "Posprzatac", details: "Odkurzanie", iconName: "sparkles")
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
                ForEach(tasks) { task in
                    HStack(spacing: 12) {
                        Image(systemName: task.iconName)
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
                    }
                    .padding(.vertical, 6)
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
                Text("Wpisz tytul i opis")
            }
        }
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
            iconName: "checkmark.circle.fill"
        )
        tasks.append(item)
    }
}

#Preview {
    ContentView()
}

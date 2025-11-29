import SwiftUI

struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    let details: String
}

struct ContentView: View {
    private let tasks: [TaskItem] = [
        TaskItem(title: "Zrobic zakupy", details: "Mleko, chleb, jajka"),
        TaskItem(title: "Silownia", details: "FBW"),
        TaskItem(title: "Nauka", details: "Nauka SwiftUI"),
        TaskItem(title: "Posprzatac", details: "Odkurzanie")
    ]

    var body: some View {
        NavigationStack {
            List(tasks) { task in
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title)
                        .font(.headline)

                    Text(task.details)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Lista zadań")
        }
    }
}

#Preview {
    ContentView()
}

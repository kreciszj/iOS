import SwiftUI

struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    let details: String
    let iconName: String
}

struct ContentView: View {
    private let tasks: [TaskItem] = [
        TaskItem(title: "Zrobic zakupy", details: "Mleko, chleb, jajka", iconName: "cart.fill"),
        TaskItem(title: "Silownia", details: "FBW", iconName: "dumbbell.fill"),
        TaskItem(title: "Nauka", details: "Nauka SwiftUI", iconName: "book.fill"),
        TaskItem(title: "Posprzatac", details: "Odkurzanie", iconName: "sparkles")
    ]

    var body: some View {
        NavigationStack {
            List(tasks) { task in
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
            .navigationTitle("Lista zadań")
        }
    }
}

#Preview {
    ContentView()
}

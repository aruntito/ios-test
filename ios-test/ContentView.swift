import SwiftUI

private struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

private enum TaskStore {
    private static let key = "pocket-tasks"

    static func load() -> [TaskItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let tasks = try? JSONDecoder().decode([TaskItem].self, from: data) else {
            return [
                TaskItem(title: "Explore SwiftUI"),
                TaskItem(title: "Build a native iOS app"),
                TaskItem(title: "Ship the first version")
            ]
        }
        return tasks
    }

    static func save(_ tasks: [TaskItem]) {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

struct ContentView: View {
    @State private var tasks = TaskStore.load()
    @State private var newTaskTitle = ""
    @State private var isShowingAddTask = false

    private var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                header

                if tasks.isEmpty {
                    ContentUnavailableView(
                        "Nothing on your list",
                        systemImage: "checkmark.circle",
                        description: Text("Add a task and make a little progress.")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach($tasks) { $task in
                            TaskRow(task: $task)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .contentMargins(.horizontal, -16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                    .accessibilityLabel("Add task")
                }
            }
            .sheet(isPresented: $isShowingAddTask) {
                addTaskSheet
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: tasks) { _, updatedTasks in
                TaskStore.save(updatedTasks)
            }
        }
        .tint(.indigo)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YOUR SPACE")
                .font(.caption.weight(.bold))
                .tracking(1.8)
                .foregroundStyle(.secondary)

            Text("Today, well spent.")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)

            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.indigo)
                Text("\(completedCount) of \(tasks.count) completed")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: tasks.isEmpty ? 0 : Double(completedCount) / Double(tasks.count))
                .tint(.indigo)
                .padding(.top, 4)
        }
        .padding(.bottom, 4)
    }

    private var addTaskSheet: some View {
        NavigationStack {
            Form {
                Section("New task") {
                    TextField("What needs doing?", text: $newTaskTitle)
                        .submitLabel(.done)
                        .onSubmit(addTask)
                }

                Section {
                    Text("Keep it small. You can always add more later.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add a task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newTaskTitle = ""
                        isShowingAddTask = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: addTask)
                        .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        withAnimation(.snappy) {
            tasks.insert(TaskItem(title: title), at: 0)
        }
        newTaskTitle = ""
        isShowingAddTask = false
    }

    private func deleteTasks(at offsets: IndexSet) {
        withAnimation(.snappy) {
            tasks.remove(atOffsets: offsets)
        }
    }
}

private struct TaskRow: View {
    @Binding var task: TaskItem

    var body: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.snappy) {
                    task.isCompleted.toggle()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .indigo : .tertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")

            Text(task.title)
                .font(.body.weight(.medium))
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .strikethrough(task.isCompleted, color: .secondary)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}

import SwiftUI

struct Goal: Identifiable {
    let id = UUID()
    var text: String
    var isCompleted: Bool
}

struct GoalTrackerCard: View {
    @State private var goals = [
        Goal(text: "Read for 30 minutes", isCompleted: false),
        Goal(text: "Exercise for 20 minutes", isCompleted: false),
        Goal(text: "Meditate for 10 minutes", isCompleted: true)
    ]
    @State private var newGoalText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily Goals")
                .font(.headline)
            Text("Track your progress towards better habits")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach($goals) { $goal in
                HStack {
                    Button(action: {
                        goal.isCompleted.toggle()
                    }) {
                        Image(systemName: goal.isCompleted ? "checkmark.square.fill" : "square")
                    }
                    .buttonStyle(.plain)
                    
                    Text(goal.text)
                        .strikethrough(goal.isCompleted)
                }
            }
            
            HStack {
                TextField("Add a new goal", text: $newGoalText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add") {
                    if !newGoalText.isEmpty {
                        goals.append(Goal(text: newGoalText, isCompleted: false))
                        newGoalText = ""
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
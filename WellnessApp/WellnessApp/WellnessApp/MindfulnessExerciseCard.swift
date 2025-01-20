import SwiftUI

struct MindfulnessExerciseCard: View {
    @State private var isActive = false
    @State private var timeRemaining = 60
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mindfulness Break")
                .font(.headline)
            Text("Take a moment to breathe and refocus")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(timeRemaining)s")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ProgressView(value: Double(60 - timeRemaining), total: 60)
            
            HStack {
                Button(action: {
                    isActive.toggle()
                }) {
                    Text(isActive ? "Pause" : "Start")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Reset") {
                    isActive = false
                    timeRemaining = 60
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .onReceive(timer) { _ in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isActive = false
                timeRemaining = 60
            }
        }
    }
}
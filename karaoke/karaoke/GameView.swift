import SwiftUI

struct SongGuess {
    let track: String
    var isCorrect: Bool? = nil
}

struct GameView: View {
    let tracks: [String]
    @State private var guesses: [SongGuess] = []
    @State private var currentIndex = 0
    @State private var showResults = false
    @State private var showReview = false
    @State private var showFeedback: Bool = false
    @State private var feedbackColor: Color = .clear
    @State private var isCooldown = false
    @State private var feedbackText: String = ""

    @Environment(\.dismiss) var dismiss
    @StateObject private var motionManager = MotionManager()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showResults || currentIndex >= guesses.count {
                VStack(spacing: 20) {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    Text("✅ Correct: \(guesses.filter { $0.isCorrect == true }.count)").foregroundColor(.white)
                    Text("❌ Incorrect: \(guesses.filter { $0.isCorrect == false }.count)").foregroundColor(.white)

                    HStack {
                        Button("Review Answers") {
                            showReview = true
                        }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Button("Done") {
                            dismiss()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Spacer()

                    if isCooldown {
                        Text(feedbackText)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(feedbackColor)
                            .rotationEffect(.degrees(90))
                            .multilineTextAlignment(.center)
                            .frame(width: UIScreen.main.bounds.height * 0.8, height: UIScreen.main.bounds.width * 0.5)
                    } else {
                        Text(guesses[currentIndex].track)
                            .font(.system(size: 48, weight: .bold))
                            .multilineTextAlignment(.center)
                            .rotationEffect(.degrees(90))
                            .frame(width: UIScreen.main.bounds.height * 0.8, height: UIScreen.main.bounds.width * 0.5)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button("Quit") {
                        showResults = true
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }

            // Feedback flash
            if showFeedback {
                feedbackColor
                    .opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            guesses = tracks.map { SongGuess(track: $0) }
            motionManager.startUpdates()
        }
        .onDisappear {
            motionManager.stopUpdates()
        }
        .onChange(of: motionManager.roll) { _, roll in
            guard !isCooldown, currentIndex < guesses.count else { return }

            if roll < -45 { // Tilted down = correct
                triggerFeedback(isCorrect: true)
            } else if roll > 45 { // Tilted up = incorrect
                triggerFeedback(isCorrect: false)
            }
        }
        .sheet(isPresented: $showReview) {
            ResultsView(guesses: guesses, motionManager: motionManager)
        }
    }

    func triggerFeedback(isCorrect: Bool) {
        isCooldown = true
        markAnswer(isCorrect: isCorrect)
        feedbackColor = isCorrect ? .green : .red
        showFeedback = true
        feedbackText = isCorrect ? "Correct ✅" : "Incorrect ❌"

        // Hide feedback after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showFeedback = false
        }

        // Prevent accidental multiple triggers by resetting pitch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            motionManager.roll = 0
        }
        
        // Reset cooldown after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isCooldown = false
            feedbackText = ""
        }
    }

    func markAnswer(isCorrect: Bool) {
        guesses[currentIndex].isCorrect = isCorrect
        currentIndex += 1
    }
}

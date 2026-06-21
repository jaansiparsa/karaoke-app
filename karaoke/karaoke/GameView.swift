import SwiftUI

struct SongGuess: Equatable, Hashable {
    let track: String
    var isCorrect: Bool? = nil
}

struct GameView: View {
    let tracks: [String]
    @Binding var path: NavigationPath

    @State private var guesses: [SongGuess] = []
    @State private var timeRemaining = 90
    @State private var currentIndex = 0
    @State private var isCooldown = false
    @State private var countdown = 3
    @State private var isCountingDown = true
    @State private var feedbackIsCorrect: Bool = true
    @State private var gameTimer: Timer?
    @State private var isGameOver = false

    @StateObject private var motionManager = MotionManager()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                (isCooldown
                    ? (feedbackIsCorrect ? Color.softGreen : Color.softRed)
                    : Color.backgroundBlue
                )
                .ignoresSafeArea()

                if isCountingDown {
                    VStack {
                        Spacer()
                        Text("Flip your screen in \(countdown)...")
                            .font(.custom("Unbounded", size: 40).weight(.bold))
                            .foregroundColor(.darkText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        Spacer()
                    }
                    .frame(width: geo.size.height, height: geo.size.width)
                    .rotationEffect(.degrees(90))
                    .frame(width: geo.size.width, height: geo.size.height)
                } else {
                    VStack(spacing: 0) {
                        // Timer at VStack top → appears ABOVE text in landscape
                        VStack(spacing: 6) {
                            Text("\(timeRemaining)s")
                                .font(.custom("Unbounded", size: 16).weight(.bold))
                                .foregroundColor(.darkText)
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.black.opacity(0.15))
                                Capsule()
                                    .fill(Color.tealDark)
                                    .frame(width: geo.size.height * 0.8 * CGFloat(timeRemaining) / 90.0)
                            }
                            .frame(width: geo.size.height * 0.8, height: 10)
                        }
                        .padding(.top, 16)

                        Spacer()

                        // Song title or feedback — centered
                        if isCooldown {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(feedbackIsCorrect ? Color.tealDark : Color(red: 179/255, green: 38/255, blue: 30/255))
                                        .frame(width: 100, height: 100)
                                    Image(systemName: feedbackIsCorrect ? "checkmark" : "xmark")
                                        .font(.system(size: 44, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                Text(feedbackIsCorrect ? "Correct!" : "Incorrect")
                                    .font(.custom("Unbounded", size: 32).weight(.bold))
                                    .foregroundColor(.darkText)
                            }
                        } else if currentIndex < guesses.count {
                            Text(guesses[currentIndex].track)
                                .font(.custom("Unbounded", size: 44).weight(.bold))
                                .foregroundColor(.darkText)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: geo.size.height * 0.8)
                        }

                        Spacer()

                        // Quit at VStack bottom → appears BELOW text in landscape
                        Button(action: { endGame() }) {
                            Text("Quit")
                                .font(.custom("Unbounded", size: 16).weight(.bold))
                                .foregroundColor(.tealDark)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                                .background(Color.correctIconBlue)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 3))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black).offset(x: 4, y: 4))
                        }
                        .padding(.bottom, 24)
                    }
                    .frame(width: geo.size.height, height: geo.size.width)
                    .rotationEffect(.degrees(90))
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            guesses = tracks.map { SongGuess(track: $0) }
            startCountdown()
        }
        .onDisappear {
            motionManager.stopUpdates()
            gameTimer?.invalidate()
        }
        .onChange(of: motionManager.roll) { _, roll in
            guard !isCooldown, currentIndex < guesses.count else { return }
            if roll < -45 {
                triggerFeedback(isCorrect: true)
            } else if roll > 45 {
                triggerFeedback(isCorrect: false)
            }
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                isCountingDown = false
                motionManager.startUpdates()
                timer.invalidate()
                startGameTimer()
            }
        }
    }

    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                endGame()
            }
        }
    }

    private func endGame() {
        guard !isGameOver else { return }
        isGameOver = true
        motionManager.stopUpdates()
        gameTimer?.invalidate()
        gameTimer = nil
        path.append(ResultsRoute(guesses: guesses.filter { $0.isCorrect != nil }))
    }

    private func triggerFeedback(isCorrect: Bool) {
        isCooldown = true
        feedbackIsCorrect = isCorrect
        guesses[currentIndex].isCorrect = isCorrect
        currentIndex += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            motionManager.roll = 0
            isCooldown = false
        }
    }
}

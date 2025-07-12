//
//  ResultsView.swift
//  karaoke
//
//  Created by Jaansi Parsa on 7/12/25.
//


import SwiftUI

struct ResultsView: View {
    let guesses: [SongGuess]
    let motionManager: MotionManager
    @Environment(\.dismiss) var dismiss

    // Filter to answered guesses only
    var answeredGuesses: [SongGuess] {
        guesses.filter { $0.isCorrect != nil }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Review Answers")
                .font(.largeTitle)
                .padding()

            Text("✅ Correct: \(guesses.filter { $0.isCorrect == true }.count)")
            Text("❌ Incorrect: \(guesses.filter { $0.isCorrect == false }.count)")

            List(answeredGuesses, id: \.track) { guess in
                HStack {
                    Text(guess.track)
                    Spacer()
                    if guess.isCorrect == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if guess.isCorrect == false {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }

            Button("Done") {
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top)
        }
        .onAppear {
            motionManager.stopUpdates()
        }
    }
}
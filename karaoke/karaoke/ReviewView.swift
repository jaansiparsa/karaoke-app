//
//  ReviewView.swift
//  karaoke
//
//  Created by Jaansi Parsa on 7/12/25.
//


import SwiftUI

struct ReviewView: View {
    let guesses: [SongGuess]

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(guesses.enumerated()), id: \.offset) { index, guess in
                    HStack {
                        Text("\(index + 1). \(guess.track)")
                        Spacer()
                        if let isCorrect = guess.isCorrect {
                            Text(isCorrect ? "✅" : "❌")
                                .font(.title2)
                        } else {
                            Text("❓")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Review Answers")
        }
    }
}
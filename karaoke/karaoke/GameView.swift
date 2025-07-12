//
//  GameView.swift
//  karaoke
//
//  Created by Jaansi Parsa on 7/12/25.
//


import SwiftUI

struct GameView: View {
    let tracks: [String]
    @State private var currentIndex = 0
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Guess this song:")
                .font(.title2)

            Text(tracks[currentIndex])
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding()

            Button("Next") {
                if currentIndex < tracks.count - 1 {
                    currentIndex += 1
                } else {
                    dismiss()
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
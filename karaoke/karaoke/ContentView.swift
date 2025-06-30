//
//  ContentView.swift
//  karaoke
//
//  Created by Jaansi Parsa on 6/29/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentHint = "🎶 This song is by Taylor Swift..."
    @State private var userGuess = ""
    @State private var feedback = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎧 Guess the Song")
                .font(.largeTitle)
                .bold()
            
            Text(currentHint)
                .font(.headline)
                .padding()

            TextField("Enter your guess", text: $userGuess)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Submit") {
                checkGuess()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Text(feedback)
                .font(.title2)
                .foregroundColor(.green)
        }
        .padding()
    }

    func checkGuess() {
        if userGuess.lowercased().contains("love story") {
            feedback = "✅ Correct!"
        } else {
            feedback = "❌ Try again!"
        }
    }
}

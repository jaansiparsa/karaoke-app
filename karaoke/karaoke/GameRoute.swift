//
//  GameRoute.swift
//  karaoke
//
//  Created by Jaansi Parsa on 7/12/25.
//


import Foundation

struct GameRoute: Hashable {
    let tracks: [String]
}

struct ResultsRoute: Hashable {
    let guesses: [SongGuess]
}
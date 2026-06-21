//
//  karaokeApp.swift
//  karaoke
//
//  Created by Jaansi Parsa on 6/29/25.
//

import SwiftUI

@main
struct KaraokeApp: App {
    

    @State private var path = NavigationPath()

        var body: some Scene {
            WindowGroup {
                NavigationStack(path: $path) {
                    PlaylistSelectionView(path: $path)
                }
            }
        }
}

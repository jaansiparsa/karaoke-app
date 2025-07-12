import SwiftUI

struct Playlist: Identifiable {
    let id: String
    let name: String
}

struct GameRoute: Hashable {
    let tracks: [String]
}

struct PlaylistSelectionView: View {
    let playlists: [Playlist] = [
        Playlist(id: "6j4w1woXd7xzGCNQoKrpY9", name: "white girl music"),
        Playlist(id: "6OJBQs9vWu8K8QFQlGm877", name: "disney bangers"),
        Playlist(id: "2wcz0IZbXv2kad6dZRfgbt", name: "gen z nostalgia"),
        Playlist(id: "0il43bTU2T9ZfBo1pCBJjY", name: "bollywood party")
    ]
    
    let clientID = "2f4d9fb7524049aa8c72d1c508bb341d"
    let clientSecret = "01fb38f54afd42f2b73cebf3e64f97eb"
    
    @State private var gameRoute: GameRoute? = nil
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(playlists) { playlist in
                        Button(action: {
                            Task {
                                do {
                                    let token = try await SpotifyAPI.fetchSpotifyAccessToken(clientID: clientID, clientSecret: clientSecret)
                                    let tracks = try await SpotifyAPI.fetchPlaylistTracks(playlistID: playlist.id, accessToken: token)
                                    self.gameRoute = GameRoute(tracks: tracks.shuffled())
                                } catch {
                                    print("Error fetching tracks: \(error)")
                                }
                            }
                        }) {
                            Text(playlist.name)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose a Playlist")
            .navigationDestination(item: $gameRoute) { route in
                GameView(tracks: route.tracks)
            }
        }
    }
}

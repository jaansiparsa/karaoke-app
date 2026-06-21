import SwiftUI

struct Playlist: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let imageName: String?

    init(id: String, name: String, subtitle: String, imageName: String? = nil) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.imageName = imageName
    }
}

func extractPlaylistID(from url: String) -> String? {
    if let range = url.range(of: "playlist/") {
        let idStart = range.upperBound
        var id = String(url[idStart...])
        if let queryStart = id.firstIndex(of: "?") {
            id = String(id[..<queryStart])
        }
        return id
    }
    return nil
}

struct PlaylistSelectionView: View {
    @Binding var path: NavigationPath
    @State private var userPlaylistLink: String = ""
    @State private var isFetchingUserPlaylist = false

    let playlists: [Playlist] = [
        Playlist(id: "0il43bTU2T9ZfBo1pCBJjY", name: "Summer Vibes",    subtitle: "24 Tracks • Sunny Days",   imageName: "BeachPenguin"),
        Playlist(id: "6j4w1woXd7xzGCNQoKrpY9", name: "Carpool Karaoke", subtitle: "15 Tracks • Sing Along", imageName: "CarpoolKaraoke"),
        Playlist(id: "2wcz0IZbXv2kad6dZRfgbt", name: "Disney Singalong",  subtitle: "32 Tracks • Nostalgia", imageName: "PrincessPenguin"),
        Playlist(id: "6OJBQs9vWu8K8QFQlGm877", name: "90s Pop",         subtitle: "18 Tracks • Boy Bands", imageName: "PopPenguin"),
    ]

    let clientID     = "2f4d9fb7524049aa8c72d1c508bb341d"
    let clientSecret = "01fb38f54afd42f2b73cebf3e64f97eb"

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
    ]

    var body: some View {
        ZStack {
            Color.backgroundBlue.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    collectionsSection
                    customPlaylistSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(for: GameRoute.self) { route in
            GameView(tracks: route.tracks, path: $path)
        }
        .navigationDestination(for: ResultsRoute.self) { route in
            ResultsView(guesses: route.guesses, path: $path)
        }
    }

    // MARK: - Collections Section
    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 8) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 18))
                    .foregroundColor(.darkText)
                Text("Your Collections")
                    .font(.custom("Unbounded", size: 16).weight(.bold))
                    .foregroundColor(.darkText)
            }

            LazyVGrid(columns: columns, spacing: 32) {
                ForEach(playlists) { playlist in
                    playlistCard(playlist: playlist)
                }
            }
        }
    }

    private func playlistCard(playlist: Playlist) -> some View {
        Button {
            Task {
                do {
                    let token = try await SpotifyAPI.fetchSpotifyAccessToken(
                        clientID: clientID,
                        clientSecret: clientSecret
                    )
                    let tracks = try await SpotifyAPI.fetchPlaylistTracks(
                        playlistID: playlist.id,
                        accessToken: token
                    )
                    path.append(GameRoute(tracks: tracks.shuffled()))
                } catch {
                    print("Error fetching tracks: \(error)")
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Image with play button — sharp corners, offset shadow behind only
                ZStack(alignment: .bottomTrailing) {
                    Image(playlist.imageName ?? "PlaylistPlaceholder")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 159)
                        .clipped()

                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        Image(systemName: "play.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.darkText)
                            .offset(x: 1)
                    }
                    .padding(8)
                }
                .overlay(Rectangle().stroke(Color.black, lineWidth: 3))
                // Offset rectangle behind — no shadow on the visible content
                .background(
                    Rectangle()
                        .fill(Color.black)
                        .offset(x: 4, y: 4)
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(playlist.name)
                        .font(.custom("DM Sans", size: 18).weight(.semibold))
                        .foregroundColor(.darkText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(playlist.subtitle)
                        .font(.custom("DM Sans", size: 12))
                        .foregroundColor(Color(red: 65/255, green: 72/255, blue: 75/255))
                }
            }
        }
    }

    // MARK: - Custom Playlist Section
    private var customPlaylistSection: some View {
        VStack(spacing: 12) {
            TextField("Paste a public Spotify playlist link", text: $userPlaylistLink)
                .font(.custom("DM Sans", size: 14))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 3))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black)
                        .offset(x: 4, y: 4)
                )

            Button(action: {
                guard let playlistID = extractPlaylistID(from: userPlaylistLink) else {
                    print("Invalid URL")
                    return
                }
                isFetchingUserPlaylist = true
                Task {
                    do {
                        let token = try await SpotifyAPI.fetchSpotifyAccessToken(
                            clientID: clientID,
                            clientSecret: clientSecret
                        )
                        let tracks = try await SpotifyAPI.fetchPlaylistTracks(
                            playlistID: playlistID,
                            accessToken: token
                        )
                        path.append(GameRoute(tracks: tracks.shuffled()))
                    } catch {
                        print("Error fetching user playlist: \(error)")
                    }
                    isFetchingUserPlaylist = false
                }
            }) {
                Group {
                    if isFetchingUserPlaylist {
                        ProgressView().tint(.white)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                            Text("Use My Playlist")
                                .font(.custom("Unbounded", size: 16).weight(.bold))
                        }
                        .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.scoringOrange)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 3))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .offset(x: 4, y: 4)
                )
            }
        }
    }
}

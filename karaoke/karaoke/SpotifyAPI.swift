//
//  SpotifyAPI.swift
//  karaoke
//
//  Created by Jaansi Parsa on 6/29/25.
//

import Foundation

struct SpotifyAuthResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
}

class SpotifyAPI {
    static func fetchSpotifyAccessToken(clientID: String, clientSecret: String) async throws -> String {
        let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        
        // Set the POST body
        let bodyParams = "grant_type=client_credentials"
        request.httpBody = bodyParams.data(using: .utf8)
        
        // Encode clientID and clientSecret in base64 for Basic Auth header
        let credentials = "\(clientID):\(clientSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            throw URLError(.badURL)
        }
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Set content type header
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode JSON response
        let authResponse = try JSONDecoder().decode(SpotifyAuthResponse.self, from: data)
        
        return authResponse.access_token
    }

    static func fetchPlaylistTracks(playlistID: String, accessToken: String) async throws -> [String] {
        var allTracks: [String] = []
        var nextURL: String? = "https://api.spotify.com/v1/playlists/\(playlistID)/tracks"
        var page = 1

        while let urlString = nextURL, let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let body = String(data: data, encoding: .utf8) ?? "No body"
                // print("Status code: \(httpResponse.statusCode)")
                // print("Response body: \(body)")
                // Try to parse error message
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = json["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw NSError(domain: "SpotifyAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
                } else {
                    throw URLError(.badServerResponse)
                }
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            if let items = json["items"] as? [[String: Any]] {
                for item in items {
                    if let track = item["track"] as? [String: Any],
                       let name = track["name"] as? String {
                        allTracks.append(name)
                    }
                }
            }
            // Spotify paginates results; check if there’s a next page
            nextURL = json["next"] as? String
            page += 1
        }
        return allTracks
    }


}

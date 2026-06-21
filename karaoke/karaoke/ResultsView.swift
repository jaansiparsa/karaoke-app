import SwiftUI

struct ResultsView: View {
    let guesses: [SongGuess]
    @Binding var path: NavigationPath

    var correctCount: Int { guesses.filter { $0.isCorrect == true }.count }
    var totalCount: Int { guesses.count }
    var scoreProgress: Double { totalCount > 0 ? Double(correctCount) / Double(totalCount) : 0 }

    var body: some View {
        ZStack {
            Color.backgroundBlue.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    scoringCard
                        .padding(.top, 16)
                    setlistSection
                    actionButtons
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Scoring Card
    private var scoringCard: some View {
        VStack(spacing: 12) {
            Text("FINAL SCORE")
                .font(.custom("DM Sans", size: 14))
                .foregroundColor(.darkBrown)
                .tracking(1.6)

            Text("\(correctCount)/\(totalCount)")
                .font(.custom("Unbounded", size: 64).weight(.bold))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 0, x: 3, y: 3)

            Text("Songs Correct")
                .font(.custom("Unbounded", size: 24).weight(.bold))
                .foregroundColor(.darkBrown)

            GeometryReader { bar in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.4))
                        .overlay(Capsule().stroke(Color.black, lineWidth: 2))
                    Capsule()
                        .fill(Color.tealDark)
                        .frame(width: max(0, bar.size.width * scoreProgress))
                }
            }
            .frame(height: 16)
            .padding(.horizontal, 24)

        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.scoringOrange)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 3))
        )
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .offset(x: 8, y: 8)
        )
        .rotationEffect(.degrees(1.5))
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }

    // MARK: - Setlist Summary
    private var setlistSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Setlist Summary")
                .font(.custom("Unbounded", size: 24).weight(.bold))
                .foregroundColor(.darkText)
                .padding(.horizontal, 8)

            ForEach(Array(guesses.enumerated()), id: \.offset) { index, guess in
                songRow(guess: guess, index: index)
            }
        }
    }

    private func songRow(guess: SongGuess, index: Int) -> some View {
        let isCorrect = guess.isCorrect == true
        let rotation: Double = index % 2 == 0 ? -2 : 1.5

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCorrect ? Color.correctIconBlue : Color.incorrectPink)
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                Image(systemName: isCorrect ? "checkmark" : "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isCorrect ? .tealDark : Color(red: 179/255, green: 38/255, blue: 30/255))
            }

            Text(guess.track)
                .font(.custom("DM Sans", size: 16).weight(.bold))
                .foregroundColor(.darkText)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: isCorrect ? "star" : "xmark")
                .font(.system(size: 16))
                .foregroundColor(.darkText.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isCorrect ? Color.white : Color(red: 243/255, green: 243/255, blue: 243/255))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 3))
        )
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black)
                .offset(x: 4, y: 4)
        )
        .rotationEffect(.degrees(rotation))
        .padding(.vertical, 6)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: { path.removeLast(path.count) }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                    Text("Play Again")
                        .font(.custom("Unbounded", size: 16).weight(.bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(Color.scoringOrange)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .offset(x: 4, y: 4)
                )
            }

            Button(action: { path.removeLast(path.count) }) {
                HStack(spacing: 12) {
                    Image(systemName: "house")
                        .font(.system(size: 16))
                    Text("Home")
                        .font(.custom("Unbounded", size: 16).weight(.bold))
                }
                .foregroundColor(.tealDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.correctIconBlue)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .offset(x: 4, y: 4)
                )
            }
        }
    }
}

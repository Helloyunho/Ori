//
//  SongVerifyView.swift
//  Ori
//
//  Created by Helloyunho on 2020/09/14.
//

import SwiftUI
import iTunesLibrary
import Neumorphic

struct SongVerifyView: View {
	@Environment(\.colorScheme) var colorScheme: ColorScheme
	var selectedSongs: [SongDownloadElement]
	@Binding var viewIndex: Int
	var body: some View {
		Neumorphic.shared.colorScheme = colorScheme
		let primaryColor = Neumorphic.shared.mainColor()
		let secondaryColor = Neumorphic.shared.secondaryColor()
		return ZStack {
			primaryColor
			VStack {
				Text("Good! Now, Recheck your choice!")
					.font(.largeTitle)
					.fontWeight(.bold)
					.foregroundColor(secondaryColor)
					.padding()
				Text("This is the last time to verify your choice.")
					.font(.title)
					.foregroundColor(secondaryColor)
					.padding(.bottom)

				ZStack {
					RoundedRectangle(cornerRadius: 32).fill(primaryColor).softOuterShadow()
					ScrollView(showsIndicators: false) {
						LazyVStack {
							ForEach (selectedSongs, id: \.self) { song in
								SongItem(title: song.mediaItem.title, artist: song.mediaItem.artist?.name, artwork: song.mediaItem.artwork?.image, colorScheme: _colorScheme)
									.background(primaryColor)
							}
						}
					}
						.padding(.all, 8.0)
				}
					.padding()
					.frame(maxWidth: 640)

				HStack {
					Button(action: {
						DispatchQueue.main.async {
							self.viewIndex -= 1
						}
					}) {
						Text("Back")
					}
						.softButtonStyle(Capsule(), pressedEffect: .flat)
						.padding()
					Button(action: {
						DispatchQueue.main.async {
							self.viewIndex += 1
						}
					}) {
						Text("Next")
					}
						.softButtonStyle(Capsule(), pressedEffect: .flat)
						.padding()
				}
			}
		}
	}
}

struct SongVerifyView_Stateful_Preview: View {
	var selectedSongs = [ITLibMediaItem]().map({ item in SongDownloadElement(mediaItem: item) })
	@State var viewIndex = 0

	var body: some View {
		SongVerifyView(selectedSongs: selectedSongs, viewIndex: $viewIndex)
	}
}

struct SongVerifyView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			SongVerifyView_Stateful_Preview()
				.frame(width: 800, height: 600)
			SongVerifyView_Stateful_Preview()
				.frame(width: 800, height: 600)
				.environment(\.colorScheme, .light)
		}
	}
}

//
//  SongSelectionView.swift
//  Ori
//
//  Created by Helloyunho on 2020/08/31.
//

import SwiftUI
import Neumorphic
import iTunesLibrary

struct SongSelectionView: View {
	@Environment(\.colorScheme) var colorScheme: ColorScheme
	var songs: [SongDownloadElement]
	@Binding var selectedSongs: [SongDownloadElement]
	let panel = DirectoryDialog(title: "Choose a directory to save songs", forDir: true)
	@Binding var pathString: String
	@Binding var viewIndex: Int

	var body: some View {
		Neumorphic.shared.colorScheme = colorScheme
		let primaryColor = Neumorphic.shared.mainColor()
		let secondaryColor = Neumorphic.shared.secondaryColor()
		return ZStack {
			primaryColor
			VStack {
				Text("Great!")
					.font(.largeTitle)
					.fontWeight(.bold)
					.foregroundColor(secondaryColor)
					.padding()
				Text("Now please select songs you want to download and where to download songs.")
					.font(.title)
					.foregroundColor(secondaryColor)
					.padding(.bottom)

				Button(action: {
					DispatchQueue.main.async {
						if let urls = panel.openDialogAndGetURLs() {
							pathString = urls[0].path
						}
					}
				}) {
					Text(pathString.isEmpty ? "Select Directory..." : pathString)
				}
					.softButtonStyle(Capsule(), pressedEffect: .flat)
					.padding()

				ZStack {
					RoundedRectangle(cornerRadius: 32).fill(primaryColor).softOuterShadow()
					ScrollView(showsIndicators: false) {
						LazyVStack {
							ForEach (songs, id: \.self) { song in
								SongItem(title: song.mediaItem.title, artist: song.mediaItem.artist?.name, selected: selectedSongs.contains(song), artwork: song.mediaItem.artwork?.image, colorScheme: _colorScheme)
									.background(primaryColor)
									.onTapGesture(perform: {
										DispatchQueue.main.async {
											if selectedSongs.contains(song) {
												selectedSongs = selectedSongs.filter() { $0 != song }
											} else {
												selectedSongs.append(song)
											}
										}
									})
							}
						}
					}
						.padding(.all, 8.0)
				}
					.padding()
					.frame(maxWidth: 640)

				HStack {
					Spacer()
					Button(action: {
						DispatchQueue.main.async {
							if (selectedSongs.count == songs.count) {
								selectedSongs = .init()
							} else {
								selectedSongs = .init(songs)
							}
						}
					}) {
						Text(selectedSongs.count == songs.count ? "Deselect All" : "Select All")
					}
						.softButtonStyle(Capsule(), pressedEffect: .flat)
						.padding()
					Spacer()
					Button(action: {
						DispatchQueue.main.async {
							self.viewIndex -= 1
						}
					}) {
						Text("Back")
					}
						.softButtonStyle(Capsule(), pressedEffect: .flat)
						.padding()
					if !self.selectedSongs.isEmpty && !self.pathString.isEmpty {
						Button(action: {
							DispatchQueue.main.async {
								self.viewIndex += 1
							}
						}) {
							Text("Next")
						}
							.softButtonStyle(Capsule(), pressedEffect: .flat)
							.padding()
					} else {
						Button(action: { }) {
							Text("Next")
						}
							.softButtonStyle(Capsule())
							.padding()
					}
					Spacer()
				}
			}
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
		}
	}
}

struct SongSelectionView_Stateful_Preview: View {
	@State var selectedSongs = [SongDownloadElement]()
	@State var pathString = ""
	@State var viewIndex = 0

	var body: some View {
		SongSelectionView(songs: ITunes.allPlaylists[1].items.map({ item in SongDownloadElement(mediaItem: item) }), selectedSongs: $selectedSongs, pathString: $pathString, viewIndex: $viewIndex)
	}
}

struct SongSelectionView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			SongSelectionView_Stateful_Preview()
				.frame(width: 800, height: 600)
			SongSelectionView_Stateful_Preview()
				.frame(width: 800, height: 600)
				.environment(\.colorScheme, .light)
		}
	}
}


//
//  SongDownloadView.swift
//  Ori
//
//  Created by Helloyunho on 2020/10/02.
//

import SwiftUI
import Neumorphic
import iTunesLibrary

struct SongDownloadView: View {
	@Environment(\.colorScheme) var colorScheme: ColorScheme
	var selectedSongs: [SongDownloadElement]
	@State var songsState = [SongDownloadElement: DownloadState]()
	var downloadPath: String
	@Binding var viewIndex: Int
	@State var isDone = false
	var body: some View {
		Neumorphic.shared.colorScheme = colorScheme
		let primaryColor = Neumorphic.shared.mainColor()
		let secondaryColor = Neumorphic.shared.secondaryColor()
		return ZStack {
			primaryColor
			VStack {
				Text("Okay! Downloading...")
					.font(.largeTitle)
					.fontWeight(.bold)
					.foregroundColor(secondaryColor)
					.padding()
				Text("Now go brew some coffee and drink it.")
					.font(.title)
					.foregroundColor(secondaryColor)
					.padding(.bottom)

				ZStack {
					RoundedRectangle(cornerRadius: 32).fill(primaryColor).softOuterShadow()
					ScrollView(showsIndicators: false) {
						LazyVStack {
							ForEach (selectedSongs, id: \.self) { song in
                SongDownloadItem(title: song.mediaItem.title, artist: song.mediaItem.artist?.name, artwork: song.mediaItem.artwork?.image, finished: songsState[song] == .finished, error: songsState[song] == .error, warning: songsState[song] == .warning, colorScheme: _colorScheme)
									.background(primaryColor)
							}
						}
					}
						.padding(.all, 8.0)
				}
					.padding()
					.frame(maxWidth: 640)

				HStack {
					if isDone {
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
							Text("Please Wait...")
						}
							.softButtonStyle(Capsule())
							.padding()
					}
				}
			}
		}
			.onAppear(perform: {
				DispatchQueue.global(qos: .utility).async {
					SongDownloadElement.downloadAll(downloadList: selectedSongs, downloadPath: downloadPath)
				}
			})
			.onReceive(NotificationCenter.default.publisher(for: .songDownloaded)) { obj in
				if let userInfo = obj.userInfo, let index = userInfo["index"] as? Int {
					songsState[selectedSongs[index]] = selectedSongs[index].downloadState
					if songsState.count == selectedSongs.count {
						isDone = true
					}
				}
		}
	}
}

struct SongDownloadView_Stateful_Preview: View {
	@State var selectedSongs = [ITLibMediaItem]().map({ item in SongDownloadElement(mediaItem: item) })
	@State var viewIndex = 0

	var body: some View {
		SongDownloadView(selectedSongs: selectedSongs, downloadPath: "~/", viewIndex: $viewIndex)
	}
}

struct SongDownloadView_Previews: PreviewProvider {
	static var previews: some View {
		SongDownloadView_Stateful_Preview()
	}
}

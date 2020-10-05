//
//  PlaylistSelectionView.swift
//  Ori
//
//  Created by Helloyunho on 2020/08/30.
//

import SwiftUI
import Neumorphic
import iTunesLibrary

struct PlaylistSelectionView: View {
	@Environment(\.colorScheme) var colorScheme: ColorScheme
	var playlists: [ITLibPlaylist]
	@Binding var selectedPlaylist: Int
	@Binding var viewIndex: Int

	var body: some View {
		Neumorphic.shared.colorScheme = colorScheme
		let primaryColor = Neumorphic.shared.mainColor()
		let secondaryColor = Neumorphic.shared.secondaryColor()
		return ZStack {
			primaryColor
			VStack {
				Text("Welcome to Ori!")
					.font(.largeTitle)
					.fontWeight(.bold)
					.foregroundColor(secondaryColor)
					.padding()
				Text("Please select a playlist.")
					.font(.title)
					.foregroundColor(secondaryColor)
					.padding(.bottom)

				ZStack {
					RoundedRectangle(cornerRadius: 32).fill(primaryColor).softOuterShadow()
					ScrollView(showsIndicators: false) {
						LazyVStack {
							ForEach (playlists.indices) { index in
								PlaylistItem(title: playlists[index].name, selected: selectedPlaylist == index, colorScheme: _colorScheme)
									.background(primaryColor)
									.onTapGesture(perform: {
										DispatchQueue.main.async {
											if selectedPlaylist == index {
												selectedPlaylist = -1
											} else {
												selectedPlaylist = index
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

				if selectedPlaylist != -1 {
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
			}
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
		}
	}
}

struct PlaylistSelectionView_Stateful_Preview: View {
	@State var selected_index = -1
	@State var viewIndex = 0

	var body: some View {
		PlaylistSelectionView(playlists: ITunes.allPlaylists, selectedPlaylist: $selected_index, viewIndex: $viewIndex)
	}
}

struct PlaylistSelectionView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			PlaylistSelectionView_Stateful_Preview()
				.frame(width: 800, height: 600)
			PlaylistSelectionView_Stateful_Preview()
				.frame(width: 800, height: 600)
				.environment(\.colorScheme, .light)
		}
	}
}

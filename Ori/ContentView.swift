//
//  ContentView.swift
//  Ori
//
//  Created by Helloyunho on 2020/08/28.
//

import SwiftUI
import Neumorphic
import iTunesLibrary

struct ContentView: View {
	let playlists = ITunes.allPlaylists.sorted(by: { $0.name < $1.name })
	@State var selectedPlaylist = -1 {
		didSet {
			self.selectedSongs = [SongDownloadElement]()
		}
	}
	@State var viewIndex = 0
	@State var selectedSongs = [SongDownloadElement]()
	@State var downloadPath = ""

	var body: some View {
		if viewIndex == 0 {
			PlaylistSelectionView(playlists: playlists, selectedPlaylist: $selectedPlaylist, viewIndex: $viewIndex)
				.transition(AnyTransition.move(edge: .leading)).animation(.default)
		} else if viewIndex == 1 {
			SongSelectionView(songs: playlists[selectedPlaylist].items.map({ item in SongDownloadElement(mediaItem: item) }), selectedSongs: $selectedSongs, pathString: $downloadPath, viewIndex: $viewIndex)
				.transition(AnyTransition.move(edge: .leading)).animation(.default)
		} else if viewIndex == 2 {
			SongVerifyView(selectedSongs: selectedSongs, viewIndex: $viewIndex)
				.transition(AnyTransition.move(edge: .leading)).animation(.default)
		} else if viewIndex == 3 {
			SongDownloadView(selectedSongs: selectedSongs, downloadPath: downloadPath, viewIndex: $viewIndex)
				.transition(AnyTransition.move(edge: .leading)).animation(.default)
		} else if viewIndex == 4 {
			FinishedView()
				.transition(AnyTransition.move(edge: .leading)).animation(.default)
		} else {
			EasterEggView()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ContentView()
				.frame(width: 800, height: 600)
			ContentView()
				.frame(width: 800, height: 600)
				.environment(\.colorScheme, .light)
		}
	}
}

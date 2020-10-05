//
//  SongDownloadItem.swift
//  Ori
//
//  Created by Helloyunho on 2020/10/02.
//

import SwiftUI
import Neumorphic

struct SongDownloadItem: View {
	var title: String
	var artist: String?
	var artwork: NSImage?
	var finished: Bool = false
	var error: Bool = false
	@Environment(\.colorScheme) var colorScheme: ColorScheme
	var body: some View {
		Neumorphic.shared.colorScheme = colorScheme
		let secondaryColor = Neumorphic.shared.secondaryColor()
		return HStack {
			if let artworkReal = artwork {
				Image(nsImage: artworkReal)
					.resizable()
					.scaledToFit()
					.frame(width: 32, height: 32)
					.padding()
			} else {
				Image(systemName: "music.note")
					.resizable()
					.scaledToFit()
					.frame(width: 32, height: 32)
					.foregroundColor(secondaryColor)
					.padding()
			}
			VStack(alignment: .leading) {
				Text(title)
					.foregroundColor(secondaryColor)
				if let artistReal = artist {
					Text(artistReal)
						.foregroundColor(secondaryColor)
				}
			}
			Spacer()

			if error {
				Image(systemName: "exclamationmark.circle")
					.resizable()
					.scaledToFit()
					.frame(width: 16, height: 16)
					.foregroundColor(Color.red)
					.padding()
			} else if finished {
				Image(systemName: "checkmark")
					.resizable()
					.scaledToFit()
					.frame(width: 16, height: 16)
					.foregroundColor(Color.green)
					.padding()
			} else {
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle())
					.frame(width: 16, height: 16)
					.padding()
			}
		}
	}
}

struct SongDownloadItem_Previews: PreviewProvider {
	static var previews: some View {
		SongDownloadItem(title: "Twinklestar", artist: "Snail's House")
	}
}


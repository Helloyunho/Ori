//
//  SongItem.swift
//  Ori
//
//  Created by Helloyunho on 2020/08/31.
//

import SwiftUI
import Neumorphic

struct SongItem: View {
	var title: String
	var artist: String?
	var selected: Bool = false
	var artwork: NSImage?
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

			if selected {
				Image(systemName: "checkmark")
					.resizable()
					.scaledToFit()
					.frame(width: 16, height: 16)
					.foregroundColor(Color.blue)
					.padding()
			}
		}
	}
}

struct SongItem_Previews: PreviewProvider {
	static var previews: some View {
		SongItem(title: "Twinkle Star", artist: "Snail's House", selected: true)
	}
}

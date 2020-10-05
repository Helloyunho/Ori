//
//  PlaylistItem.swift
//  Ori
//
//  Created by Helloyunho on 2020/08/29.
//

import SwiftUI
import Neumorphic

struct PlaylistItem: View {
	var title: String
	var selected: Bool = false
	@Environment(\.colorScheme) var colorScheme: ColorScheme
	var body: some View {
		Neumorphic.shared.colorScheme = colorScheme
		let secondaryColor = Neumorphic.shared.secondaryColor()
		return HStack {
			Image(systemName: "music.note.list")
				.resizable()
				.scaledToFit()
				.frame(width: 32, height: 32)
				.foregroundColor(secondaryColor)
				.padding()
			Text(title)
				.foregroundColor(secondaryColor)
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

struct PlaylistItem_Previews: PreviewProvider {
	static var previews: some View {
		PlaylistItem(title: "On-The-Go", selected: true)
	}
}

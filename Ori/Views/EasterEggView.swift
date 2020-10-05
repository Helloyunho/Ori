//
//  EasterEggView.swift
//  Ori
//
//  Created by Helloyunho on 2020/10/04.
//

import SwiftUI
import Neumorphic

struct EasterEggView: View {
	@Environment(\.colorScheme) var colorScheme: ColorScheme

	var body: some View {
		Neumorphic.shared.colorScheme = colorScheme
		let primaryColor = Neumorphic.shared.mainColor()
		let secondaryColor = Neumorphic.shared.secondaryColor()
		return ZStack {
			primaryColor
			VStack {
				Text("Easter Egg!")
					.font(.largeTitle)
					.fontWeight(.bold)
					.foregroundColor(secondaryColor)
					.padding()
				Text("Actually... it's not. You shouldn't be in here... How did you come here? Please let me know using GitHub.")
					.font(.title)
					.foregroundColor(secondaryColor)
					.padding(.bottom)
				Spacer()
			}
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
		}
	}
}

struct EasterEggView_Previews: PreviewProvider {
	static var previews: some View {
		EasterEggView()
	}
}

//
//  FinishedView.swift
//  Ori
//
//  Created by Helloyunho on 2020/10/04.
//

import SwiftUI
import Neumorphic

struct FinishedView: View {
	@Environment(\.colorScheme) var colorScheme: ColorScheme

	var body: some View {
		Neumorphic.shared.colorScheme = colorScheme
		let primaryColor = Neumorphic.shared.mainColor()
		let secondaryColor = Neumorphic.shared.secondaryColor()
		return ZStack {
			primaryColor
			VStack {
				Text("Finished!")
					.font(.largeTitle)
					.fontWeight(.bold)
					.foregroundColor(secondaryColor)
					.padding()
				Text("Thank you for using this program. Made with ❤️ by Helloyunho.")
					.font(.title)
					.foregroundColor(secondaryColor)
					.padding(.bottom)
				Spacer()
			}
				.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
		}
	}
}

struct FinishedView_Previews: PreviewProvider {
	static var previews: some View {
		FinishedView()
	}
}

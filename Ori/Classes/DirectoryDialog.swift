//
//  DirectoryDialog.swift
//  Ori
//
//  Created by Helloyunho on 2020/10/02.
//

import Foundation
import AppKit

class DirectoryDialog {
	let nsopenpanel = NSOpenPanel()
	var multipleSelection: Bool

	init (title: String, forFile: Bool = false, forDir: Bool = false, multipleSelection: Bool = false) {
		nsopenpanel.canChooseFiles = forFile
		nsopenpanel.canChooseDirectories = forDir
		nsopenpanel.allowsMultipleSelection = multipleSelection
		nsopenpanel.title = title
		self.multipleSelection = multipleSelection
	}

	func openDialogAndGetURLs() -> [URL]? {
		if (nsopenpanel.runModal() == NSApplication.ModalResponse.OK) {
			return nsopenpanel.urls
		}
		return nil
	}
}

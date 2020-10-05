//
//  OriApp.swift
//  Ori
//
//  Created by Helloyunho on 2020/08/28.
//

import SwiftUI
import iTunesLibrary

let ITunes = try! ITLibrary(apiVersion: "1.0", options: .lazyLoadData)

@main
struct OriApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}

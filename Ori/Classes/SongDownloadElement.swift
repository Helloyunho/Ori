//
//  SongDownloadElement.swift
//  Ori
//
//  Created by Helloyunho on 2020/10/03.
//

import Foundation
import iTunesLibrary
import Alamofire
import SwiftyJSON
import StringMetric
import ShellOut

enum DownloadState {
	case downloading
	case finished
	case error
}

class SongDownloadElement: Hashable {
	static func == (lhs: SongDownloadElement, rhs: SongDownloadElement) -> Bool {
		return lhs.mediaItem == rhs.mediaItem
	}

	var downloadState: DownloadState = .downloading
	var mediaItem: ITLibMediaItem

	init (mediaItem: ITLibMediaItem) {
		self.mediaItem = mediaItem
	}

	func setState(_ state: DownloadState) {
		self.downloadState = state
	}

	private func getMostRelatedVideoID (query: String, callback: @escaping (String?) -> Void) {
		let parameters = [
			"part": "snippet",
			"maxResults": "50",
			"q": query,
			"key": YOUTUBE_API_KEY
		]
		let headers: HTTPHeaders = [
				.accept("application/json")
		]

		AF.request("https://www.googleapis.com/youtube/v3/search", parameters: parameters, headers: headers).validate().responseJSON(queue: .global(qos: .utility)) { [weak self] response in
			if let value = response.value {
				let json = JSON(value)
				var bestRelatedVideoID: (String, Double) = ("", 0.0)
				if let items = json["items"].array {
					for item in items {
						if let videoID = item["id"]["videoId"].string, let title = item["snippet"]["title"].string {
							let distance = title.distance(between: query)
							if distance > bestRelatedVideoID.1 {
								bestRelatedVideoID = (videoID, distance)
								if distance > 0.9 {
									break
								}
							}
						}
					}
					DispatchQueue.main.async {
						callback(bestRelatedVideoID.0)
					}

					return
				}
			} else if let error = response.error {
				LOGGER.error("Youtube Search Alamofire Error: \(String(describing: error))")
				self?.downloadState = .error
			}
			DispatchQueue.main.async {
				callback(nil)
			}

			return
		}
	}

	func startDownload(downloadPath: String, callback: @escaping (Bool) -> Void) {
		let query = (self.mediaItem.artist?.name != nil) ? "\(self.mediaItem.artist!.name!) - \(self.mediaItem.title)" : self.mediaItem.title
		// Just for now. Will be able to change later
		let format = "mp3"

		self.getMostRelatedVideoID(query: query) { [weak self] videoIDnotSure in
			if let videoID = videoIDnotSure {
				do {
					let result = try shellOut(to: "export PATH=\"/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/Library/Apple/usr/bin:/usr/local/bin\" && youtube-dl -x --add-metadata --embed-thumbnail --audio-format \(format) -o \"\(downloadPath)/\(query.replacingOccurrences(of: "\"", with: "\\\"")).%(ext)s\" https://youtu.be/\(videoID)")
					LOGGER.debug("\(result)")
					self?.downloadState = .finished
					DispatchQueue.main.async {
						callback(true)
					}
				} catch {
					let error = error as! ShellOutError
					LOGGER.error("Youtube dl Error: \(error.message)")
					self?.downloadState = .error
					DispatchQueue.main.async {
						callback(false)
					}
				}
			} else {
				LOGGER.error("videoID Not Found")
				self?.downloadState = .error
				DispatchQueue.main.async {
					callback(false)
				}
			}
		}
	}

	func hash (into hasher: inout Hasher) {
		hasher.combine(self.mediaItem)
	}

	static func downloadAll (downloadList: [SongDownloadElement], downloadPath: String) {
		let cpuCount = ProcessInfo.processInfo.processorCount
		var currentlyRunning = 0
		var index = 0

		while index >= downloadList.startIndex && index < downloadList.endIndex {
			if currentlyRunning < cpuCount {
				let _index = Int(index)
				DispatchQueue.global(qos: .utility).async {
					downloadList[_index].startDownload(downloadPath: downloadPath) { _ in
						NotificationCenter.default.post(name: .songDownloaded, object: nil, userInfo: ["index": _index])
						currentlyRunning -= 1
					}
				}
				index += 1
				currentlyRunning += 1
			}
		}
	}
}

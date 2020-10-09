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
  case warning
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
        let savePathWithoutExt = "\(downloadPath)/\(query.replacingOccurrences(of: "\"", with: "\\\""))"
				do {
          let args = [
            "youtube-dl",
            "-x",
            "--audio-format",
            "\(format)",
            " -o",
            "\"\(savePathWithoutExt)_temp.%(ext)s\"",
            "https://youtu.be/\(videoID)"
          ]
          let result = try shellOut(to: "export PATH=\"/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/Library/Apple/usr/bin:/usr/local/bin\" && \(args.joined(separator: " "))")
					LOGGER.debug("\(result)")
          let tempMusicPath = URL(fileURLWithPath: "\(savePathWithoutExt)_temp.\(format)")
          var isArtworkPossible = false
          var isArtworkSuccess = false
          if format == "mp3", let artwork = self?.mediaItem.artwork {
            if let artworkData = artwork.imageData {
              var formatRecognizable = true
              var imageFormatAsExt = ""
              switch (artwork.imageDataFormat) {
              case .none:
                formatRecognizable = false
              case .bitmap:
                imageFormatAsExt = ".bmp"
              case .JPEG:
                imageFormatAsExt = ".jpg"
              case .JPEG2000:
                imageFormatAsExt = ".jpg"
              case .GIF:
                imageFormatAsExt = ".gif"
              case .PNG:
                imageFormatAsExt = ".png"
              case .TIFF:
                imageFormatAsExt = ".tiff"
              case .PICT:
                imageFormatAsExt = ".pict"
              case .BMP:
                imageFormatAsExt = ".bmp"
              @unknown default:
                formatRecognizable = false
              }
              
              if formatRecognizable {
                isArtworkPossible = true
                do {
                  let artworkURL = URL(fileURLWithPath: "\(savePathWithoutExt)_temp.\(imageFormatAsExt)")
                  try artworkData.write(to: artworkURL)
                  let args = [
                    "ffmpeg",
                    "-y",
                    "-i",
                    "\"\(savePathWithoutExt)_temp.\(format)\"",
                    "-i",
                    "\"\(savePathWithoutExt)_temp.\(imageFormatAsExt)\"",
                    "-c",
                    "copy",
                    "-map",
                    "0",
                    "-map",
                    "1",
                    "-metadata:s:v",
                    "title=\"Album cover\"",
                    "-metadata:s:v",
                    "comment=\"Cover (front)\"",
                    "\"\(savePathWithoutExt)_temp_artwork.\(format)\""
                  ]
                  do {
                    let result = try shellOut(to: "export PATH=\"/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/Library/Apple/usr/bin:/usr/local/bin\" && \(args.joined(separator: " "))")
                    LOGGER.debug("\(result)")
                    isArtworkSuccess = true
                    try? FileManager.default.removeItem(at: artworkURL)
                    try? FileManager.default.removeItem(at: tempMusicPath)
                  } catch {
                    let error = error as! ShellOutError
                    LOGGER.error("FFmpeg Error while applying artwork: \(error.message)")
                    try? FileManager.default.removeItem(at: artworkURL)
                  }
                } catch {
                  LOGGER.error("Artwork Data Saving Error: \(String(describing: error))")
                }
              }
            }
          }
          do {
            var args = [
              "ffmpeg",
              "-y",
              "-i",
              isArtworkSuccess ? "\"\(savePathWithoutExt)_temp_artwork.\(format)\"" : "\"\(savePathWithoutExt)_temp.\(format)\""
            ]

            if format == "m4a" {
              args.append(contentsOf: ["-vn", "-acodec", "copy"])
            } else {
              args.append(contentsOf: ["-c", "copy"])
            }
            
            if let title = self?.mediaItem.title {
              args.append(contentsOf: ["-metadata", "title=\"\(title.replacingOccurrences(of: "\"", with: "\\\""))\""])
            }
            if let artist = self?.mediaItem.artist?.name {
              args.append(contentsOf: ["-metadata", "author=\"\(artist.replacingOccurrences(of: "\"", with: "\\\""))\""])
            }
            if let albumArtist = self?.mediaItem.album.albumArtist {
              args.append(contentsOf: ["-metadata", "album_artist=\"\(albumArtist.replacingOccurrences(of: "\"", with: "\\\""))\""])
            }
            if let album = self?.mediaItem.album.title {
              args.append(contentsOf: ["-metadata", "album=\"\(album.replacingOccurrences(of: "\"", with: "\\\""))\""])
            }
            if let grouping = self?.mediaItem.grouping {
              args.append(contentsOf: ["-metadata", "grouping=\"\(grouping.replacingOccurrences(of: "\"", with: "\\\""))\""])
            }
            if let composer = self?.mediaItem.composer {
              args.append(contentsOf: ["-metadata", "composer=\"\(composer.replacingOccurrences(of: "\"", with: "\\\""))\""])
            }
            if let year = self?.mediaItem.year {
              args.append(contentsOf: ["-metadata", "year=\"\(year)\""])
            }
            if let track = self?.mediaItem.trackNumber {
              args.append(contentsOf: ["-metadata", "track=\"\(track)\""])
            }
            if let comment = self?.mediaItem.comments {
              args.append(contentsOf: ["-metadata", "comment=\"\(comment.replacingOccurrences(of: "\"", with: "\\\""))\""])
            }
            if let genre = self?.mediaItem.genre {
              args.append(contentsOf: ["-metadata", "genre=\"\(genre.replacingOccurrences(of: "\"", with: "\\\""))\""])
            }
            if let description = self?.mediaItem.description {
              args.append(contentsOf: ["-metadata", "description=\"\(description.replacingOccurrences(of: "\"", with: "\\\""))\""])
            }
            args.append("\"\(savePathWithoutExt).\(format)\"")
            let result = try shellOut(to: "export PATH=\"/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/Library/Apple/usr/bin:/usr/local/bin\" && \(args.joined(separator: " "))")
            LOGGER.debug("\(result)")
            try? FileManager.default.removeItem(at: tempMusicPath)
            if isArtworkSuccess {
              let tempArtworkMusicFile = URL(fileURLWithPath: "\(savePathWithoutExt)_temp_artwork.\(format)")
              try? FileManager.default.removeItem(at: tempArtworkMusicFile)
            }
            self?.downloadState = (isArtworkPossible && !isArtworkSuccess) ? .warning : .finished
            DispatchQueue.main.async {
              callback(true)
            }
          } catch {
            let error = error as! ShellOutError
            LOGGER.error("FFmpeg Error: \(error.message)")
            self?.downloadState = .error
            DispatchQueue.main.async {
              callback(false)
            }
            return
          }
				} catch {
					let error = error as! ShellOutError
					LOGGER.error("Youtube dl Error: \(error.message)")
					self?.downloadState = .error
					DispatchQueue.main.async {
						callback(false)
					}
          return
				}
			} else {
				LOGGER.error("videoID Not Found")
				self?.downloadState = .error
				DispatchQueue.main.async {
					callback(false)
				}
        return
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

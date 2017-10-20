
//
//  Container.swift
//  Evergreen
//
//  Created by Brent Simmons on 4/17/16.
//  Copyright © 2016 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import RSCore
import Data

extension NSNotification.Name {
	
	public static let ChildrenDidChange = Notification.Name("ChildrenDidChange")
}

public protocol Container {

	var children: [AnyObject] { get }

	func hasAtLeastOneFeed() -> Bool
	func objectIsChild(_ object: AnyObject) -> Bool

	//Recursive
	func flattenedFeeds() -> Set<Feed>
	func hasFeed(with feedID: String) -> Bool
	func hasFeed(withURL url: String) -> Bool
	func existingFeed(with feedID: String) -> Feed?
	func existingFeed(withURL url: String) -> Feed?
	func existingFolder(with name: String) -> Folder?

	func postChildrenDidChangeNotification()
}

public extension Container {

	func hasAtLeastOneFeed() -> Bool {

		for child in children {
			if child is Feed {
				return true
			}
			if let folder = child as? Folder {
				if folder.hasAtLeastOneFeed() {
					return true
				}
			}
		}

		return false
	}

	func objectIsChild(_ object: AnyObject) -> Bool {

		for child in children {
			if object === child {
				return true
			}
		}
		return false
	}

	func flattenedFeeds() -> Set<Feed> {

		var feeds = Set<Feed>()

		for object in children {
			if let feed = object as? Feed {
				feeds.insert(feed)
			}
			else if let container = object as? Container {
				feeds.formUnion(container.flattenedFeeds())
			}
		}

		return feeds
	}

	func hasFeed(with feedID: String) -> Bool {

		return existingFeed(with: feedID) != nil
	}

	func hasFeed(withURL url: String) -> Bool {

		return existingFeed(withURL: url) != nil
	}

	func existingFeed(with feedID: String) -> Feed? {

		for child in children {

			if let feed = child as? Feed, feed.feedID == feedID {
				return feed
			}
			if let container = child as? Container, let feed = container.existingFeed(with: feedID) {
				return feed
			}
		}

		return nil
	}

	func existingFeed(withURL url: String) -> Feed? {

		for child in children {

			if let feed = child as? Feed, feed.url == url {
				return feed
			}
			if let container = child as? Container, let feed = container.existingFeed(withURL: url) {
				return feed
			}
		}

		return nil
	}

	func existingFolder(with name: String) -> Folder? {

		for child in children {

			if let folder = child as? Folder {
				if folder.name == name {
					return folder
				}
				if let subFolder = folder.existingFolder(with: name) {
					return subFolder
				}
			}
		}

		return nil
	}

	func postChildrenDidChangeNotification() {
		
		NotificationCenter.default.post(name: .ChildrenDidChange, object: self)
	}
}

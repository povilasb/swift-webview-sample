//
//	AppDelegate.swift
//	webview-sample
//
//	Created by Povilas Balciunas on 19/03/15.
//	Copyright (c) 2015 povilasb. All rights reserved.
//

import Cocoa
import WebKit


class Person: NSObject {
	private var name: String


	init(name: String) {
		self.name = name
	}

	deinit {
		println("Person '" + self.name + "' destroyed.")
	}

	func getName() -> String {
		return self.name
	}

	override class func webScriptNameForSelector(aSelector: Selector)
		-> String!  {
		switch aSelector {
		case Selector("getName"):
			return "getName"

		default:
			return nil
		}
	}

	// Only allow the two defined functions to be called from JavaScript
	// Same applies to variable access, all blocked by default
	override class func isSelectorExcludedFromWebScript(aSelector: Selector)
		-> Bool {
		switch aSelector {
		default:
			return false
		}
	}
}


// Create class which we later hook into the javascript side of the world
class JsHost : NSObject {

	func log(msg: String) {
		println("JavaScript: " + msg)
	}

	func hostName() -> String {
		return "MacOS X WebKit"
	}

	func createPerson(name: String) -> Person {
		return Person(name: name)
	}


	deinit {
		println("JsHost destroy.")
	}

	// Create alias in javascript env so that one can call bridge.getColor(...)
	// instead of bridge.getColorWith_green_blue_alpha_(...)
	override class func webScriptNameForSelector(aSelector: Selector)
		-> String!  {
		switch aSelector {
		case Selector("log:"):
			return "log"

		case Selector("hostName"):
			return "hostName"

		case Selector("createPerson:"):
			return "createPerson"

		default:
			return nil
		}
	}

	// Only allow the two defined functions to be called from JavaScript
	// Same applies to variable access, all blocked by default
	override class func isSelectorExcludedFromWebScript(aSelector: Selector)
		-> Bool {
		switch aSelector {
		default:
			return false
		}
	}
}


class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var webView: WebView!


	func loadGui() {
		let url = NSBundle.mainBundle()
			.URLForResource("main", withExtension: "html")
		let requesturl = NSURL(string: "main.html")
		let request = NSURLRequest(URL: url!)
		self.webView.mainFrame.loadRequest(request)
	}

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		self.loadGui()

		var jsWindow = self.webView.windowScriptObject
		var jsHost = JsHost()
		jsWindow.setValue(jsHost, forKey: "host")
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
		self.webView.close()
	}

}

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

	func createPerson(name: String) -> Person {
		return Person(name: name)
	}

	deinit {
		println("JsHost destroy.")
	}

	override class func webScriptNameForSelector(aSelector: Selector)
		-> String!  {
		switch aSelector {
		case Selector("log:"):
			return "log"

		case Selector("createPerson:"):
			return "createPerson"

		default:
			return nil
		}
	}

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
		self.webView.close()
	}

}

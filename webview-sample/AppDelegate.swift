import Cocoa
import WebKit


class JSContextManager {

	weak var webView: WebView?

	init(_ webView: WebView!) {
		self.webView = webView
	}

	func setValue(value: AnyObject?, forKey: String) {
		self.webView?.windowScriptObject.setValue(value,
			forKey: forKey)
	}

	/**
	 * Does not wait for javascript to finish.
	 */
	class func callJSFunctionAsync(function: WebScriptObject!,
		arguments: [AnyObject]!) {

		dispatch_async(dispatch_get_main_queue()) {
			function.JSValue().callWithArguments(arguments)
			()
		}
	}

	class func callJSFunction(function: WebScriptObject!,
		arguments: [AnyObject]!) {
		function.JSValue().callWithArguments(arguments)
	}

}


class Person: NSObject {
	private var name: String
	private var sayHandler: WebScriptObject?


	init(name: String) {
		self.name = name
		self.sayHandler = nil
	}

	deinit {
		println("Person '" + self.name + "' destroyed.")
	}

	func getName() -> String {
		return self.name
	}

	func setSayHandler(handler: WebScriptObject) {
		self.sayHandler = handler
	}

	func sayMyName() {
		if self.sayHandler != nil {
			JSContextManager.callJSFunctionAsync(self.sayHandler!,
				arguments: [self.name])
		}
		else {
			println("Error: say handler not set.")
		}
	}

	override class func webScriptNameForSelector(aSelector: Selector)
		-> String!  {
		switch aSelector {
		case Selector("getName"):
			return "getName"

		case Selector("setSayHandler:"):
			return "setSayHandler"

		case Selector("sayMyName"):
			return "sayMyName"

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

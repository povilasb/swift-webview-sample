import Cocoa


println("Starting main.")

func main() {
	let application = NSApplication.sharedApplication()
	let delegate = AppDelegate()
	application.delegate = delegate

	var topLevelObjects: NSArray?
	let bundle = NSBundle.mainBundle()
	let nibName = "MainMenu"
	bundle.loadNibNamed(nibName, owner: application,
		topLevelObjects: &topLevelObjects)

	application.run()
}

main()

println("Main exiting.")

#!/usr/bin/swift
// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Close all Finder Windows
// @raycast.mode silent
// Optional parameters:
// @raycast.icon assets/finder.png
// Documentation:
// @raycast.author Omar Shahine
// @raycast.authorURL https://omar.shahine.com

import AppKit

let script = """
tell application "Finder" to close every window
"""

if let scriptObject = NSAppleScript(source: script) {
    var error: NSDictionary?
    scriptObject.executeAndReturnError(&error)
    
    if let error = error {
        print("Error: \(error)")
    }
}

print("Closed all Finder windows")
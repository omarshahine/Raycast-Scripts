#!/usr/bin/swift
// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Paste as Plain Text
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 📋
// @raycast.description Pastes clipboard content as plain text by stripping formatting

// Documentation:
// @raycast.author Omar Shahine
// @raycast.authorURL https://omar.shahine.com

import AppKit

// Get the current pasteboard
let pasteboard = NSPasteboard.general

// Get text from pasteboard
if let clipboardString = pasteboard.string(forType: .string) {
    // Clear the pasteboard
    pasteboard.clearContents()
    
    // Set the plain text back to the pasteboard
    pasteboard.setString(clipboardString, forType: .string)
    
    // Simulate Command+V to paste
    let source = CGEventSource(stateID: .combinedSessionState)
    let vKeyCode = UInt16(9) // V key
    
    // Create key down and up events with Command modifier
    let keyDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
    keyDown?.flags = .maskCommand
    
    let keyUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
    keyUp?.flags = .maskCommand
    
    // Post the events
    keyDown?.post(tap: .cghidEventTap)
    keyUp?.post(tap: .cghidEventTap)
    
    print("Content pasted as plain text")
} else {
    print("No text content found in clipboard")
}
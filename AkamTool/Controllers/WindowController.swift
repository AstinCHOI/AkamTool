//
//  WindowController.swift
//  AkamTool
//
//  Created by Astin on 1/31/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

import AppKit

class WindowController: NSWindowController, NSWindowDelegate {
    
    var contentView: NSView {
        get {
            return self.window!.contentView as NSView
        }
        set {
            self.window!.contentView = newValue
        }
    }
    
    init(windowSize: CGSize = CGSizeZero) {
        let screenSize = NSScreen.mainScreen()!.frame.size
        let rect = CGRectMake(
            (screenSize.width - windowSize.width) / 2,
            (screenSize.height - windowSize.height) / 2,
            windowSize.width,
            windowSize.height
        )
        let mask = NSTitledWindowMask | NSClosableWindowMask
        let window = NSWindow(contentRect: rect, styleMask: mask, backing: .Buffered, defer: false)
        super.init(window: window)
        
        window.delegate = self
        window.hasShadow = true
        window.contentView = NSView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func showWindow(sender: AnyObject?) {
        AkamToolManager.sharedInstance().close()
        self.window?.level = Int(CGWindowLevelForKey(Int32(kCGScreenSaverWindowLevelKey))) // NSScreenSaverWindowLevel
        super.showWindow(sender)
    }
}

//
//  main.swift
//  AkamTool
//
//  Created by Astin on 1/31/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

import AppKit

autoreleasepool { () -> () in
    let application = NSApplication.sharedApplication()
    let delegate = AppDelegate()
    application.delegate = delegate
    application.run()
}

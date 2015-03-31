//
//  AppDelegate.swift
//  AkamTool
//
//  Created by Astin on 1/29/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

import Cocoa

//@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.terminateAlreadyRunning()
        
        self.moveToApplicationFolderIfNeeded()
        
        AKHotKeyManager.registerHotKey()
        
        let ga = AnalyticsHelper.sharedInstance()
        ga.beginPeriodicReportingWithAccount("UA-61304426-1", name:"AkamTool", version: BundleInfo.Version)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func terminateAlreadyRunning() {
        let pid = NSProcessInfo.processInfo().processIdentifier
        let cmd = "ps aux | grep 'Contents/MacOS/AkamTool' | awk '{ if($2 != \(pid)) print $2 }' | xargs kill -9"
        let task = NSTask.launchedTaskWithLaunchPath("/bin/sh", arguments: ["-c", cmd])
        task.waitUntilExit()
    }
    
    func moveToApplicationFolderIfNeeded() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let ignore = userDefaults.boolForKey(UserDefaultsKey.IgnoreApplicationFolderWarning)
        if ignore {
            return
        }
        
        if self.isInApplicationFolder() {
            return
        }
        
        let alert = NSAlert()
        alert.messageText = "AkamTool is not in Application folder."
        alert.informativeText = "AkamTool wouldn't be updated automatcally.\nWould you move it to Application folder?"
        alert.addButtonWithTitle("Move")
        alert.addButtonWithTitle("Cancel")
        alert.addButtonWithTitle("Don't Ask Again")
        
        let response = alert.runModal()
        
        // Don't Ask Again
        if response == 1002 {
            userDefaults.setObject(true, forKey: UserDefaultsKey.IgnoreApplicationFolderWarning)
            userDefaults.synchronize()
        }
            
        // Move
        else if response == 1000 {
            self.moveToApplicationFolder()
        }
    }
    
    func isInApplicationFolder() -> Bool {
        let bundlePath = NSBundle.mainBundle().bundlePath
        let paths = NSSearchPathForDirectoriesInDomains(.ApplicationDirectory, .AllDomainsMask, true) as [String]
        for path in paths {
            if bundlePath.hasPrefix(path) {
                return true
            }
        }
        return false
    }
    
    func moveToApplicationFolder() {
        let sourcePath = NSBundle.mainBundle().bundlePath
        let bundleName = sourcePath.lastPathComponent
        let applicationPaths = NSSearchPathForDirectoriesInDomains(.ApplicationDirectory, .LocalDomainMask, true)
        let destPath = (applicationPaths.last as NSString).stringByAppendingPathComponent(bundleName)
        
        let fileManager = NSFileManager.defaultManager()
        let existing = fileManager.fileExistsAtPath(destPath)
        if existing {
            // Terminate running process at destination path.
            let cmd = "ps aux | grep '\(destPath)' | awk '{print $2}' | xargs kill -9"
            let task = NSTask.launchedTaskWithLaunchPath("/bin/sh", arguments: ["-c", cmd])
            task.waitUntilExit()
            
            // Move existing app to trash
            let success = NSWorkspace.sharedWorkspace().performFileOperation(
                NSWorkspaceRecycleOperation,
                source: destPath.stringByDeletingLastPathComponent,
                destination: "",
                files: [bundleName],
                tag: nil
            )
            
            if !success {
                NSLog("Failed to trash existing app.")
            }
        }
        
        // Copy to /Application folder.
        var error: NSError?
        fileManager.copyItemAtPath(sourcePath, toPath: destPath, error: &error)
        if error? != nil {
            NSLog("Error copying file: \(error)")
        }
        
        // Remove downloaded app to trash
        fileManager.removeItemAtPath(sourcePath, error: &error)
        if error? != nil {
            NSLog("Error removing downloaded file: \(error)")
        }
        
        // Run new app
        let cmd = "open \(destPath)"
        let task = NSTask.launchedTaskWithLaunchPath("/bin/sh", arguments: ["-c", cmd])
        task.waitUntilExit()
        
        exit(0)
    }
}
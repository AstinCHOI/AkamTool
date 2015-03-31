//
//  ContentViewController.swift
//  AkamTool
//
//  Created by Astin on 1/31/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

import AppKit
import Snappy

public class ContentViewController: NSViewController {
    
    let titleLabel = LabelButton()
    let hotKeyLabel = Label()
    let separatorView = NSImageView()
    let tabView = NSTabView()
    let spoofingTabViewItem = NSTabViewItem()
    let spoofingTabViewController = SpoofingTabViewController(nibName: "SpoofingTabViewController", bundle: nil)
    
    let indicator = NSProgressIndicator(frame: NSZeroRect)
    let menuButton = NSButton()
    let mainMenu = NSMenu()
    let dictionaryMenu = NSMenu()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public func loadView() {
        self.view = NSView(frame: CGRectMake(0, 0, 450, 550))
        self.view.autoresizingMask = .ViewNotSizable
        self.view.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        // TITLE
        self.view.addSubview(self.titleLabel)
        self.titleLabel.textColor = NSColor.controlTextColor()
        self.titleLabel.font = NSFont.systemFontOfSize(16)
        self.titleLabel.stringValue = "AkamTool"
        self.titleLabel.sizeToFit()
        self.titleLabel.target = self
        self.titleLabel.action = "navigateToMain"
        self.titleLabel.snp_makeConstraints { make in
            make.top.equalTo(10)
            make.centerX.equalTo(self.view)
        }
        
        // SHORTCUT KEY
        self.view.addSubview(self.hotKeyLabel)
        self.hotKeyLabel.textColor = NSColor.headerColor()
        self.hotKeyLabel.font = NSFont.systemFontOfSize(NSFont.smallSystemFontSize())
        self.hotKeyLabel.snp_makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp_bottom).with.offset(2)
            make.centerX.equalTo(self.view)
        }

        // TABVIEW
        self.spoofingTabViewItem.label = "Spoofing"
        self.spoofingTabViewItem.view = spoofingTabViewController?.view
        
        self.tabView.addTabViewItem(spoofingTabViewItem)
        
        self.view.addSubview(self.tabView)
        self.tabView.snp_makeConstraints { make in
            make.top.equalTo(self.hotKeyLabel.snp_bottom).with.offset(8)
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view)
            make.left.right.and.bottom.equalTo(self.view)
        }
        
        self.view.addSubview(self.menuButton)
        self.menuButton.title = ""
        self.menuButton.bezelStyle = .RoundedDisclosureBezelStyle
        self.menuButton.setButtonType(.MomentaryPushInButton)
        self.menuButton.target = self
        self.menuButton.action = "showMenu"
        self.menuButton.snp_makeConstraints { make in
            make.right.equalTo(self.view).with.offset(-10)
            make.centerY.equalTo(self.tabView.snp_top).dividedBy(2)
        }
        
        let mainMenuItems = [
            NSMenuItem(title: "Preference", action: "showPreferenceWindow", keyEquivalent: ","),
            NSMenuItem.separatorItem(),
            NSMenuItem(title: "Quit", action: "quit", keyEquivalent: ""),
        ]
        
        for mainMenuItem in mainMenuItems {
            self.mainMenu.addItem(mainMenuItem)
        }
        
        self.navigateToMain()
    }
    
    public func updateHotKeyLabel() {
        let keyBindingData = NSUserDefaults.standardUserDefaults().dictionaryForKey(UserDefaultsKey.HotKey)
        let keyBinding = KeyBinding(dictionary: keyBindingData)
        self.hotKeyLabel.stringValue = keyBinding.description
        self.hotKeyLabel.sizeToFit()
    }
 
    func navigateToMain() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        self.indicator.startAnimation(self)
        self.indicator.hidden = false
    }

    public func handleKeyBinding(keyBinding: KeyBinding) {
        let key = (keyBinding.shift, keyBinding.control, keyBinding.option, keyBinding.command, keyBinding.keyCode)
        
        switch key {
        case (false, false, false, false, 53):
            // ESC
            AkamToolManager.sharedInstance().close()
            break
            
        case (false, false, false, true, KeyBinding.keyCodeFormKeyString(",")):
            // Command + 1, 2, 3, ...
            self.showPreferenceWindow()
            break
            
        default:
            break
        }
    }
  
    func showMenu() {
        self.mainMenu.popUpMenuPositioningItem(
            self.mainMenu.itemAtIndex(0),
            atLocation:self.menuButton.frame.origin,
            inView:self.view
        )
    }
    
    func showPreferenceWindow() {
        AkamToolManager.sharedInstance().preferenceWindowController.showWindow(self)
    }
    
    func quit() {
        exit(0)
    }
}
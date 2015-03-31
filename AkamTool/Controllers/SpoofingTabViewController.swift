//
//  SpoofingTabViewController.swift
//  AkamTool
//
//  Created by Astin on 2/1/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

import AppKit
import Snappy

public class SpoofingTabViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    let tableScrollView = NSScrollView(frame: NSMakeRect(0, 0, 380, 400))
    let tableHeaderView: NSTableHeaderView = NSTableHeaderView(frame: NSMakeRect(0, 0, 380, 17))
    let tableView = NSTableView(frame: NSMakeRect(0, 0, 380, 400))
    
    let ipTableColumn: NSTableColumn = NSTableColumn(identifier: "ip")
    let hostTableColumn: NSTableColumn = NSTableColumn(identifier: "host")
    
    let ipTableHeaderCell: NSTableHeaderCell = NSTableHeaderCell(textCell: "ip")
    let hostTableHeaderCell: NSTableHeaderCell = NSTableHeaderCell(textCell: "host")
    
    let segmentedControl: NSSegmentedControl = NSSegmentedControl(frame: NSMakeRect(0, 0, 380, 17))
    let segmentedCell: NSSegmentedCell = NSSegmentedCell()
    
    let hostTextField: EditTextField = EditTextField()
    let addButton: NSButton = NSButton()
    
    var spoofingManager: SpoofingManager = SpoofingManager()
    var dataArray:[NSMutableDictionary] = [["ip":"", "host":"", "comment": false]];
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public func loadView() {
        self.view = NSView()
        self.view.autoresizingMask = .ViewNotSizable
        self.view.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        dataArray.removeAtIndex(0); // to prevent nil to dataArray.
        _loadHosts();
        
        
        // TableView
        self.ipTableColumn.headerCell = ipTableHeaderCell
        self.hostTableColumn.headerCell = hostTableHeaderCell
        self.ipTableColumn.width = 140
        self.hostTableColumn.width = 240
        
        self.tableView.headerView = tableHeaderView
        self.tableView.allowsMultipleSelection = true
        self.tableView.usesAlternatingRowBackgroundColors = true
        
        self.tableView.addTableColumn(ipTableColumn)
        self.tableView.addTableColumn(hostTableColumn)
        
        self.tableView.focusRingType = NSFocusRingType.None
        self.tableView.autoresizesSubviews = true
        self.tableView.setDelegate(self)
        self.tableView.setDataSource(self)
        self.tableView.reloadData()
        
        self.tableScrollView.addSubview(tableView)
        self.tableScrollView.addSubview(tableHeaderView)

        self.tableScrollView.documentView = tableView
        self.tableScrollView.hasVerticalScroller = true
        self.tableScrollView.borderType = NSBorderType.BezelBorder

        
        self.view.addSubview(tableScrollView)
        self.tableScrollView.snp_makeConstraints { make in
            make.top.equalTo(10)
            make.width.equalTo(380)
            make.height.equalTo(390)

            make.centerX.equalTo(self.view)
        }
        
        self.segmentedCell.segmentCount = 3
        self.segmentedCell.segmentStyle = NSSegmentStyle.SmallSquare
        self.segmentedCell.trackingMode = NSSegmentSwitchTracking.Momentary
        
        self.segmentedCell.bordered = true
        self.segmentedCell.setLabel("#", forSegment:0)
        self.segmentedCell.setToolTip("Comment hosts", forSegment:0)
        self.segmentedCell.setEnabled(false, forSegment:0)
        self.segmentedCell.setImage(NSImage(named: NSImageNameRemoveTemplate), forSegment:1)
        self.segmentedCell.setToolTip("Remove hosts", forSegment:1)
        self.segmentedCell.setEnabled(false, forSegment:1)
        self.segmentedCell.setWidth(320, forSegment:2)
        self.segmentedCell.setEnabled(false, forSegment:2)
        self.segmentedCell.target = self
        self.segmentedCell.action = "segmentedCellChanged:"

        self.segmentedControl.setCell(self.segmentedCell)
        
        self.view.addSubview(segmentedControl)
        self.segmentedControl.snp_makeConstraints { make in
            make.top.equalTo(self.tableScrollView.snp_bottom)
            make.width.equalTo(self.tableScrollView)
            
            make.centerX.equalTo(self.view)
        }
        
        self.view.addSubview(hostTextField)
        self.view.addSubview(addButton)

        // Host TextField
        let color = NSColor.grayColor()
        let attrs = [NSForegroundColorAttributeName: color]
        let placeHolderStr = NSAttributedString(string: "Akamaized Hostname", attributes: attrs)
        
        self.hostTextField.placeholderAttributedString = placeHolderStr
        self.hostTextField.font = NSFont.systemFontOfSize(13)

        self.hostTextField.editable = true
        self.hostTextField.focusRingType = NSFocusRingType.None
        self.hostTextField.delegate = self

        self.hostTextField.snp_makeConstraints { make in
            make.left.equalTo(self.segmentedControl)
            make.top.equalTo(self.segmentedControl.snp_bottom).with.offset(10)
            make.width.equalTo(320)
            make.height.equalTo(22)
        }

        // Add Button
        self.addButton.title = "Add"
        self.addButton.action = "_addHost"
        self.addButton.snp_makeConstraints { make in
            make.right.equalTo(self.segmentedControl.snp_right)
            make.top.equalTo(self.segmentedControl.snp_bottom).with.offset(10.5)
            make.width.equalTo(50)
            make.height.equalTo(22)
        }
    }
}

extension SpoofingTabViewController {
    func segmentedCellChanged(sender: NSSegmentedCell) {
        switch sender.selectedSegment {
            case 0:
                self._commentHosts()
            case 1:
                self._removeHosts()
            default:
                false // Nothing
        }
    }
    
    // Show /etc/hosts
    func _loadHosts() {
        self.spoofingManager.loadHosts(&dataArray)
    }
    
    // Add Host
    func _addHost() {
        self.spoofingManager.addHost(self.hostTextField.stringValue)
        self.dataArray.removeAll()
        _loadHosts()
        self.tableView.reloadData()
    }
    
    func _commentHosts() {
        let indexes:[Int] = selectedHosts()
        
        var commentListStr = ""
        
        for index in indexes {
            let ip = dataArray[index]["ip"] as NSString
            let host = dataArray[index]["host"] as NSString
            
            if(ip.hasPrefix("#")) {
                commentListStr += "s/\(ip)[[:space:]]\(host)/\(ip.substringFromIndex(1)) \(host)/g;"
            } else {
                commentListStr += "s/\(ip)[[:space:]]\(host)/#\(ip) \(host)/g;"
            }
        }
        //println(commentListStr)
        if commentListStr != "" {
            self.spoofingManager.removeHosts(commentListStr)
            self.dataArray.removeAll()
            _loadHosts()
            self.tableView.reloadData()
        }
    }
    
    func _removeHosts() {
        // sudo sed -i "" "/127.0.0.1 localhost/d;/a b c/d" /etc/hosts
        let indexes:[Int] = selectedHosts()
        
        var removeListStr = ""
        for index in indexes {
            let ip = dataArray[index]["ip"] as NSString
            let host = dataArray[index]["host"] as NSString
            
            removeListStr += "/\(ip)[[:space:]]\(host)/d;"
        }
        
        if removeListStr != "" {
            self.spoofingManager.removeHosts(removeListStr)
            self.dataArray.removeAll()
            _loadHosts()
            self.tableView.reloadData()
        }
    }
    
    func selectedHosts() -> [Int] {
        let selectedRowIndexes = self.tableView.selectedRowIndexes
        
        var indexes = [Int]()
        if selectedRowIndexes.count > 0 {
            selectedRowIndexes.enumerateIndexesUsingBlock { (idx, _) in
                indexes.append(idx)
            }
        }
        return indexes
    }
}

extension SpoofingTabViewController {
    func numberOfRowsInTableView(aTableView: NSTableView!) -> Int
    {
        let numberOfRows:Int = dataArray.count
        return numberOfRows
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject!
    {
        let object = dataArray[row] as NSMutableDictionary
        
        if ((tableColumn.identifier) == "check")
        {
            return object[tableColumn.identifier] as? Int!
        }
        else
        {
            return object[tableColumn.identifier] as? String!
        }
    }
    
    public func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int)
    {
        dataArray[row].setObject(object!, forKey: (tableColumn?.identifier)!)
    }
    
    public func tableViewSelectionDidChange(notification: NSNotification) {
        let selectedRows = selectedHosts()
        let buttonsEnabled = (selectedRows.count != 0)
        self.segmentedCell.setEnabled(buttonsEnabled, forSegment:0)
        self.segmentedCell.setEnabled(buttonsEnabled, forSegment:1)
    }
}

extension SpoofingTabViewController: NSTextFieldDelegate {
    public override func controlTextDidEndEditing(notification: NSNotification?) {
        if notification? == nil {
            return
        }
        
        let key: AnyObject? = notification?.valueForKey("userInfo")
        if (key?.valueForKey("NSTextMovement") as Int == NSReturnTextMovement) {
            _addHost()
        }
    }
}
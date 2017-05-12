//
//  ViewController.swift
//  Informant
//
//  Created by Luigi Sansonetti on 11.05.17.
//  Copyright © 2017 Luigi Sansonetti. All rights reserved.
//

import Cocoa
import Foundation

class GeneralViewController: NSViewController {
    
    // MARK: Variables and constants
    let mask: String = "/24"
    
    // MARK:- Properties
    
    // MARK: Interface
    @IBOutlet weak var interfaceLabel: NSTextField!
    @IBOutlet weak var interfaceSelector: NSPopUpButton!
    @IBAction func changeInterface(_ sender: NSPopUpButton) {
        refresh(self)
    }
    
    // MARK: Addresses
    @IBOutlet weak var IPLabel: NSTextField!
    @IBOutlet weak var IPAddress: NSTextField!
    @IBOutlet weak var MACLabel: NSTextField!
    @IBOutlet weak var MACAddress: NSTextField!
    
    @IBOutlet weak var scanButton: NSButton!
    @IBAction func scanRequested(_ sender: NSButton) {
        scan(IP: IPAddress.stringValue, mask: mask, populate: self)
    }
    
    // MARK: Scan
    @IBOutlet weak var MACAddressesFieldTitle: NSTextField!
    @IBOutlet weak var MACAddresses: NSTextView!
    @IBOutlet weak var IPAddressesFieldTitle: NSTextField!
    @IBOutlet weak var IPAddresses: NSTextView!
    
    // MARK: Ping
    @IBOutlet weak var PingButton: NSButton!
    @IBAction func pingRequested(_ sender: NSButton) {
        ping(self)
    }
    @IBOutlet weak var PingResult: NSTextField!
    
    // MARK: Lookup
    @IBOutlet weak var IPAddressForLookup: NSTextField!
    @IBOutlet weak var LookupButton: NSButton!
    @IBAction func lookupRequested(_ sender: NSButton) {
        lookup(IPAddressForLookup.stringValue)
    }
    
    
    // MARK:- Initialisation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Filling the interface menu.
        interfaceSelector.removeAllItems()
        bash("ifconfig -a | cut -f1") // Getting the interfaces names.
            .components(separatedBy: "\n") // Separating the string into an array.
            .filter { $0 != "" } // removing empty lines.
            .map { $0.components(separatedBy: ":")[0] } // Keeping the interface names only.
            .forEach { interfaceSelector.addItem(withTitle: $0) } // Adding them to the selector.
        interfaceSelector.selectItem(at: 3)
        
        // Getting the IP and MAC addresses.
        refresh(self)
        
        // Setting the visibility and editability of the scan results fields.
        MACAddressesFieldTitle.isHidden = true
        MACAddresses.enclosingScrollView?.isHidden = true
        MACAddresses.isEditable = false
        
        IPAddressesFieldTitle.isHidden = true
        IPAddresses.enclosingScrollView?.isHidden = true
        IPAddresses.isEditable = false
        
        // Setting the visibility of the ping button.
        PingResult.isHidden = true
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}


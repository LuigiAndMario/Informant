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
    
    // MARK: Properties
    
    @IBOutlet weak var interfaceLabel: NSTextField!
    @IBOutlet weak var interfaceSelector: NSPopUpButton!
    
    @IBOutlet weak var IPLabel: NSTextField!
    @IBOutlet weak var IPAddress: NSTextField!
    @IBOutlet weak var MACLabel: NSTextField!
    @IBOutlet weak var MACAddress: NSTextField!
    
    @IBOutlet weak var scanButton: NSButton!
    @IBAction func scanRequested(_ sender: NSButton) {
        scan(IP: IPAddress.stringValue, mask: mask)
    }
    
    
    
    
    // MARK: Actions
    @IBAction func changeInterface(_ sender: NSPopUpButton) {
        refresh(self)
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
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}


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
    
    // MARK: Properties
    
    @IBOutlet weak var interfaceLabel: NSTextField!
    @IBOutlet weak var interfaceSelector: NSPopUpButton!
    
    @IBOutlet weak var IPLabel: NSTextField!
    @IBOutlet weak var IPAddress: NSTextField!
    @IBOutlet weak var MACLabel: NSTextField!
    @IBOutlet weak var MACAddress: NSTextField!
    
    // MARK: Actions
    @IBAction func changeInterface(_ sender: NSPopUpButton) {
        refresh()
    }
    
    // MARK: Variables and constants
    let defaultIP: String = "<None> (interface is down)"
    let defaultMAC: String = "<None> (this interface doesn't have a MAC)"

    // MARK:- Initialisation
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Changing the window title.
        self.view.window?.title = "Informant"
    }
    
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
        refresh()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK:- Network analysis
    
    /// Refreshes the state of the labels whenever the interface is changed.
    func refresh() {
        
        let interfaceName: String = (interfaceSelector.selectedItem?.title)!
        
        // Finding the IP and MAC addresses.
        let outputAsArray: Array = bash("ifconfig -a").components(separatedBy: " ")
        var hasMAC = false
        var hasIP = false
        
        var outputForInterface = outputAsArray.drop(while: { !isInterface($0, interfaceName) }).dropFirst()
        outputForInterface = outputForInterface.prefix(while: { !isInterface($0) })
        
        
        IPAddress.stringValue = defaultIP
        MACAddress.stringValue = defaultMAC
        
        for i in outputForInterface.startIndex ..< outputForInterface.endIndex {
            if outputAsArray[i].range(of: "ether") != nil {
                // MAC address
                MACAddress.stringValue = outputAsArray[i + 1];
                hasMAC = true
            } else if outputAsArray[i].range(of: "inet6") == nil && outputAsArray[i].range(of: "inet") != nil {
                // IP address
                IPAddress.stringValue = outputAsArray[i + 1]
                hasIP = true
            }
                
            if hasMAC && hasIP {
                break
            }
        }
    }
    
    /// Returns true if the the parameter represents an interface.
    private func isInterface(_ value: String) -> Bool {
        for interface in interfaceSelector.itemTitles {
            if isInterface(value, interface) {
                return true
            }
        }
        
        return false
    }
    
    /// Returns true if the the first parameter represents the interface given as second parameter.
    private func isInterface(_ value: String, _ ref: String) -> Bool {
        return value.range(of: ref + ":") != nil
    }
    
    // MARK:- Bash command issuing
    
    /// Allows to issue a bash command and returns its output as a string
    func bash(_ arguments: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c"] + [arguments]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }


}


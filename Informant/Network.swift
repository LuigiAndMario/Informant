//
//  Scanner.swift
//  Informant
//
//  Created by Luigi Sansonetti on 12.05.17.
//  Copyright © 2017 Luigi Sansonetti. All rights reserved.
//

import Cocoa
import Foundation

let defaultIP: String = "<None> (interface is down)"
let defaultMAC: String = "<None> (this interface doesn't have a MAC)"

// MARK:- Interface scanning

/// Refreshes the state of the labels whenever the interface is changed.
func refresh(_ viewController: GeneralViewController) {
    
    let interfaceName: String = (viewController.interfaceSelector.selectedItem?.title)!
    
    // Finding the IP and MAC addresses.
    let outputAsArray: Array = bash("ifconfig -a").components(separatedBy: " ")
    var hasMAC = false
    var hasIP = false
    
    var outputForInterface = outputAsArray.drop(while: { !isInterface($0, interfaceName) }).dropFirst()
    outputForInterface = outputForInterface.prefix(while: { !isInterface($0, of: viewController) })
    
    // Setting the default values for the IP and the MAC addresses
    viewController.IPAddress.stringValue = defaultIP
    viewController.MACAddress.stringValue = defaultMAC
    
    for i in outputForInterface.startIndex ..< outputForInterface.endIndex {
        if outputAsArray[i].range(of: "ether") != nil {
            // MAC address
            viewController.MACAddress.stringValue = outputAsArray[i + 1];
            hasMAC = true
        } else if outputAsArray[i].range(of: "inet6") == nil && outputAsArray[i].range(of: "inet") != nil {
            // IP address
            viewController.IPAddress.stringValue = outputAsArray[i + 1]
            hasIP = true
        }
        
        if hasMAC && hasIP {
            break
        }
    }
}

/// Returns true if the the parameter represents an interface.
private func isInterface(_ value: String, of: GeneralViewController) -> Bool {
    for interface in of.interfaceSelector.itemTitles {
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


// MARK: Network Analysis

func scan(IP: String, mask: String) {
    let popup: NSAlert = NSAlert()
    
    popup.messageText = python("Arpy", "py", "en0", IP + mask) ?? "An error occured."
    
    popup.alertStyle = NSAlertStyle.warning
    popup.addButton(withTitle: "OK")
    
    popup.runModal()
}

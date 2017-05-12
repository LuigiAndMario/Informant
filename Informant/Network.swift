//
//  Scanner.swift
//  Informant
//
//  Created by Luigi Sansonetti on 12.05.17.
//  Copyright © 2017 Luigi Sansonetti. All rights reserved.
//

import Cocoa
import Foundation

// MARK: Values

let defaultIP: String = "<None> (interface is down)"
let defaultMAC: String = "<None> (this interface doesn't have a MAC)"

let pingAddress: String = "www.google.com"

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
private func isInterface(_ value: String, of viewController: GeneralViewController) -> Bool {
    for interface in viewController.interfaceSelector.itemTitles {
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

/// Scans the network for every IP addresses (and their corresponding MAC)
func scan(IP: String, mask: String, populate viewController: GeneralViewController) {
    // Setting the visibility of the addresses fields.
    viewController.MACAddressesFieldTitle.isHidden = true
    viewController.MACAddresses.enclosingScrollView?.isHidden = true
    viewController.IPAddressesFieldTitle.isHidden = true
    viewController.IPAddresses.enclosingScrollView?.isHidden = true
    
    let popup: NSAlert = NSAlert()
    
    if let scanResult = python("Arpy", "py", "en0", IP + mask) {
        var separated = scanResult.components(separatedBy: "\n")
        popup.messageText = separated[1] + separated[2]
        
        separated = separated.dropFirst(4).dropLast().flatMap( {$0.components(separatedBy: " ")} )
        
        // Setting the visibility of the addresses fields.
        viewController.MACAddressesFieldTitle.isHidden = false
        viewController.MACAddresses.enclosingScrollView?.isHidden = false
        viewController.IPAddressesFieldTitle.isHidden = false
        viewController.IPAddresses.enclosingScrollView?.isHidden = false
        
        // Filling the fields
        var index: Int = 1
        for i in separated.startIndex ..< separated.endIndex {
            if (i % 2 == 0) {
                viewController.MACAddresses.textStorage?.append(NSAttributedString(string: String(index) + ": " + separated[i] + "\r\n"))
                viewController.IPAddresses.textStorage?.append(NSAttributedString(string: String(index) + ": " + separated[i + 1] + "\r\n"))
                index += 1
            }
        }
    } else {
        popup.messageText = "An error occured."
    }
    
    popup.alertStyle = NSAlertStyle.warning
    popup.addButton(withTitle: "OK")
    
    popup.runModal()
}

func ping(_ viewController: GeneralViewController) {
    viewController.PingResult.isHidden = false
    viewController.PingResult.stringValue = bash("ping -c 1 " + pingAddress) // taking the output of the ping.
        .components(separatedBy: " ").filter { $0.range(of: "time") != nil }[0] // Keeping only the time.
        .components(separatedBy: "=")[1] // Removing the string "time".
        + " ms."
}

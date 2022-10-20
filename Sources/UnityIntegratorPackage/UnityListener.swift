//
//  UnityListener.swift
//  Minions
//
//  Created by Omar Barrera Peña on 11/04/22.
//

import Foundation

/**
 Manage and receives messages sent from Unity module
 */
public class UnityListener: NSObject, iOSBridgeProtocol {
    
    var delegate: UnityListenerDelegate?
    
    override init() {
        super.init()
        NSClassFromString("FrameworkLibAPI")?.registerAPIforiOSCalls(self)
    }
    
    /**
     Gets a message sent from Unity and sends it to the delegate to perform a task
     
     - Parameters:
        - message: The message sent from Unity and received from the bridge
     */
    internal func message(fromBridge message: String) {
        delegate?.processMessageFromUnity(message)
    }
}

@available(iOS 13.0, *)
extension UnityListener: ObservableObject {
    
}

/**
 Protocol that receives messages sent from Unity and redirects them to a `UIViewController` or `View`
 */
protocol UnityListenerDelegate {
    /**
     Process the message received from Unity to determine whick task is going to be performed in the host app
     
     - Parameters:
        - message: The message sent from Unity and received from the bridge
     */
    func processMessageFromUnity(_ message: String)
}

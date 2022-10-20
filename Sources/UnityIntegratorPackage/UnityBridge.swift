//
//  UnityBridge.swift
//  SwiftUnityBridgeDemo
//
//  Created by Omar Barrera Peña on 20/03/22.
//

import Foundation
/*import UIKit
import UnityFramework

/**
 Loads Unity module inside the host app and handles all its behaviors and allows to send data to Unity
 */
public class UnityBridge: UIResponder, UIApplicationDelegate {
    
    private let dataBundleId = "com.unity3d.framework"
    private let frameworkPath = "/Frameworks/UnityFramework.framework"
    private var unityFrameWork: UnityFramework?
    private static var instance: UnityBridge!
    private static var hostMainWindow: UIWindow!
    private static var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    private static var cachedMessages: [UnityMessage] = []
    private var isInitialized: Bool {
        unityFrameWork?.appController() != nil && unityFrameWork != nil
    }
    
    /**
     The view in which runs the Unity module
     
     - Returns: The `UIView` where the Unity module is running
     */
    public static func getUnityView() -> UIView? {
        return instance.unityFrameWork?.appController().rootView
    }
    
    /**
     The root view controller of the Unity module
     
     - Returns: The `UIViewController` where the Unity module is hosted
     */
    public static func getUnityRootVC() -> UIViewController? {
        return instance.unityFrameWork?.appController().rootViewController
    }
    
    /**
     Initialize or loads the Unity module in the current `UIViewController`
     */
    public static func showUnity() {
        if let instance = UnityBridge.instance, instance.isInitialized {
            instance.showWindow()
        } else {
            UnityBridge().initWindow()
        }
    }
    
    /**
     Hides Unity module from the current `UIViewController`
     */
    public static func hideUnity() {
        UnityBridge.instance?.hideWindow()
    }
    
    /**
     Removes Unity module from the current `UIViewController`
     */
    public static func unloadUnity() {
        UnityBridge.instance?.unloadWindow()
    }
    
    /**
     Pauses Unity module
     */
    public static func pauseUnity() {
        UnityBridge.instance?.unityFrameWork?.pause(true)
    }
    
    /**
     Resumes Unity module
     */
    public static func resumeUnity() {
        UnityBridge.instance?.unityFrameWork?.pause(false)
    }
    
    /**
     Finishes Unity module and host app
     */
    public static func quitUnity() {
        UnityBridge.instance?.quitWindow()
    }
    
    /**
     Sets the window where the Unity module will be loaded
     
     - Parameters:
        - hostMainWindow: The `UIWindow` that will host the unity module
     
     - Precondition: If the host app runs under the new `SwiftUI` app lifecycle the host main window is determined by default so there is no need to execute this method
     
     - Invariant: On apps that supports multiple windows, Unity module is hosted on a new window, so the host window by default is the first in the app array of window objects
     */
    public static func setHostMainWindow(_ hostMainWindow: UIWindow?) {
        UnityBridge.hostMainWindow = hostMainWindow
    }
    
    /**
     Sets the same launching options of the app in the `UIAppDelegate`
     
     - Parameters:
        - launchingOptions: The launch options specified in the `UIAppDelegate`
     
     - Precondition: If the host app only uses `UIWindowSceneDelegate` of runs under the new `SwiftUI` app lifecycle the launching options are determined by default so there is no need to call this method
     */
    public static func setLaunchingOptions(_ launchingOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        UnityBridge.launchOptions = launchingOptions
    }
    
    private func initWindow() {
        if isInitialized {
            showWindow()
            return
        }
        guard let ufw = loadUnityFramework() else {
            return unloadWindow()
        }
        unityFrameWork = ufw
        unityFrameWork?.setDataBundleId(dataBundleId)
        unityFrameWork?.register(self)
        unityFrameWork?.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: UnityBridge.launchOptions)
        sendCachedMessages()
        UnityBridge.instance = self
    }
    
    private func showWindow() {
        if isInitialized {
            unityFrameWork?.showUnityWindow()
            sendCachedMessages()
        }
    }
    
    private func hideWindow() {
        guard let hostWindow = UnityBridge.hostMainWindow else {
            let windowUI = UIApplication.shared.windows[0]
            windowUI.makeKeyAndVisible()
            return
        }
        hostWindow.makeKeyAndVisible()
    }
    
    private func unloadWindow() {
        if isInitialized {
            UnityBridge.cachedMessages.removeAll()
            unityFrameWork?.unloadApplication()
        }
    }
    
    private func quitWindow() {
        if isInitialized {
            UnityBridge.cachedMessages.removeAll()
            unityFrameWork?.quitApplication(0)
        }
    }
    
    private func loadUnityFramework() -> UnityFramework? {
        let bundlePath = Bundle.main.bundlePath + frameworkPath
        guard let bundle = Bundle(path: bundlePath) else { return nil }
        if bundle.isLoaded == false {
            bundle.load()
        }
        let ufw = bundle.principalClass?.getInstance()
        if ufw?.appController() == nil {
            let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
            machineHeader.pointee = _mh_execute_header
            ufw?.setExecuteHeader(machineHeader)
        }
        return ufw
    }
    
    /**
     Send a message to a specific script in Unity
     
     - Parameters:
        - objectName: The name of the object in a scene where you want to send a message
        - methodName: The name of the method or function you want to call
        - message: The data that you want to send to Unity
     
     - Invariant: You can only send strings to Unity so, before sending anything you must convert it to a `String` and reconvert it to the expected value in Unity
     */
    static func sendMessage(objectName: String, methodName: String, message: String) {
        // Send the message right away if Unity is initialized, else cache it
        if let instance = UnityBridge.instance, instance.isInitialized {
            instance.unityFrameWork?.sendMessageToGO(withName: objectName, functionName: methodName, message: message)
        } else {
            let message = UnityMessage(objectName: objectName, methodName: methodName, message: message)
            UnityBridge.cachedMessages.append(message)
        }
    }
    
    private func sendCachedMessages() {
        if !UnityBridge.cachedMessages.isEmpty && isInitialized {
            for message in UnityBridge.cachedMessages {
                unityFrameWork?.sendMessageToGO(withName: message.objectName, functionName: message.methodName, message: message.message)
            }
            UnityBridge.cachedMessages.removeAll()
        }
    }
    
    private struct UnityMessage {
        let objectName: String?
        let methodName: String?
        let message: String?
    }
}

extension UnityBridge: UnityFrameworkListener {
    public func unityDidUnload(_ notification: Notification!) {
        unityFrameWork?.unregisterFrameworkListener(self)
        unityFrameWork = nil
        UnityBridge.hideUnity()
    }
    
    public func unityDidQuit(_ notification: Notification!) {
        unityFrameWork?.unregisterFrameworkListener(self)
        unityFrameWork = nil
    }
}*/

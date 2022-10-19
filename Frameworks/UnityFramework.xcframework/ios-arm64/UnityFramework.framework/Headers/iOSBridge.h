//
//  iOSBridge.h
//  SwiftUnityBridgeDemo
//
//  Created by Valtechie on 19/03/22.
//

#import <Foundation/Foundation.h>

/**
 Protocol that manage the communications from Unity Module and the iOS host app
 */
@protocol iOSBridgeProtocol
/**
 Sends a message to the iOS host app from Unity module
 
 @param message: The message sent from Unity to iOS
 */
@required - (void) messageFromBridge: (NSString*) message;

@end

__attribute__ ((visibility("default")))
@interface FrameworkLibAPI: NSObject
/**
 Connects a class from iOS host app with Unity module
 
 @param id: The protocol registered to receive messages from Unity
 */
+ (void) registerAPIforiOSCalls: (id<iOSBridgeProtocol>) aApi;

@end
//
//  AppDelegate.swift
//  PushToTalkSample
//
//  Created by anz-ryu on 2023/11/17.
//

import UIKit
import PushToTalk
import AVFAudio

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var channelManager: PTChannelManager? = nil
    var channelDescriptor: PTChannelDescriptor? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Task {
            let channelImage = UIImage(named: "ChannelImage")
            channelDescriptor = PTChannelDescriptor(name: "Happy Channel",
                                                    image: channelImage)
            NSLog("liu: start channel manager")
            channelManager = try await PTChannelManager.channelManager(delegate: self, restorationDelegate: self)
            channelManager?.requestJoinChannel(channelUUID: UUID(uuidString: "103e040f-518f-4b5a-8884-2437e9ba0aa9")!, descriptor: channelDescriptor!)
            NSLog("liu: channel manager started")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: PTChannelRestorationDelegate, PTChannelManagerDelegate {
    func channelManager(_ channelManager: PTChannelManager, didJoinChannel channelUUID: UUID, reason: PTChannelJoinReason) {
        NSLog("liu: A")
    }
    
    func channelManager(_ channelManager: PTChannelManager, didLeaveChannel channelUUID: UUID, reason: PTChannelLeaveReason) {
        NSLog("liu: B")
    }
    
    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didBeginTransmittingFrom source: PTChannelTransmitRequestSource) {
        NSLog("liu: C")
    }
    
    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didEndTransmittingFrom source: PTChannelTransmitRequestSource) {
        NSLog("liu: D")
    }
    
    func channelManager(_ channelManager: PTChannelManager, receivedEphemeralPushToken pushToken: Data) {
        NSLog("liu: E")
        NSLog("liu: Data: " + pushToken.debugDescription)
    }
    
    func incomingPushResult(channelManager: PTChannelManager, channelUUID: UUID, pushPayload: [String : Any]) -> PTPushResult {
        NSLog("liu: F")
        guard let activeSpeaker = pushPayload["activeSpeaker"] as? String else {
            // Report that there's no active speaker, so leave the channel.
            return .leaveChannel
        }

        let activeSpeakerImage = UIImage(named: "ChannelImage")
        let participant = PTParticipant(name: activeSpeaker,
                                        image: activeSpeakerImage)
        return .activeRemoteParticipant(participant)
    }
    
    func channelDescriptor(restoredChannelUUID channelUUID: UUID) -> PTChannelDescriptor {
        NSLog("liu: G")
        if let channelDescriptor = channelDescriptor {
            return channelDescriptor
        }
        let channelImage = UIImage(named: "ChannelImage")
        channelDescriptor = PTChannelDescriptor(name: "Happy Channel",
                                                    image: channelImage)
        return channelDescriptor!
    }
    
    func channelManager(_ channelManager: PTChannelManager, didActivate audioSession: AVAudioSession) {
        NSLog("liu: H")
    }

    
    func channelManager(_ channelManager: PTChannelManager, didDeactivate audioSession: AVAudioSession) {
        NSLog("liu: I")
    }
    
}


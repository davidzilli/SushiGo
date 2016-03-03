//
//  ViewController.swift
//  SushiGo
//
//  Created by David Zilli on 12/31/15.
//  Copyright © 2015 Bravebeard. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
    
    @IBOutlet var clientsLabel : UILabel!
    @IBOutlet var sendButton : UIButton!
    @IBOutlet var textfield : UITextField!
    @IBOutlet var chatLabel : UILabel!

    // Multi peer connectivity
    // Advertiser
    private let ServiceType = "SushiGo"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    
    // Browser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    // Session
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    
    required init?(coder aDecoder: NSCoder) {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ServiceType)
        super.init(coder: aDecoder)
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        
        let game = Game(numberOfPlayers: 2)
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sendButton.addTarget(self, action: Selector("sendText"), forControlEvents: UIControlEvents.TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// UI
extension ViewController {
    
    @IBAction func sendText() {
        if let text = self.textfield.text {
            let selfID = UIDevice.currentDevice().name
            let attributedText = "\(selfID):\(text)"
            guard let data = attributedText.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else { return }
            NSLog("%@", "sendText: \(attributedText)")
            if (session.connectedPeers.count > 0) {
                do {
                    try self.session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                } catch {
                    
                }
                self.textfield.text = ""
                if let curString = self.chatLabel.text {
                    self.chatLabel.text = curString + "\n\(attributedText)"
                }
            }
        }
    }
}

extension ViewController : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
         NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}

extension ViewController : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
}

extension ViewController : MCSessionDelegate {
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        NSLog("%@", "didReceiveCertificate")
        certificateHandler(true)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.clientsLabel.text = "\(session.connectedPeers.map({$0.displayName}))"
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        if let curString = self.chatLabel.text {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.chatLabel.text = curString + "\n\(str)"
            }
        }
    }
}


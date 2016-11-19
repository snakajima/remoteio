//
//  ViewController.swift
//  remote.bj
//
//  Created by satoshi on 11/18/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let service:NetService = NetService(domain: "local", type: "_m2mchat._tcp", name: "Demo Server", port:8081)

    override func viewDidLoad() {
        super.viewDidLoad()

        service.delegate = self
        service.publish()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController : NetServiceDelegate {
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("netService:didNotPublish")
    }

    func netServiceWillPublish(_ sender: NetService) {
        print("netServiceWillPublish")
    }
    func netServiceDidPublish(_ sender: NetService) {
        print("netServiceDidPublish")
    }
    func netServiceWillResolve(_ sender: NetService) {
        print("netServiceWillResolve")
    }
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("netServiceWillResolve")
    }
    func netServiceDidStop(_ sender: NetService) {
        print("netServiceDidStop")
    }
}


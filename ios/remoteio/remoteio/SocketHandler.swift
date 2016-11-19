//
//  SocketHandler.swift
//  ioswall
//
//  Created by satoshi on 10/20/16.
//  Copyright © 2016 UIEvolution Inc. All rights reserved.
//

import UIKit

class SocketHandler {
    public static let didLoadConfig = NSNotification.Name("didLoadConfig")
    public static let didConnectionChange = NSNotification.Name("didConnectionChange")
    public static let didGuidsChange = NSNotification.Name("didGuidsChange")
    public private(set) var connected = false
    private let socket:SocketIOClient
    public private(set) var guids = Set<String>()
    public private(set) var verbs = [String]()
    private var config = ["rooms":["Lobby"], "scenes":["Main":"/"]] as [String : Any]
    public var rooms:[String] { return self.config["rooms"] as? [String] ?? [String]() }
    public var scenes:[[String:Any]] { return self.config["scenes"] as? [[String:Any]] ?? [[String:Any]]() }
    public var setups:[String] { return self.config["setups"] as? [String] ?? [String]() }

    init(baseURL:URL, configPath:String) {
        socket = SocketIOClient(socketURL: baseURL, config: [])
        extraInit()
        socket.connect()
        
        let configURL = URL(string: configPath, relativeTo: baseURL)!
        print(configURL.absoluteString)
        SNNet.get(configURL.absoluteString, params:nil) { url, error in
            guard
                error == nil,
                let url = url,
                let data = try? Data(contentsOf: url),
                let json = try? JSONSerialization.jsonObject(with: data),
                let config = json as? [String:Any],
                let _ = config["rooms"] as? [String],
                let _ = config["scenes"] as? [[String:Any]] else {
                return
            }
            self.config = config
            NotificationCenter.default.post(name: SocketHandler.didLoadConfig, object: nil)
        }
    }
    
    private func extraInit() {
        socket.on("connect") { data, ack in
            self.connected = true
            NotificationCenter.default.post(name: SocketHandler.didConnectionChange, object: nil)
            print("socket connected")
        }

        socket.on("/room/message") { (_data, _) in
            //print("on room/message", _data)
            guard let data = _data[0] as? [String:Any],
                  let cmd = data["cmd"] as? String else {
                print("on /room/scene, invalid data ", _data)
                return
            }
            switch(cmd) {
            case "advertise":
                guard let guid = data["guid"] as? String else {
                    return
                }
                self.guids.insert(guid)
                if let verbs = data["verbs"] as? [String], verbs.count > 0 {
                    self.verbs = verbs
                }
                print("on /room/message:advertise", guid, self.guids.count, self.verbs)
                
                NotificationCenter.default.post(name: SocketHandler.didGuidsChange, object: nil)
            case "scene":
                break
            default:
                break
            }
        }
    }
    
    func switchTo(scene:[String:Any]) {
        self.verbs = scene["commands"] as? [String] ?? [String]()
        socket.emit("/room/message", ["cmd":"scene", "scene":scene])
    }
    
    func switchTo(room:String) {
        socket.emit("/room/join", ["name":room])
    }

    func sendAppMessage(data:[String:Any]) {
        socket.emit("/room/message", data)
    }
    
    func add(objects:[String:[String:Any]]) {
        socket.emit("/room/add", objects)
    }
    
    func scan() {
        guids.removeAll()
        socket.emit("/room/message", ["cmd":"scan"])
    }
}

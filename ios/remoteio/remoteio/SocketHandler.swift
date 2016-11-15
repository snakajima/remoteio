//
//  SocketHandler.swift
//  ioswall
//
//  Created by satoshi on 10/20/16.
//  Copyright © 2016 UIEvolution Inc. All rights reserved.
//

import UIKit

class SocketHandler {
    public static let didConnectionChange = NSNotification.Name("didConnectionChange")
    public static let didGuidsChange = NSNotification.Name("didGuidsChange")
    public private(set) var connected = false
    private let socket:SocketIOClient
    private var latency = 0
    private var latencyHistory = [Int]()
    private var roomData = [String:AnyObject]()
    private var beginTime:Int = 0
    public private(set) var guids = Set<String>()
    public private(set) var verbs = [String]()
    private var refreshCount = 0 // only for debugging

    init(baseURL:URL, config:String) {
        socket = SocketIOClient(socketURL: baseURL, config: [])
        extraInit()
        socket.connect()
        
        let configURL = URL(string: config, relativeTo: baseURL)!
        print(configURL.absoluteString)
        SNNet.get(configURL.absoluteString, params:nil) { url, error in
            guard
                error == nil,
                let url = url,
                let data = try? Data(contentsOf: url),
                let json = try? JSONSerialization.jsonObject(with: data) else {
                return
            }
            print(json)
        }
    }
    
    private func extraInit() {
        socket.on("connect") { data, ack in
            self.connected = true
            NotificationCenter.default.post(name: SocketHandler.didConnectionChange, object: nil)
            print("socket connected")

            self.syncTime()
            self.setTimeout(msec:2500, callback:self.syncTime)
            self.setTimeout(msec:5000, callback:self.syncTime)
            self.setTimeout(msec:7500, callback:self.syncTime)
            self.setTimeout(msec:10000, callback:self.syncTime)
            self.setTimeout(msec:15000, callback:self.syncTime)
            self.setTimeout(msec:20000, callback:self.syncTime)
            self.setTimeout(msec:25000, callback:self.syncTime)
            
            // HACK: I'm not sure why we need to add a delay here
            self.setTimeout(msec:100) {
                self.timerTick(fps:60)
            }
        }
        socket.on("/sync") { (_data, _) in
            let now = self.now()
            guard let data = _data[0] as? [String:AnyObject],
                  let time = data["time"] as? Int else {
                print("on /sync, invalid data ", _data)
                return
            }
            var delta = now - time
            if let client = data["client"] as? Int {
                delta -= (now - client) / 2
            }
            
            self.latencyHistory.append(delta)
            self.latency = self.latencyHistory.reduce(0, { (sum:Int, value:Int) -> Int in
                return sum + value
            }) / self.latencyHistory.count
            if self.latencyHistory.count > 10 {
                self.latencyHistory.removeFirst()
            }
        }
        socket.on("/room/info") { (_data, _) in
            print("on room/info", _data)
            guard let _ = _data[0] as? [String:AnyObject] else {
                print("on /room/info, invalid data ", _data)
                return
            }
        }
        
        socket.on("/room/clear") { (_data, _) in
            print("on room/clear", _data)
            self.roomData.removeAll()
            //self.prepareAllElements()
        }
        
        socket.on("/room/refresh") { (_data, _) in
            self.refreshCount += 1
            print("on room/refresh", self.refreshCount)
            guard let data = _data[0] as? [String:AnyObject] else {
                print("on /room/refresh, invalid data ", _data)
                return
            }
            self.roomData = data
            //self.prepareAllElements()
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
                if let verbs = data["verbs"] as? [String] {
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
        // NOTE: This code has never been tested
        /*
        socket.on("/room/patch") { (_data, _) in
            guard let newObjects = _data[0] as? [String:[String:AnyObject]] else {
                print("patch no/invalid objects")
                return
            }
            guard var objects = self.roomData["objects"] as? [String:[String:AnyObject]] else {
                print("prepare no/invalid objects")
                return
            }
            for (name, object) in newObjects {
                var objectCopy = object
                objectCopy["__noreuse"] = true
                objects[name] = objectCopy
            }
            self.roomData["objects"] = objects
            //self.prepareAllElements()
        }
        */
    }
    
    private func syncTime() {
        self.socket.emit("/sync", ["client":Int(self.now())])
    }
    
    private func setTimeout(msec:UInt64, callback: @escaping @convention(block) () -> Swift.Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute:callback)
    }
    
    private func timerTick(fps:UInt64) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        //updateElements()
        CATransaction.commit()

        self.setTimeout(msec:1000 / fps) {
            self.timerTick(fps:fps)
        }
    }

    private func now() -> Int {
        return Int(NSDate().timeIntervalSince1970 * 1000)
    }

    func switchTo(scene:String, path:String) {
        socket.emit("/room/message", ["cmd":"scene", "name":scene, "path":path])
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
        verbs.removeAll()
        socket.emit("/room/message", ["cmd":"scan"])
    }
}

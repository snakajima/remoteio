//
//  SceneViewController.swift
//  ioswall
//
//  Created by satoshi on 10/24/16.
//  Copyright © 2016 UIEvolution Inc. All rights reserved.
//

import UIKit

class SceneViewController: UIViewController {
    var scene = "N/A"
    var handler:SocketHandler!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = scene
        
        handler.scan();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func handlePinches(recognizer:UIPinchGestureRecognizer) {
        let pt = recognizer.location(in: recognizer.view)
        let scale = recognizer.scale
        let state:String
        switch(recognizer.state) {
        case .began:
            state = "pan"
        case .changed:
            state = "changed"
        case .ended:
            state = "ended"
        default:
            state = "cancelled"
        }
        handler.sendAppMessage(data: ["cmd":"pinch", "state":state, "pos":[pt.x, pt.y], "scale":scale])
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let pt = recognizer.location(in: recognizer.view)
        let tx = recognizer.translation(in: recognizer.view)
        let state:String
        switch(recognizer.state) {
        case .began:
            state = "pan"
        case .changed:
            state = "changed"
        case .ended:
            state = "ended"
        default:
            state = "cancelled"
        }
        handler.sendAppMessage(data: ["cmd":"pan", "state":state, "pos":[pt.x, pt.y], "tx":[tx.x, tx.y]])
    }
    
    @IBAction func action(btn:UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        })
        for verb in handler.verbs {
            alert.addAction(UIAlertAction(title: verb, style: .default) { (_) in
                self.handler.sendAppMessage(data: ["cmd" : "custom", "verb":verb])
            })
        }
        self.present(alert, animated: true, completion: nil)
    }
}

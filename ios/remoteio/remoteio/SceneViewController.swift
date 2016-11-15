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
    var scale = CGFloat(1.0)
    var xf = CGPoint.zero

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = scene
        
        handler.scan();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateViewport(scale:CGFloat, xf:CGPoint) {
        handler.sendAppMessage(data: ["cmd":"viewport", "scale":scale, "tx":xf.x, "ty":xf.y])
    }

    @IBAction func handlePinchs(recognizer:UIPinchGestureRecognizer) {
        let scale = self.scale * recognizer.scale
        switch(recognizer.state) {
        case .ended:
            updateViewport(scale: scale, xf:xf)
            self.scale = scale
        case .changed:
            updateViewport(scale: scale, xf:xf)
        default:
            break
        }
    }
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        //print("panning")
        let t = recognizer.translation(in: recognizer.view)
        let xf = CGPoint(x: self.xf.x + t.x, y: self.xf.y + t.y)
        switch(recognizer.state) {
        case .changed:
            updateViewport(scale: scale, xf:xf)
        case .ended:
            updateViewport(scale: scale, xf:xf)
            self.xf = xf
        default:
            break
        }
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

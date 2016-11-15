//
//  ScenePicker
//  ioswall
//
//  Created by satoshi on 10/20/16.
//  Copyright © 2016 UIEvolution Inc. All rights reserved.
//

import UIKit

class ScenePicker: UITableViewController {
    let scenes = ["Main":"/", "Map":"/html/demo1.html"]
    var room = "N/A"
    var scene = "N/A"
    var handler:SocketHandler!
    let notificationManger = SNNotificationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = room
        
        notificationManger.addObserver(forName: SocketHandler.didConnectionChange, object: nil, queue: OperationQueue.main) { [unowned self] (_) in
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func action() {
        handler.scan();
        //handler.add(objects: ["jelly1":["type":"ball", "state":["x":0, "y":10, "z":0]]])
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return handler.connected ? scenes.count : 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "standard", for: indexPath)
        cell.textLabel?.text = Array(scenes.keys)[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        scene = Array(scenes.keys)[indexPath.row]
        handler.switchTo(scene:scene, path:scenes[scene]!)
        performSegue(withIdentifier: "scene", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SceneViewController {
            vc.scene = scene
            vc.handler = handler
        } else if let vc = segue.destination as? ClientController {
            vc.handler = handler
            handler.scan()
        }
    }
}


//
//  ScenePicker
//  ioswall
//
//  Created by satoshi on 10/20/16.
//  Copyright © 2016 UIEvolution Inc. All rights reserved.
//

import UIKit

class ScenePicker: UITableViewController {
    var scenes = [["name":"Main", "path":"/"]] as [[String:Any]]
    var room = "N/A"
    var sceneName = "Main"
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
        scenes = handler.scenes
        return handler.connected ? scenes.count : 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "standard", for: indexPath)
        cell.textLabel?.text = scenes[indexPath.row]["name"] as? String
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var scene = scenes[indexPath.row]
        guard let name = scene["name"] as? String else {
          return
        }
        scene["index"] = indexPath.row
        sceneName = name
        handler.switchTo(scene:scene)
        performSegue(withIdentifier: "scene", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SceneViewController {
            vc.scene = sceneName
            vc.handler = handler
        } else if let vc = segue.destination as? ClientController {
            vc.handler = handler
            handler.scan()
        }
    }
}


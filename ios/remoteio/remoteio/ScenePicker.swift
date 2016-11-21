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
    var index = 0
    var sceneName = "Main"
    var handler:SocketHandler!
    let notificationManger = SNNotificationManager()
    @IBOutlet var btnNext:UIBarButtonItem!

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

    override func numberOfSections(in tableView: UITableView) -> Int {
        let scripts = handler.scripts
        return scripts.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let script = handler.scripts[section]
        return script["title"] as? String
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let script = handler.scripts[section]
        scenes = script["scenes"] as? [[String:Any]] ?? [[String:Any]]()
        return scenes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "standard", for: indexPath)
        cell.textLabel?.text = scenes[indexPath.row]["name"] as? String
        return cell
    }
    
    private func moveTo(index:Int) {
        var scene = scenes[index]
        guard let name = scene["name"] as? String else {
          return
        }
        self.index = index
        scene["index"] = index
        sceneName = name
        handler.switchTo(scene:scene)
        btnNext.isEnabled = (index + 1 < scenes.count)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moveTo(index: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        moveTo(index: indexPath.row)
        performSegue(withIdentifier: "scene", sender: nil)
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
    
    @IBAction func next() {
        if index + 1 < scenes.count {
            moveTo(index: index + 1)
            tableView.selectRow(at: [0, index], animated: true, scrollPosition: UITableViewScrollPosition.none)
        }
    }
}


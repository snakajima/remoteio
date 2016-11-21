//
//  RoomPicker
//  ioswall
//
//  Created by satoshi on 10/20/16.
//  Copyright © 2016 UIEvolution Inc. All rights reserved.
//

import UIKit

class RoomPicker: UITableViewController {
    var handler:SocketHandler!
    var rooms = [[String:Any]]()
    var room:[String:Any]?
    let notificationManger = SNNotificationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Rooms"
        
        notificationManger.addObserver(forName: SocketHandler.didConnectionChange, object: nil, queue: OperationQueue.main) { [unowned self] (_) in
            self.tableView.reloadData()
        }
        notificationManger.addObserver(forName: SocketHandler.didLoadConfig, object: nil, queue: OperationQueue.main) { [unowned self] (_) in
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rooms = handler.rooms
        return handler.connected ? rooms.count : 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "standard", for: indexPath)
        cell.textLabel?.text = rooms[indexPath.row]["name"] as? String
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        room = rooms[indexPath.row]
        if let name = room?["name"] as? String {
            handler.switchTo(room:name)
            performSegue(withIdentifier: "room", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ScenePicker,
           let name = room?["name"] as? String {
            vc.room = name
            vc.handler = handler
        }
    }
}


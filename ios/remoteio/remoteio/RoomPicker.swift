//
//  RoomPicker
//  ioswall
//
//  Created by satoshi on 10/20/16.
//  Copyright © 2016 UIEvolution Inc. All rights reserved.
//

import UIKit

class RoomPicker: UITableViewController {
    var rooms = ["Lobby"]
    var room = "N/A"
    let notificationManger = SNNotificationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        notificationManger.addObserver(forName: SocketHandler.didConnectionChange, object: nil, queue: OperationQueue.main) { [unowned self] (_) in
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
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return 0
        }
        rooms = delegate.handler.rooms
        return delegate.handler.connected ? rooms.count : 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "standard", for: indexPath)
        cell.textLabel?.text = rooms[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let handler = delegate.handler
            room = rooms[indexPath.row]
            handler.switchTo(room:room)
            performSegue(withIdentifier: "room", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if let vc = segue.destination as? ScenePicker {
            vc.room = room
            vc.handler = delegate.handler
        }
    }
}


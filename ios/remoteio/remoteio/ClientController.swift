//
//  ClientController.swift
//  ioswall
//
//  Created by satoshi on 11/3/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

class ClientController: UITableViewController {
    var handler:SocketHandler!
    private let notificationManger = SNNotificationManager()
    private var focusGuid = "n/a"

    override func viewDidLoad() {
        super.viewDidLoad()

        notificationManger.addObserver(forName: SocketHandler.didGuidsChange, object: nil, queue: OperationQueue.main) { [unowned self] (_) in
            self.tableView.reloadData()
        }
    }
    
    @IBAction func refresh() {
        handler.scan()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return handler.guids.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "standard", for: indexPath)
        let guid = handler.guids.sorted()[indexPath.row]
        cell.textLabel?.text = guid

        return cell
    }
    
    private func deselect() {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        handler.sendAppMessage(data: ["cmd":"focus", "guid":focusGuid, "focus":false])
    }
    
    private func swichTo(camera:String) {
        handler.sendAppMessage(data: ["cmd":"camera", "guid":focusGuid, "camera":camera])
        deselect()
    }

    private func swichTo(room:String) {
        handler.sendAppMessage(data: ["cmd":"switch", "guid":focusGuid, "room":room])
        deselect()
        refresh()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        focusGuid = handler.guids.sorted()[indexPath.row]
        let alert = UIAlertController(title: "Camera", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.deselect()
        })
        alert.addAction(UIAlertAction(title: "Full", style: .default) { (_) in
            self.swichTo(camera: "full")
        })
        alert.addAction(UIAlertAction(title: "North West", style: .default) { (_) in
            self.swichTo(camera: "nw")
        })
        alert.addAction(UIAlertAction(title: "North East", style: .default) { (_) in
            self.swichTo(camera: "ne")
        })
        alert.addAction(UIAlertAction(title: "South West", style: .default) { (_) in
            self.swichTo(camera: "sw")
        })
        alert.addAction(UIAlertAction(title: "South East", style: .default) { (_) in
            self.swichTo(camera: "se")
        })
        self.present(alert, animated: true, completion: nil)
        handler.sendAppMessage(data: ["cmd":"focus", "guid":focusGuid, "focus":true])
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("accessoryButtonTapped")
        focusGuid = handler.guids.sorted()[indexPath.row]
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        let alert = UIAlertController(title: "Room", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.deselect()
        })
        alert.addAction(UIAlertAction(title: "Lobby", style: .default) { (_) in
            self.swichTo(room: "Lobby")
        })
        alert.addAction(UIAlertAction(title: "Room1", style: .default) { (_) in
            self.swichTo(room: "Room1")
        })
        alert.addAction(UIAlertAction(title: "Room2", style: .default) { (_) in
            self.swichTo(room: "Room2")
        })
        alert.addAction(UIAlertAction(title: "Room3", style: .default) { (_) in
            self.swichTo(room: "Room3")
        })
        alert.addAction(UIAlertAction(title: "Satoshi", style: .default) { (_) in
            self.swichTo(room: "Satoshi")
        })
        alert.addAction(UIAlertAction(title: "Hideya", style: .default) { (_) in
            self.swichTo(room: "Hideya")
        })
        self.present(alert, animated: true, completion: nil)
        handler.sendAppMessage(data: ["cmd":"focus", "guid":focusGuid, "focus":true])
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

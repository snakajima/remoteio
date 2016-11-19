//
//  NetServicePicker.swift
//  remoteio
//
//  Created by satoshi on 11/18/16.
//  Copyright © 2016 Satoshi Nakajima. All rights reserved.
//

import UIKit

class NetServicePicker: UITableViewController {
    let browser = NetServiceBrowser()
    var services = [NetService]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Servers"
        browser.delegate = self
        browser.searchForServices(ofType: "_m2mchat._tcp", inDomain: "local")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "standard", for: indexPath)
        let service = services[indexPath.row]
        if let hostName = service.hostName {
            cell.textLabel?.text = "http://\(hostName):8080"
        } else {
            cell.textLabel?.text = "Resolving \(service.name) ..."
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let service = services[indexPath.row]
        if let _ = service.hostName {
            performSegue(withIdentifier: "rooms", sender: service)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let roomPicker = segue.destination as? RoomPicker,
           let service = sender as? NetService,
           let hostName = service.hostName {
           roomPicker.handler = SocketHandler(baseURL:URL(string: "http://\(hostName):8080")!, configPath:"/js/config.json")
        }
    }

}

extension NetServicePicker : NetServiceBrowserDelegate {
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("netServiceBrowserWillSearch")
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("netServiceBrowser:didFind", moreComing)
        services.append(service)
        service.delegate = self
        service.resolve(withTimeout: 5)
        if !moreComing {
            tableView.reloadData()
        }
    }
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("netServiceBrowserDidStopSearch")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let index = services.index(of: service) {
            services.remove(at: index)
            tableView.reloadData()
        }
    }
}

extension NetServicePicker : NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("netServiceDidResolveAddress")
        tableView.reloadData()
    }
}

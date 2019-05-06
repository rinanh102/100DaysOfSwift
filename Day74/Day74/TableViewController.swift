//
//  TableViewController.swift
//  Day74
//
//  Created by henry on 06/05/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var notes = ["henry", "dung", "tao"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }



    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)

        // Configure the cell
        cell.textLabel?.text = notes[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DetailView") as? DetailViewController {
         vc.selectedRow = notes[indexPath.row]
            vc.title = notes[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    

   
}

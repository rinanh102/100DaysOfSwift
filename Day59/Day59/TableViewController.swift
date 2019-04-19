//
//  ViewController.swift
//  Day59
//
//  Created by henry on 18/04/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    var countries = [Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "https://restcountries.eu/rest/v2/all"
        
        
        //TODO: use if let to unwrap url, make sure it valid
        if let url = URL(string: urlString){
            // create a Data object use contentOf method. This return the content of url, may throw errors
            if let data = try? Data(contentsOf: url){
                parse(json: data)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row].name
        cell.detailTextLabel?.text =  "Capital: \(countries[indexPath.row].capital)"
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController{
            vc.selectedCountry = countries[indexPath.row]
            print(countries[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)
        }
       
    }
    
    func parse(json : Data){
        // JSONDecoder is dedicated to converting between JSON and Country (Codable ojbect)
        let decoder = JSONDecoder()
        // asking convert json to Country object
        if let jsonCountry = try? decoder.decode([Country].self, from: json){
            // assign country array
            countries = jsonCountry
            tableView.reloadData()
        }
    }
}


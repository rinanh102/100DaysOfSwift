//
//  DetailViewController.swift
//  Day74
//
//  Created by henry on 06/05/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var selectedRow : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let string = selectedRow{
            print(string)
        }
        // Do any additional setup after loading the view.
    }
    

}

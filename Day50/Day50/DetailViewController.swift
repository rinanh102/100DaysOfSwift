//
//  DetailViewController.swift
//  Day50
//
//  Created by henry on 30/03/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var selectedImage : String?
    @IBOutlet weak var imageView: UIImageView!
    
    var content : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedImage = selectedImage {
            imageView.image = UIImage(named: selectedImage)
        }
   
    }
    


}

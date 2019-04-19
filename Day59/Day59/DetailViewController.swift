//
//  DetailViewController.swift
//  Day59
//
//  Created by henry on 18/04/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var lable: UILabel!
   
    var selectedCountry : Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let country = selectedCountry {
            if let url = URL(string: country.flag){
               imageView.load(url: url)
            }
            lable.text =  """
                            Name: \(country.name)
                            Capital: \(country.capital)
                          """
        }
    }
    
}

extension UIImageView{
    func load(url: URL){
        DispatchQueue.global().async {
            [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        //self : UIImageView
                        self?.image = image
                    }
                }
            }
        }
    }
}

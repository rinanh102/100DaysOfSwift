//
//  ViewController.swift
//  Day50
//
//  Created by henry on 30/03/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

     var imageArray = [Image]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImage))
    }
    
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? ImageCell else {
            fatalError("Unable to get ImageCell") }
        let imageCell = imageArray[indexPath.row]
        
        cell.captionLabel.text = imageCell.caption
        
        let path = getDocumentsDirectory().appendingPathComponent(imageCell.name)
        cell.viewImage.image = UIImage(named: path.path)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let imageCell = imageArray[indexPath.row]
            
            let path = getDocumentsDirectory().appendingPathComponent(imageCell.name)
                vc.selectedImage = path.path
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func addImage(){
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
            picker.allowsEditing = true
            //When you set self as the delegate, you'll need to conform not only to the UIImagePickerControllerDelegate protocol, but also the UINavigationControllerDelegate protocol.
            picker.delegate = self
            present(picker, animated: true)
        }
    }
    //MARK: Pick the image and save to disk
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //TODO: extract the image from the dictionary, then it passed as a parameter
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        let newImage = Image(name: imageName, caption: "Unknown")
        
        //TODO: add an alert to get the Caption from user
        let alert = UIAlertController(title: "Add Caption", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "OK", style: .default){
            [weak self, weak alert] _ in
            guard let newCaption = alert?.textFields?[0].text else { return }
            
            newImage.caption = newCaption
            self?.imageArray.append(newImage)
            self?.tableView.reloadData()
        })
        
        dismiss(animated: true, completion: nil)
        present(alert, animated: true)
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}


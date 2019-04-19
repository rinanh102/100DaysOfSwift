//
//  ViewController.swift
//  Project13
//
//  Created by henry on 31/03/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var radius: UISlider!
    var currentImage : UIImage!
    
    var context : CIContext!
    var currentFilter : CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CISepiaTone"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importImage))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
       
    }
    
    @objc func importImage(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        currentImage = image
//        UIView.animate(withDuration: 0.8, delay: 0, options: [], animations: {
//            self.imageView.alpha = 0
//        }, completion: nil)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

    @IBAction func changeFilter(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Filter", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
//        guard let image = imageView.image else { return }
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            let alert = UIAlertController(title: "No Image", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
    }
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func radiusChanged(_ sender: Any) {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputRadiusKey) {currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
}
        guard let image = currentFilter.outputImage else { return }
        if let cgimage = context.createCGImage(image, from: image.extent){
            let spinnedImage = UIImage(cgImage: cgimage)
            imageView.image = spinnedImage
        }
    }
    func applyProcessing(){
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)}
//        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey:  kCIInputRadiusKey)}
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)}
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        guard let image = currentFilter.outputImage else { return }
//        currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        if let cgimage = context.createCGImage(image, from: image.extent){
            let processedImage = UIImage(cgImage: cgimage)
            imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction){
        // make sure we have a valid image before continuing
        guard currentImage != nil else { return }
        //Safety read the title of AlertAction
        guard let actionTitle = action.title else { return }
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
        title = actionTitle
    }
    
    @objc func image(_ image : UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error{
            // we got back an error
            let alert = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Saved!", message: "The image is saved to your photo library.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

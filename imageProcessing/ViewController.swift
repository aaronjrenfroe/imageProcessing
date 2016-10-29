//
//  ViewController.swift
//  imageProcessing
//
//  Created by AaronR on 10/23/16.
//  Copyright © 2016 Aaron Renfroe. All rights reserved.
//

import UIKit
import CoreImage
import AssetsLibrary

class ViewController: UIViewController {

    

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func saveImage(_ sender: AnyObject) {
        
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self,#selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //logAllFilters()
        //let image = UIImage(named: "dark1.jpg")!
        var newImage: UIImage? = nil
        let start = 4562
        let finish = 4594
        
        for index1 in start...finish{
            
            let image = (UIImage(named:"IMG_\(index1).JPG")!)
            if newImage == nil{
                newImage = image
            }
            else{
                newImage = overLay2(image1: newImage!, image2: image).toUIImage()!
            }
            print(index1)
            
            
         
        }
        
        
        
        let filter = CIFilter(name: "CIMedianFilter")
        filter?.setValue(CIImage(image: newImage!), forKey: kCIInputImageKey)
        //filter?.setValue(0.5, forKey: kCIInputIntensityKey)
        
        let outImage = filter?.outputImage
        
        
        //set sned image to UIImageView on divice
        //imageView.image = UIImage(ciImage: outImage!)
        //imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = newImage
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func logAllFilters() {
        let properties = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
        print(properties)
        
        for filterName in properties {
            let fltr = CIFilter(name:filterName as String)
            print(fltr!.attributes)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("There is a memory warning _*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*_*")
        // Dispose of any resources that can be recreated.
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Figure out Why", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    


}


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

    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //logAllFilters()
        //let image = UIImage(named: "dark1.jpg")!
        var newImage: UIImage? = nil
        let start = 0
        let finish = 30
        
        for index1 in start...finish{
            
            let image = (UIImage(named:"IMG_\(index1).JPG")!)
            //if first run through loop newImage will be nil
            if newImage == nil{
                newImage = image
            }
            // all other times do normal stuff
            else{
                newImage = average(image1: newImage!, image2: image).toUIImage()!
            }
            print(index1) // prints current image index
         
        }
        
        imageView.image = newImage
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}

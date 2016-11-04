//
//  ViewController.swift
//  imageProcessing
//
//  Created by Aaronr on 10/23/16.
//  Copyright © 2016 Aaronr. All rights reserved.
//

import UIKit
import CoreImage
import AssetsLibrary

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var newImage: UIImage? = nil
        let start = 4017
        let finish = 4048
        
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
            // can a Do somethine here to free up memory
            print(index1) // prints current image index
         
        }
        
        imageView.image = newImage
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // can I put something here to free up some memory

    }

}

//
//  PauseMenu.swift
//  Dodger Me!
//
//  Created by Guan Wong on 2/18/15.
//  Copyright (c) 2015 Guan Wong. All rights reserved.
//

import UIKit
import SpriteKit

/*@objc protocol UnpauseDelegate{
    // add all functions you want to be able to use
    optional func callUnpause()
}*/

protocol PauseMenuDelegate{
    func callUnpause()
}


class PauseMenuController: UIViewController {
    
   // deinit{
    //    print(" pausemenu being deInitialized.");
        
   // }
    
    var delegate:PauseMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        view.frame = CGRectMake(view.center.x/2 , view.center.y/2, self.view.frame.width * 0.5, self.view.frame.height * 0.5)
       // UIGraphicsBeginImageContext(view.frame.size)
        let background_img = UIImage(named: "sprites/pause_img")
     //   background_img?.drawInRect(self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: background_img!)
        
        
        let continueButton = UIButton (frame: CGRectMake(view.frame.width/4,view.frame.height/2,100,50))
        continueButton.setTitle("CONTINUE", forState: .Normal)
        continueButton.titleLabel?.font = UIFont(name: "Chalkduster", size: 15)
        continueButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        continueButton.backgroundColor = UIColor.darkGrayColor()
        continueButton.addTarget(self, action: "continueGame", forControlEvents: .TouchUpInside)
        continueButton.layer.cornerRadius = 5.0
        view.addSubview(continueButton)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @IBAction func continueGame(){
            //print("THE VALUE IS: \(self.paused)")
       delegate?.callUnpause()
      view.removeFromSuperview()
    }
    
}
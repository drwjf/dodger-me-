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


protocol MessageMenuDelegate{
    func reset_score(mode:String)
}


class MessageMenuController: UIViewController {
    
    // deinit{
    //    print(" pausemenu being deInitialized.");D
    
    // }
    
    var theMode:String? // the mode
    var delegate:MessageMenuDelegate?
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate // Create reference to the app delegate
    
    var BUTTON_WIDTH:CGFloat = 100.0 * 0.7
    var BUTTON_HEIGHT:CGFloat = 50.0 * 0.7
    var BUTTON_LETTER_SIZE:CGFloat = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let ratio = appDelegate.screenSize.width/appDelegate.screenSize.height
        
        if (ratio != 0.5625){
            fixRatio(ratio)
        }
        
        view.frame = CGRectMake(view.center.x/2 , view.center.y/2, self.view.frame.width * 0.5, self.view.frame.height * 0.5)
        // UIGraphicsBeginImageContext(view.frame.size)
        let background_img = UIImage(named: "sprites/pause_img")
        
        let someImage = UIImageView(frame: self.view.bounds)
        someImage.image = background_img
        
        someImage.contentMode = .ScaleAspectFit
        //   background_img?.drawInRect(self.view.bounds)
        //  self.view.backgroundColor = UIColor(patternImage: background_img)
        
        //print("view_width: \(view.frame.width), view_height: \(view.frame.height)")
        //self.view.sendSubviewToBack(someImage)
        self.view.addSubview(someImage)
        
        let continueButton = UIButton (frame: CGRectMake(view.frame.width/4 + 18, view.frame.height/2,BUTTON_WIDTH,BUTTON_HEIGHT))
        continueButton.setTitle("CONTINUE", forState: .Normal)
        continueButton.titleLabel?.font = UIFont(name: "Chalkduster", size: BUTTON_LETTER_SIZE)
        continueButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        continueButton.backgroundColor = UIColor.darkGrayColor()
        continueButton.addTarget(self, action: "continueGame", forControlEvents: .TouchUpInside)
        continueButton.layer.cornerRadius = 5.0
        view.addSubview(continueButton)
    
        let yesButton = UIButton (frame: CGRectMake(view.frame.width/4 - 24, view.frame.height/2 + 60,BUTTON_WIDTH,BUTTON_HEIGHT))
        yesButton.setTitle("yes", forState: .Normal)
        //yesButton.center = CGPointMake(view.center.x, view.center.y)
        yesButton.titleLabel?.font = UIFont(name: "Chalkduster", size: BUTTON_LETTER_SIZE)
        yesButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        yesButton.backgroundColor = UIColor.darkGrayColor()
        yesButton.addTarget(self, action: "yes:", forControlEvents: .TouchUpInside)
        yesButton.tag = 2
        yesButton.layer.cornerRadius = 5.0
        view.addSubview(yesButton)
        
        let noButton = UIButton (frame: CGRectMake(view.frame.width/4 + 60, view.frame.height/2 + 60,BUTTON_WIDTH,BUTTON_HEIGHT))
        noButton.setTitle("no", forState: .Normal)
        noButton.titleLabel?.font = UIFont(name: "Chalkduster", size: BUTTON_LETTER_SIZE)
        noButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        noButton.backgroundColor = UIColor.darkGrayColor()
        noButton.addTarget(self, action: "no", forControlEvents: .TouchUpInside)
        noButton.layer.cornerRadius = 5.0
        view.addSubview(noButton)
    }
    
    func fixRatio(curr_ratio:CGFloat){
        //  print("THE RATIO IS: \(curr_ratio)")
        
        var RATIO:CGFloat = 1.0
        
        //      var FIX_X:CGFloat = 0.0
        
        // iPhone 4S
        if (curr_ratio > 0.6){
            RATIO = 0.6333
            //      FIX_X = 20.0
        }
            
        else if (curr_ratio >= 0.562 && curr_ratio < 0.563){
            RATIO = 0.9
        }
        else{
            RATIO = 0.76
        }
        
        BUTTON_WIDTH *= RATIO
        BUTTON_HEIGHT  *= RATIO
        BUTTON_LETTER_SIZE *= RATIO
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @IBAction func yes(sender: UIButton!){
       
        print("the tag is: \(sender.tag)")
        //print("THE VALUE IS: \(self.paused)")
     //   delegate?.reset_score("classic")
   //     view.removeFromSuperview()
    }
    
    @IBAction func no(){
        print("no button clicked")
        //print("THE VALUE IS: \(self.paused)")
       // delegate?.reset_score("insane")
        view.removeFromSuperview()
    }
    
    @IBAction func continueGame(){
        //print("THE VALUE IS: \(self.paused)")
        //   delegate?.restart_scene()
        view.removeFromSuperview()
    }
    
}
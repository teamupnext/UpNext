//
//  guestVC.swift
//  SpotifyTest
//
//  Created by Shivan Desai on 4/13/17.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import UIKit
import Firebase

class guestVC: UIViewController {

    @IBOutlet weak var text1: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func joinPartyClicked(_ sender: Any) {
        userIsHost = false
        if text1.text != ""{
            var ref : FIRDatabaseReference?
            ref = FIRDatabase.database().reference()
            ref?.child("hosts").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(self.text1.text!){
                    hostName = self.text1.text!
                    self.performSegue(withIdentifier: "guestSegue", sender: nil)
                }
                else{
                    let alert = UIAlertController(title: "Whoops!", message: "There is no Host with this code", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("There is no host with this name ...")
                }
            })
        }
        print("User is host : \(userIsHost)")
    }
    
    @IBAction func onTapScreen(_ sender: Any) {
        self.view.endEditing(true)
    }
    
}

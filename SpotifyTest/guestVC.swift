//
//  guestVC.swift
//  SpotifyTest
//
//  Created by Shivan Desai on 4/13/17.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import UIKit

class guestVC: UIViewController {

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
        self.performSegue(withIdentifier: "guestSegue", sender: nil)
        print("User is host : \(userIsHost)")
    }
}
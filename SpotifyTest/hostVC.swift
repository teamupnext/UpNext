//
//  hostVC.swift
//  SpotifyTest
//
//  Created by Shivan Desai on 4/13/17.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

var userIsHost : Bool = true// true -> "HOST" | false -> "GUEST"
var hostName : String = ""

class hostVC: UIViewController {

    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        text1.text = ""
        text2.text = ""

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
 //   var flag = 0

    @IBAction func createPartyClicked(_ sender: Any) {
        userIsHost = true
        if text1.text != "" && text2.text != ""{
            var ref : FIRDatabaseReference?
            ref = FIRDatabase.database().reference()
            print(ref)
            ref?.child("hosts").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(self.text1.text!){
                    let alert = UIAlertController(title: "Whoops!", message: "There is already a host with this code", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("There is already a host ...")
                }
                else{
                    
                    print(snapshot.value)
                    ref?.child("hosts").child(self.text1.text!).setValue("1")
                    ref?.child("passwords").child(self.text1.text!).setValue(self.text2.text!)
                    print("in create")
                    hostName = self.text1.text!
                    self.performSegue(withIdentifier: "hostSegue", sender: nil)
                }
            })
        }
    }
    
    
    @IBAction func joinExistingClicked(_ sender: Any) {
        userIsHost = true
        if text1.text != "" && text2.text != ""{
            var ref : FIRDatabaseReference?
            ref = FIRDatabase.database().reference()
            ref?.child("hosts").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(self.text1.text!){
                    hostName = self.text1.text!
                    
//                    self.performSegue(withIdentifier: "hostSegue", sender: nil)
                }
                else{
                    let alert = UIAlertController(title: "Whoops!", message: "There is no host with this code", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("There is no host with this name ...")
                }
            })
            ref?.child("passwords").child(self.text1.text!).observeSingleEvent(of: .value, with: { (snapshot) in
                let whatever = snapshot.value as! String
                if whatever == self.text2.text{
                    self.performSegue(withIdentifier: "hostSegue", sender: nil)
                }
                else{
                    let alert = UIAlertController(title: "Whoops!", message: "You entered the wrong password", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("The password is wrong")
                }
            })
        }
    }
    
    @IBAction func onTapScreen(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    

    
    
}

            
            
            
            
            
            
            
            
/*            var DBRef = ref?.child("Party Codes")
            DBRef.
            
            observe(.childAdded, with: { (snapshot) in
                let post = snapshot.value as? String
                
                if let actualPost = post {
                    print("actualPost\t"+actualPost)
                    print("text\t"+self.text1.text!)
                    print("flag\t\(self.flag)")
                    if actualPost == self.text1.text {
                        self.flag = 1
                    }
                }
            })
            
            databaseRef.child("Party Codes").observeSingleEvent(of: .value, with: {(snapshot) in
                print(snapshot.childrenCount) // I got the expected number of items
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    let code = rest.value as! String
                    print(rest.value!)
//                    if rest.value == text1.text {
//                        flag = 1
//                    }
                }
//                let value = snapshot.value as? NSDictionary
//                let code = value?["code"] as? String ?? ""
//                if code == self.text1.text! {
//                    flag = 1
//                }
                
                //}
                //else {
                //    print("same same \n")
                //}
            })
            
            if flag == 0 {
                print("if")
                ref?.child("Party Codes").childByAutoId().setValue(self.text1.text)
                //self.performSegue(withIdentifier: "hostSegue", sender: nil)
            }else {
                print("else")
            }
 
        }
    }
}*/

//
//  upNextListViewController.swift
//  SpotifyTest
//
//  Created by Shivan Desai on 4/9/17.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

struct liking{
    var likesForSong : Int
    var liked : Bool!
    var trackID : String!
}

var songList = [post]()
var myLikes = [liking]()

var npArtist : String = ""
var npSong : String = ""
var npImage : UIImage? = nil

var restart : Bool = false
var lastSong : Bool = false

var numAppeared : Int = 0

protocol SongLikingDelegate {
    func likeAction(_ sender: upNextListTableViewCell)
}

class upNextListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SongLikingDelegate {
    @IBOutlet weak var nowPlayingView: UIView!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var nowPlayingImage: UIImageView!
    @IBOutlet weak var nowPlayingSong: UILabel!
    
    

    
    @IBOutlet weak var tableView2: UITableView!
    override func viewDidLoad() {
        
        
        navigationController?.navigationBar.barTintColor = UIColor(red:59/255, green: 132/255 , blue: 29/255, alpha: 1)
        
        super.viewDidLoad()
        tableView2.delegate = self
        tableView2.dataSource = self
        tableView2.reloadData()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(upNextListViewController.ViewTapped))
        self.nowPlayingView.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }
    
    func ViewTapped(){
        if userIsHost == true{
            self.performSegue(withIdentifier: "showPlayer", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        let ref = FIRDatabase.database().reference()
        let hostRef = ref.child("hosts").child(hostName)
        ref.child("NowPlaying").child(hostName).observe(FIRDataEventType.value, with: {(snapshot) in
            if snapshot.exists(){
            let npl = snapshot.value as! NSDictionary
            self.nowPlayingArtist.text = npl["artist"] as! String
            self.nowPlayingSong.text = npl["name"] as! String
            let mainImageURL = URL(string: npl["image"] as! String)
            let mainImageData = NSData(contentsOf: mainImageURL!)
            let myMainImage = UIImage(data: mainImageData! as Data)
            self.nowPlayingImage.image = myMainImage
            }
        })
        hostRef.observe(FIRDataEventType.value, with: {(snapshot) in
            songList.removeAll()
            var myLikes2 = myLikes
            myLikes.removeAll()
            if snapshot.hasChildren(){
                let allSongs = snapshot.value as! NSArray
                for i in 0..<allSongs.count{
//                    print("no.of Songs : \(allSongs.count)")
                    var aSong = allSongs[i] as! [String : Any]
                    songList.append(post.init(mainImage: aSong["image"] as! NSString, name: aSong["name"] as! String, artistName: aSong["artist"] as! String, trackU: aSong["track"] as! String, likes: aSong["likes"] as! Int, liked: false ))
                    myLikes.append(liking.init(likesForSong: aSong["likes"] as! Int, liked: false, trackID: aSong["track"] as! String))
                }
            }
            for i in 0..<myLikes2.count{
                for j in 0..<myLikes.count{
                    if myLikes2[i].trackID == myLikes[j].trackID{
                        myLikes[j].liked = myLikes2[i].liked
                    }
                }
            }
            self.tableView2.reloadData()
        })
        if userIsHost == false{
//            goToPlayer.isHidden = true
        }else{
            if songList.count == 1 && numAppeared == 0{
                numAppeared = numAppeared + 1
                self.performSegue(withIdentifier: "showPlayer", sender: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return songList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell1 = tableView2.dequeueReusableCell(withIdentifier: "upNextListCell", for: indexPath) as! upNextListTableViewCell
        cell1.songLabel.text = songList[indexPath.row].name
        cell1.artistLabel.text = songList[indexPath.row].artistName
        let mainImageURL = URL(string: songList[indexPath.row].mainImage! as String)
        let mainImageData = NSData(contentsOf: mainImageURL!)
        let myMainImage = UIImage(data: mainImageData! as Data)
        cell1.coverImage.image = myMainImage
        cell1.delegate = self
        if myLikes[indexPath.row].liked == true{
            cell1.likeButton.setTitle("Unlike", for: .normal)
        }
        else{
            cell1.likeButton.setTitle("Like", for: .normal)
        }
        cell1.likesLabel.text = String(songList[indexPath.row].likes!)
        return cell1
    }
    
    func likeAction(_ sender: upNextListTableViewCell) {
        var likesDictionary = [NSDictionary]()
        let indexPath = tableView2.indexPath(for: sender)!
        if myLikes[indexPath.row].liked == false{
            songList[indexPath.row].likes = songList[indexPath.row].likes + 1
            myLikes[indexPath.row].likesForSong = myLikes[indexPath.row].likesForSong + 1
            myLikes[indexPath.row].liked = true
            print("row : \(indexPath.row) and likes : \(songList[indexPath.row].likes)")
            let ref = FIRDatabase.database().reference()
            let hostRef = ref.child("hosts").child(hostName)
            hostRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
                let allSongs = snapshot.value as! NSArray
                for i in 0..<allSongs.count{
                    var aSong = allSongs[i] as! NSDictionary
                    var nLikes = aSong["likes"] as! Int
                    if i == indexPath.row{
                        nLikes = nLikes + 1
                    }
                    let newSong : NSDictionary = [
                        "artist" : aSong["artist"],
                        "name" : aSong["name"],
                        "track" : aSong["track"],
                        "likes" : nLikes,
                        "image" : aSong["image"]
                    ]
                    likesDictionary.append(newSong)
                }
                let myArray = likesDictionary as NSArray
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "likes", ascending: false)
                let sortedResults: NSArray = myArray.sortedArray(using: [descriptor]) as NSArray
                hostRef.setValue(sortedResults)
                print("sortedSongs : \(sortedResults)")
                songList.sort{ // sorts in descending order of likes
                    return $0.likes > $1.likes
                }
                myLikes.sort{
                    return $0.likesForSong > $1.likesForSong
                }
                self.tableView2.reloadData()
            })
            
            
        }else{
            songList[indexPath.row].likes = songList[indexPath.row].likes - 1
            myLikes[indexPath.row].likesForSong = myLikes[indexPath.row].likesForSong - 1
            myLikes[indexPath.row].liked = false
            print("row : \(indexPath.row) and likes : \(songList[indexPath.row].likes)")
            let ref = FIRDatabase.database().reference()
            let hostRef = ref.child("hosts").child(hostName)
            hostRef.observeSingleEvent(of: FIRDataEventType.value, with: {(snapshot) in
                let allSongs = snapshot.value as! NSArray
                for i in 0..<allSongs.count{
                    var aSong = allSongs[i] as! NSDictionary
                    var nLikes = aSong["likes"] as! Int
                    if i == indexPath.row{
                        nLikes = nLikes - 1
                    }
                    let newSong : NSDictionary = [
                        "artist" : aSong["artist"],
                        "name" : aSong["name"],
                        "track" : aSong["track"],
                        "likes" : nLikes,
                        "image" : aSong["image"]
                    ]
                    likesDictionary.append(newSong)
                }
                let myArray = likesDictionary as NSArray
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "likes", ascending: false)
                let sortedResults: NSArray = myArray.sortedArray(using: [descriptor]) as NSArray
                hostRef.setValue(sortedResults)
                print("sortedSongs : \(sortedResults)")
                songList.sort{ // sorts in descending order of likes
                    return $0.likes > $1.likes
                }
                myLikes.sort{
                    return $0.likesForSong > $1.likesForSong
                }
                self.tableView2.reloadData()
            })
            

        }
      
    }
    
}

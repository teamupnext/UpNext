//
//  upNextListViewController.swift
//  SpotifyTest
//
//  Created by Shivan Desai on 4/9/17.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import UIKit

struct liking{
    var likesForSong : Int
    var liked : Bool!
}

var songList = [post]()
var myLikes = [liking]()

var npArtist : String = ""
var npSong : String = ""
var npImage : UIImage? = nil

var restart : Bool = false
var lastSong : Bool = false

var numAppeared : Int = 0

class upNextListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var nowPlayingView: UIView!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var nowPlayingImage: UIImageView!
    @IBOutlet weak var nowPlayingSong: UILabel!
    
    
//    @IBOutlet weak var goToPlayer: UIButton!
    
    @IBOutlet weak var tableView2: UITableView!
    override func viewDidLoad() {
  //      songList.append(post.init(mainImage: nil, name: "First", artistName: "ss", trackU: "sd", likes: 0, liked: false ))
    //    songList.append(post.init(mainImage: nil, name: "Second", artistName: "dd", trackU: "fw", likes: 0, liked: false ))
      //  songList.append(post.init(mainImage: nil, name: "Third", artistName: "fwef", trackU: "fve", likes: 0, liked: false ))
//        myLikes.append(liking.init(likesForSong: 0, liked: false))
  //      myLikes.append(liking.init(likesForSong: 0, liked: false))
    //    myLikes.append(liking.init(likesForSong: 0, liked: false))
        super.viewDidLoad()
        tableView2.delegate = self
        tableView2.dataSource = self
        tableView2.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "ViewTapped")
        self.nowPlayingView.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }
    
    func ViewTapped(){
        if userIsHost == true{
            self.performSegue(withIdentifier: "showPlayer", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView2.reloadData()
        nowPlayingArtist.text = npArtist
        nowPlayingImage.image = npImage
        nowPlayingSong.text = npSong
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
        cell1.coverImage.image = songList[indexPath.row].mainImage
        cell1.likeButton.tag = indexPath.row
        cell1.likeButton.addTarget(self, action: #selector(upNextListViewController.likeAction(_:)), for: .touchUpInside)
        
        return cell1
    }
    
    @IBAction func likeAction(_ sender: UIButton){
        if myLikes[sender.tag].liked == false{
            songList[sender.tag].likes = songList[sender.tag].likes + 1
            myLikes[sender.tag].likesForSong = myLikes[sender.tag].likesForSong + 1
            myLikes[sender.tag].liked = true
            print("row : \(sender.tag) and likes : \(songList[sender.tag].likes)")
            
        }else{
            songList[sender.tag].likes = songList[sender.tag].likes - 1
            myLikes[sender.tag].likesForSong = myLikes[sender.tag].likesForSong - 1
            myLikes[sender.tag].liked = false
            print("row : \(sender.tag) and likes : \(songList[sender.tag].likes)")
        }
        songList.sort{ // sorts in descending order of likes
            return $0.likes > $1.likes
        }
        myLikes.sort{
            return $0.likesForSong > $1.likesForSong
        }
        tableView2.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
    @IBAction func goToPlayerClicked(_ sender: Any) {
        if userIsHost == true{
            self.performSegue(withIdentifier: "showPlayer", sender: nil)
        }
    }*/

}

//
//  FirstViewController.swift
//  SpotifyTest
//
//  Created by Shivan Desai on 4/7/17.
//  Copyright © 2017 Seth Rininger. All rights reserved.
//

import UIKit
import Alamofire

struct post{
    let mainImage : UIImage!
    let name : String!
    let artistName : String!
    let trackU : String!
    var likes : Int!
    var liked : Bool!
}

var posts = [post]()


class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var addSongButton: UIButton!
    var indexOfSong : Int = -1

    var searchURL = String()
    
    var aSong : post? = nil
    
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    typealias JSONStandard = [String : AnyObject]
    
    @IBOutlet weak var tableView: UITableView!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        posts.removeAll()
        let keywords = mySearchBar.text
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)&market=US&type=track"
        callAlamo(url: searchURL)
        self.view.endEditing(true)
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSongButton.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableViewCell
        cell.Song.text = posts[indexPath.row].name
        cell.Description.text = posts[indexPath.row].artistName
        cell.CoverImage.image = posts[indexPath.row].mainImage
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        indexOfSong = (indexPath?.row)!
        addSongButton.isHidden = false
    }
    
    @IBAction func AddSongClicked(_ sender: Any) {
//        if songList.count == 0{
  //          restart = true
    //    }
        aSong = posts[indexOfSong]
        songList.append(post.init(mainImage: aSong?.mainImage, name: aSong?.name, artistName: aSong?.artistName, trackU: aSong?.trackU, likes: 0, liked: false ))
        myLikes.append(liking.init(likesForSong: 0, liked: false))
//        self.performSegue(withIdentifier: "showSongList", sender: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
 
    func callAlamo(url: String){
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
            self.ParseData(JSONData: response.data!)
            
        })
    }
    
    func ParseData(JSONData : Data){
        do{
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                if let items = tracks["items"] as? [JSONStandard]{
                    for i in 0..<items.count{
                        var artist : String
                        let item = items[i]
                        let name = item["name"] as! String
                        let mTrack = item["uri"] as! String
                        //names.append(name)
                        let artists = item["artists"] as? [JSONStandard]
                        let artist1 = (artists?[0])! as JSONStandard
                        artist = artist1["name"] as! String
                        //artistsArray.append(artist)
                        
                        if let album = item["album"] as? JSONStandard{
                            if let images = album["images"] as? [JSONStandard]{
                                let imageData = images[0]
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                let mainImage = UIImage(data: mainImageData as! Data)
                                //allImages.append(mainImage!)
                                posts.append(post.init(mainImage: mainImage, name: name, artistName: artist, trackU: mTrack, likes: 0, liked: false ))
                                self.tableView.reloadData()
                            }
                        }
                        
                        //self.tableView.reloadData()
                    }
                }
            }
            print(readableJSON)
        }
        catch{
            print(error)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
/*    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
//        let movie = movies?[(indexPath?.row)!]
        let destViewController = segue.destination as! ViewController
//        detailViewController.movie = movie
        destViewController.myTrack = "spotify:track:60vvp6UXG2KmLmrNvcVHa8"
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
*/
    

    
}

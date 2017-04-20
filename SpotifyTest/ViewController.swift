//
//  ViewController.swift
//  SpotifyTest
//
//  Created by Seth Rininger on 11/11/16.
//  Copyright © 2016 Seth Rininger. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

var myCounter : Int = 0
let audioSession = AVAudioSession.sharedInstance()
var isChangingProgress: Bool = false

class ViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var artistTitle: UILabel!
    @IBOutlet weak var playbackSourceTitle: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var coverView2: UIImageView!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    var myTrack: String = "spotify:track:1RiuVQWyC7g7tL3niYzHKP"//spotify:track:60vvp6UXG2KmLmrNvcVHa8"
    
//    var isChangingProgress: Bool = false
//    let audioSession = AVAudioSession.sharedInstance()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
//        self.trackTitle.text = "Nothing Playing"
  //      self.artistTitle.text = ""
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func rewind(_ sender: UIButton) {
        SPTAudioStreamingController.sharedInstance().skipPrevious(nil)
    }
    
    @IBAction func playPause(_ sender: UIButton) {
        SPTAudioStreamingController.sharedInstance().setIsPlaying(!SPTAudioStreamingController.sharedInstance().playbackState.isPlaying, callback: nil)
        print("position: \(SPTAudioStreamingController.sharedInstance().playbackState.position)")
    }
    
    @IBAction func fastForward(_ sender: UIButton) {
        SPTAudioStreamingController.sharedInstance().skipNext(nil)
    }

    @IBAction func seekValueChanged(_ sender: UISlider) {
        isChangingProgress = false
        let dest = SPTAudioStreamingController.sharedInstance().metadata!.currentTrack!.duration * Double(self.progressSlider.value)
        SPTAudioStreamingController.sharedInstance().seek(to: dest, callback: nil)
    }
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        if (SPTAudioStreamingController.sharedInstance() != nil) {
            SPTAudioStreamingController.sharedInstance().logout()
        }
        else {
            _ = self.navigationController!.popViewController(animated: true)
        }

    }
    
    @IBAction func proggressTouchDown(_ sender: UISlider) {
        isChangingProgress = true
    }
    
    func applyBlur(on imageToBlur: UIImage, withRadius blurRadius: CGFloat) -> UIImage {
        let originalImage = CIImage(cgImage: imageToBlur.cgImage!)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(originalImage, forKey: "inputImage")
        filter?.setValue(blurRadius, forKey: "inputRadius")
        let outputImage = filter?.outputImage
        let context = CIContext(options: nil)
        let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let ret = UIImage(cgImage: outImage!)
        return ret
    }
    
    
    func updateUI() {
        let auth = SPTAuth.defaultInstance()
        if SPTAudioStreamingController.sharedInstance().metadata == nil || SPTAudioStreamingController.sharedInstance().metadata.currentTrack == nil {
            self.coverView.image = nil
            self.coverView2.image = nil
            return
        }
        self.spinner.startAnimating()
        self.nextButton.isEnabled = SPTAudioStreamingController.sharedInstance().metadata.nextTrack != nil
        self.prevButton.isEnabled = SPTAudioStreamingController.sharedInstance().metadata.prevTrack != nil
        self.trackTitle.text = SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.name
        self.artistTitle.text = SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.artistName
        self.playbackSourceTitle.text = SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.playbackSourceName


        SPTTrack.track(withURI: URL(string: SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.uri)!, accessToken: auth!.session.accessToken, market: nil) { error, result in
            
            if let track = result as? SPTTrack {
                let imageURL = track.album.largestCover.imageURL
                if imageURL == nil {
                    print("Album \(track.album) doesn't have any images!")
                    self.coverView.image = nil
                    self.coverView2.image = nil
                    return
                }
                // Pop over to a background queue to load the image over the network.
                
                DispatchQueue.global().async {
                    do {
                        let imageData = try Data(contentsOf: imageURL!, options: [])
                        let image = UIImage(data: imageData)
                        // …and back to the main queue to display the image.
                        DispatchQueue.main.async {
                            self.spinner.stopAnimating()
                            self.coverView.image = image
                            if image == nil {
                                print("Couldn't load cover image with error: \(error)")
                                return
                            }
                        }
                        // Also generate a blurry version for the background
                        let blurred = self.applyBlur(on: image!, withRadius: 10.0)
                        DispatchQueue.main.async {
                            self.coverView2.image = blurred
                        }

                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if songList.count != 0{
            myCounter = myCounter + 1
        }
        super.viewDidAppear(animated)
        if (myCounter == 1){
            self.handleNewSession()
            myCounter = myCounter + 1
        }else{
            self.activateAudioSession()
     //       print("123: \(SPTAudioStreamingController.sharedInstance().playbackState.accessibilityActivate())")
            SPTAudioStreamingController.sharedInstance().delegate = self
            SPTAudioStreamingController.sharedInstance().playbackDelegate = self
            if restart == true{
                self.updateUI()
                SPTAudioStreamingController.sharedInstance().playSpotifyURI("\(songList[0].trackU!)", startingWith: 0, startingWithPosition: 0) { error in
                    if error != nil {
                        print("*** failed to play: \(error)")
                        return
                    }
                }
                npSong = songList[0].name
                npArtist = songList[0].artistName
                npImage = songList[0].mainImage
                songList.remove(at: 0)
                restart = false
            }
        }

    }
    
    
    func handleNewSession() {
        do {
            try SPTAudioStreamingController.sharedInstance().start(withClientId: SPTAuth.defaultInstance().clientID, audioController: nil, allowCaching: true)
            SPTAudioStreamingController.sharedInstance().delegate = self
            SPTAudioStreamingController.sharedInstance().playbackDelegate = self
            SPTAudioStreamingController.sharedInstance().diskCache = SPTDiskCache() /* capacity: 1024 * 1024 * 64 */
            SPTAudioStreamingController.sharedInstance().login(withAccessToken: SPTAuth.defaultInstance().session.accessToken!)
        } catch let error {
            let alert = UIAlertController(title: "Error init", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: { _ in })
            self.closeSession()
        }
    }
    
    func closeSession() {
        do {
            try SPTAudioStreamingController.sharedInstance().stop()
            SPTAuth.defaultInstance().session = nil
            _ = self.navigationController!.popViewController(animated: true)
        } catch let error {
            let alert = UIAlertController(title: "Error deinit", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: { _ in })
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        let alert = UIAlertController(title: "Message from Spotify", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: { _ in })
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        print("is playing = \(isPlaying)")
        if isPlaying {
            self.activateAudioSession()
        }
        else {
            self.deactivateAudioSession()
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        self.updateUI()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceive event: SpPlaybackEvent, withName name: String) {
        print("didReceivePlaybackEvent: \(event) \(name)")
        print("isPlaying=\(SPTAudioStreamingController.sharedInstance().playbackState.isPlaying) isRepeating=\(SPTAudioStreamingController.sharedInstance().playbackState.isRepeating) isShuffling=\(SPTAudioStreamingController.sharedInstance().playbackState.isShuffling) isActiveDevice=\(SPTAudioStreamingController.sharedInstance().playbackState.isActiveDevice) positionMs=\(SPTAudioStreamingController.sharedInstance().playbackState.position)")
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        self.closeSession()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        print("didReceiveError: \(error!.localizedDescription)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        if isChangingProgress {
            return
        }
        let positionDouble = Double(position)
        let durationDouble = Double(SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.duration)
        self.progressSlider.value = Float(positionDouble / durationDouble)
        if songList.count == 0{
            let position1 = Double(positionDouble / durationDouble)
            if position1 > 0.99 {
                SPTAudioStreamingController.sharedInstance().setIsPlaying(false, callback: nil)
                restart = true
                numAppeared = 0
            }
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStartPlayingTrack trackUri: String) {
        print("Starting \(trackUri)")
        print("Source \(SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.playbackSourceUri)")
        // If context is a single track and the uri of the actual track being played is different
        // than we can assume that relink has happended.
        let isRelinked = SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.playbackSourceUri.contains("spotify:track") && !(SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.playbackSourceUri == trackUri)
        print("Relinked \(isRelinked)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStopPlayingTrack trackUri: String) {
        print("Finishing: \(trackUri)")
        self.updateUI()
        SPTAudioStreamingController.sharedInstance().playSpotifyURI("\(songList[0].trackU!)", startingWith: 0, startingWithPosition: 0) { error in
            if error != nil {
                print("*** failed to play: \(error)")
                return
            }
        }
        npSong = songList[0].name
        npArtist = songList[0].artistName
        npImage = songList[0].mainImage
        songList.remove(at: 0)
        
    }
    
    
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController) {
        //print("Postss: \(posts[0].name!)")
        //self.updateUI()
        if songList.count != 0{
            SPTAudioStreamingController.sharedInstance().playSpotifyURI("\(songList[0].trackU!)", startingWith: 0, startingWithPosition: 0) { error in
                if error != nil {
                    print("*** failed to play: \(error)")
                    return
                }
            }
    //        SPTAudioStreamingController.sharedInstance().queueSpotifyURI("spotify:track:5eCkuGPZNl4mISFNPgr3Dd", callback: nil)
            npSong = songList[0].name
            npArtist = songList[0].artistName
            npImage = songList[0].mainImage
            songList.remove(at: 0)
        }else{
            
        }

    }
    
    //spotify:user:spotify:playlist:2yLXxKhhziG2xzy7eyD4TD
    
    func activateAudioSession() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        }
        catch let error {
            print("activateAudioSessionError: \(error.localizedDescription)")
        }
    }
    
    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}

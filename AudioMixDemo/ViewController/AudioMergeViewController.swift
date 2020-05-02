//
//  AudioMergeViewController.swift
//  AudioMixDemo
//
//  Created by PIYUSH  GHOGHARI on 22/04/20.
//  Copyright © 2020 PIYUSH  GHOGHARI. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
class AudioMergeViewController: UIViewController {
    
    // MARK: - All IBOutlet's for this UIViewController
    
    @IBOutlet weak var player1View: UIView!
    @IBOutlet weak var player2View: UIView!
    @IBOutlet weak var finalPlayerView: UIView!
    @IBOutlet weak var filePathValue: UILabel!
    
    // Variables
    var audioRecord1URL: URL!
    var audioRecord2URL: URL!
    var tempURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let asset1 : AVURLAsset = AVURLAsset.init(url: audioRecord1URL, options: nil)
        let playerView1 = SYWaveformPlayerView(frame: CGRect(x: 0, y: 5, width: Constants.SCREEN_SIZES.WIDTH - 50, height: 60), asset: asset1, color: UIColor.gray, progressColor: UIColor(red: 132.0/255.0, green: 112.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        self.player1View.addSubview(playerView1!)
        
        let asset2 : AVURLAsset = AVURLAsset.init(url: audioRecord2URL, options: nil)
        let playerView2 = SYWaveformPlayerView(frame: CGRect(x: 0, y: 5, width: Constants.SCREEN_SIZES.WIDTH - 50, height: 60), asset: asset2, color: UIColor.gray, progressColor: UIColor(red: 132.0/255.0, green: 112.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        self.player2View.addSubview(playerView2!)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func overLAyAudioButttonClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.mixAudio()
    }
    
    
    func mixAudio() {
        let composition = AVMutableComposition()
        let tracks:[URL] = [audioRecord1URL, audioRecord2URL]
        
        for trackName in tracks {
            let audioAsset = AVURLAsset(url: trackName, options: nil)
            let audioTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset.duration), of: audioAsset.tracks(withMediaType: AVMediaType.audio)[0], at: CMTime.zero)
        }
        
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        
        let date :NSDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'_'HH_mm_ss"
        
        let filename = "AudioMix\(dateFormatter.string(from: date as Date)).m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        
        assetExport?.outputFileType = AVFileType.m4a
        assetExport?.outputURL = filePath
        assetExport?.shouldOptimizeForNetworkUse = true
        
        assetExport?.exportAsynchronously(completionHandler: {() -> Void in
            print("Completed Sucessfully")
            print("filePath: ->\(filePath)")
            
            
        })
        
        self.filePathValue.text = "FileManager/ApplicationName/audio/Mix/\(filename)"
        
        let alert = UIAlertController(title: "AudioMixDemo", message: "Completed Sucessfully", preferredStyle: UIAlertController.Style.alert)
        
        
        
        alert.addAction(image: nil, title: "OK", color: .black, style: .default) { action in
            // completion handler
            let asset2 : AVURLAsset = AVURLAsset.init(url: self.getDocumentsDirectory().appendingPathComponent(filename), options: nil)
            let playerView2 = SYWaveformPlayerView(frame: CGRect(x: 0, y: 5, width: Constants.SCREEN_SIZES.WIDTH - 50, height: 60), asset: asset2, color: UIColor.gray, progressColor: UIColor(red: 132.0/255.0, green: 112.0/255.0, blue: 255.0/255.0, alpha: 1.0))
            self.finalPlayerView.addSubview(playerView2!)
        }
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func getDocumentsDirectory() -> URL{
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let paths = documentsDirectory[0].appendingPathComponent("audio/Mix")
        do{
            try FileManager.default.createDirectory(atPath: paths.path, withIntermediateDirectories: true, attributes: nil)
        }catch let error as NSError{
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        return paths
    }
}

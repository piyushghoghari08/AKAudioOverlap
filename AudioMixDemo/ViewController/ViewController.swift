//
//  ViewController.swift
//  AudioMixDemo
//
//  Created by PIYUSH  GHOGHARI on 22/04/20.
//  Copyright © 2020 PIYUSH  GHOGHARI. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: - All IBoutlet's for this UIViewController
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var vwAudioPlayerMain: UIView!
    @IBOutlet weak var recordButtonLabel: UILabel!
    
    var rippleLayer = RippleLayer()
    
    //Internal audio recording variables
    var isRecordingStart        = false
    var isRecording             = false
    var isAudioRecording        = false
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var audioData           = Data()
    var recordAudioURL : URL!
    var objSYWaveformPlayer: SYWaveformPlayerView!
    var tempAudioURl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func audioRecordingButtonClick(_ sender: UIControl) {
        self.view.endEditing(true)
        if isAudioRecording == false {
            recordButtonLabel.text = "Stop Recording"
            isAudioRecording = true
            self.startProgress()
            self.setUpRecording()
        } else {
            isAudioRecording = false
            self.finishAudioRecording(success: true)
            self.rippleLayer.stopAnimation()
            
        }
    }
    
    @IBAction func nextButtonClick(_ sender: UIControl) {
        self.view.endEditing(true)
        if isAudioRecording == true {
            isAudioRecording = false
            self.finishAudioRecording(success: true)
            self.rippleLayer.stopAnimation()
        }
        
        let objAudio2VC = self.storyboard?.instantiateViewController(withIdentifier: "AudioRecord2ViewController")as! AudioRecord2ViewController
        objAudio2VC.audioRecord1URL = tempAudioURl
              self.navigationController?.pushViewController(objAudio2VC, animated: true)
    }
    
    func startProgress() {
        self.rippleLayer.position = CGPoint(x: self.progressView.layer.bounds.midX, y: self.progressView.layer.bounds.midY);
        self.rippleLayer.startAnimation()
        self.progressView.layer.addSublayer(self.rippleLayer)
        
    }
}


extension ViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    //----------------------------
    // Recording Code - Start
    //----------------------------
    
    //MARK: - Internal Audio Recording Code
    func setUpRecording(){
        self.isRecordingStart = true
        self.setup_recorder()
        self.audioRecorder.record()
        
        self.isRecording = true
    }
    
    //record File Path
    func getDocumentsDirectory() -> URL{
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let paths = documentsDirectory[0].appendingPathComponent("audio")
        do{
            try FileManager.default.createDirectory(atPath: paths.path, withIntermediateDirectories: true, attributes: nil)
        }catch let error as NSError{
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        return paths
    }
    
    func getFileUrl() -> URL{
        if recordAudioURL == nil {
            let date :NSDate = NSDate()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'_'HH_mm_ss"
            
            let filename = "\(dateFormatter.string(from: date as Date)).m4a"
            let filePath = getDocumentsDirectory().appendingPathComponent(filename)
            recordAudioURL = filePath
            
            
        }
        return recordAudioURL
    }
    
    func setup_recorder(){
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
        }
        catch let error {
            display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
        }
    }
    
    //Record Timer Function.
    @objc func updateAudioMeter(timer: Timer){
        if(self.isRecordingStart == true){
            if audioRecorder.isRecording{
                let hr = Int((audioRecorder.currentTime / 60) / 60)
                let min = Int(audioRecorder.currentTime / 60)
                let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
                let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
                print("Recording Time : ->",totalTimeString)
                audioRecorder.updateMeters()
            }
        }
    }
    
    func finishAudioRecording(success: Bool){
        if success{
            audioRecorder.stop()
            audioRecorder = nil
            let saveAudioURL = getFileUrl()
            audioData =  try! Data(contentsOf: saveAudioURL)
            print("data \(audioData)")
            
             print("audioURL1: -> \(recordAudioURL)")
            
            let asset : AVURLAsset = AVURLAsset.init(url: recordAudioURL, options: nil)
            let playerView = SYWaveformPlayerView(frame: CGRect(x: 0, y: 5, width: Constants.SCREEN_SIZES.WIDTH - 50, height: 60), asset: asset, color: UIColor.gray, progressColor: UIColor(red: 132.0/255.0, green: 112.0/255.0, blue: 255.0/255.0, alpha: 1.0))
            self.vwAudioPlayerMain.addSubview(playerView!)
            tempAudioURl = recordAudioURL
            recordAudioURL = nil
        }else{
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool){
        if !flag{
            finishAudioRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){}
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String){
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        //        ac.addAction(UIAlertAction(title: action_title, style: .default){
        //            (result : UIAlertAction) -> Void in
        //        })
        ac.addAction(UIAlertAction(title: action_title, style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    //----------------------------
    // Recording Code - End
    //----------------------------
}

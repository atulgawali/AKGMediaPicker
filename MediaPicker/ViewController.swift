//
//  ViewController.swift
//  MediaPicker
//
//  Created by Atul Gawali on 12/02/17.
//  Copyright © 2017 Atul Gawali. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation

class ViewController: UIViewController ,UINavigationControllerDelegate, UIImagePickerControllerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate{
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    //MARK:- IBACtion Methode
    
    @IBAction func captureImage(_ sender: Any) {
        self.openImageCapturePicker()
    }
    
    @IBAction func recordVideo(_ sender: Any) {
        self.openVideoPicker()
    }
    
    @IBAction func viewCaptureImage(_ sender: Any) {
        //TODO View Capture Image
    }
    
    @IBAction func playVideo(_ sender: Any) {
        self.playVideo(mediaName: "atul.mp4")
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        self.recordAudioFunction()
    }
    @IBAction func playAudio(_ sender: Any) {
        self.playAudioRecorded()
    }
    
    @IBAction func viewPhotoGallery(_ sender: Any) {
        self.openIphonePhotoGallery()
    }
    
    
    func openVideoPicker() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.camera;
            imag.mediaTypes = [kUTTypeMovie as String]
            imag.cameraCaptureMode = .video
            imag.allowsEditing = false
            
            self.present(imag, animated: true, completion: nil)
        }
    }
    func openImageCapturePicker() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.camera;
            imag.allowsEditing = false
            imag.cameraCaptureMode = .photo
            self.present(imag, animated: true, completion: nil)
        }
    }
    func openIphonePhotoGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if picker.sourceType == .camera {
            if picker.cameraCaptureMode == .video {
                let videoURL = info["UIImagePickerControllerMediaURL"] as? NSURL
                do {
                    let video = try NSData(contentsOf: videoURL as! URL, options: .mappedIfSafe)
                    let fileName =  DocDirectoryMaanger.sharedManager().saveSituationCapture(video as Data!, withSituationCaptureType:SituationCaptureType.MediaCaptureTypeVideo.rawValue)
                    print(fileName!)
                    
                } catch {
                    print(error)
                    return
                }
            }
            else {
                let image = info[UIImagePickerControllerOriginalImage]
                let imageData = UIImagePNGRepresentation(image as! UIImage)
                let fileName = DocDirectoryMaanger.sharedManager().saveSituationCapture(imageData as Data!, withSituationCaptureType:SituationCaptureType.MediaCaptureTypeImage.rawValue)
                print(fileName!)
            }
        }
        else {
            let image = info[UIImagePickerControllerOriginalImage]
            let imageData = UIImagePNGRepresentation(image as! UIImage)
            _ = DocDirectoryMaanger.sharedManager().saveSituationCapture(imageData as Data!, withSituationCaptureType:SituationCaptureType.MediaCaptureTypeImage.rawValue)
            
        }
        self.dismiss(animated: true, completion: {})
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        self.dismiss(animated: true, completion: {})
    }
    
    
    func playVideo(mediaName : String){
        let videoPath =  DocDirectoryMaanger.sharedManager().getPathForMediaFile(mediaName)
        let player = AVPlayer(url: URL(fileURLWithPath: videoPath!))
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true) {
            player.play()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Audio Recording
    func recordAudioFunction()  {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func playAudioRecorded() {
        let documentDirectoryName = DocDirectoryMaanger.sharedManager().documentsPathWithFolderName().appending("atul.m4a")
        let url = URL(fileURLWithPath: documentDirectoryName)
        var player: AVAudioPlayer!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
        
        /*
         //Stop Sound
         if bombSoundEffect != nil {
         bombSoundEffect.stop()
         bombSoundEffect = nil
         }*/
        
    }
    
    func loadRecordingUI() {
        recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 250, height: 64))
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    func startRecording() {
        let documentDirectoryName = DocDirectoryMaanger.sharedManager().documentsPathWithFolderName().appending("atul.m4a")
        let audioFilename = NSURL(string: documentDirectoryName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename as! URL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}


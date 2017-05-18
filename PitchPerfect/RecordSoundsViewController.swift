//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Prabhav Chawla on 5/17/17.
//  Copyright © 2017 Prabhav Chawla. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    
    func isRecording(_ flag: Bool) {
        if flag {
            recordingLabel.text = "Recording in Progress..."
            stopRecordingButton.isEnabled = true
            recordAudioButton.isEnabled = false
        } else {
            recordingLabel.text = "Tap to Record"
            recordAudioButton.isEnabled = true
            stopRecordingButton.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isRecording(false)
        super.viewWillAppear(animated)
    }

    @IBAction func recordAudio(_ sender: Any) {
        isRecording(true)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String // get a directory path, in particular the .documentDirectory, store it as a String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/")) // pathArray.joined.. works for [String], IN THIS CASE- "\(dirPath)/\(recordingName)"
        
        let session = AVAudioSession.sharedInstance() //AVAudioSession is needed to play/record audio. We use .sharedInstance() to get the object that is already created when app starts since this doesn't require much set-up. Since a device only has one set of audio equipment hardware , there is only one instance of AVAudioSesion that is shared across all apps.
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker) // set up the session to play and record Audio. The ! after try means that the error/exception isn't handled if thrown.
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self // set this view controller as the delegate of audioRecorder
        // this tells AVAudioRecorder that we have implemented the audioRecorderDidFinishRecording func in this class and to use it
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(_ sender: Any) {
        isRecording(false)
        
        audioRecorder.stop()
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url) // The segue is called when recording finishes, that is, when the audio file is saved. We also send to it the path of where the audio file is located. Path is in the form of a URL. The flag variable determines if saving the file was successful or not. sender is just an argument that gets passed along with this function, typically it is the object that triggered this segue. This is received later in the function prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!), where you can get this object and make decision based on who the sender is.
        } else {
            let alert = UIAlertController(title: "Error", message: "There was a problem saving the audio file. Please record your voice again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
       }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundVC = segue.destination as! PlaySoundsViewController // we grab the view controller destination. as! is used to cast the object.
            let url = sender as! URL
            playSoundVC.recordedAudioURL = url // remeber that PlaySoundViewController has the property recordedAudioURL
        }
        
    }
}


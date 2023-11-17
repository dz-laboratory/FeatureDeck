//
//  ViewController.swift
//  BcakgroundAudio
//
//  Created by anz-ryu on 2023/11/17.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVSpeechSynthesizerDelegate {
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance.init(string: "あいうえお あいうえお あいうえお あいうえお あいうえお あいうえお あいうえお あいうえお")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction
    func play(sender: UIButton) {
        // for background
        do {
           try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: AVAudioSession.CategoryOptions.mixWithOthers)
           try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        
        let voice = AVSpeechSynthesisVoice.init(language: "ja-JP")
        utterance.voice = voice
        synthesizer.delegate = self
        synthesizer.speak(utterance)
        NSLog("liu: success")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didFinish utterance: AVSpeechUtterance) {
        NSLog("liu: complete")
        synthesizer.speak(utterance)
    }
}


//
//  AVSpeechSynthesizer+Shared.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation

extension AVSpeechSynthesizer {
    private struct Storage {
        static let shared = AVSpeechSynthesizer()
    }
    static var shared: AVSpeechSynthesizer {
        return Storage.shared
    }
    
    func speak(_ string: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        if isSpeaking {
            stopSpeaking(at: .immediate)
        }
        speak(utterance)
    }
}

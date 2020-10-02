//
//  OfflineSpeechRecognizer.swift
//  MovixVision
//
//  Created by rosteg on 02.10.2020.
//

import Foundation
import UIKit
import Speech
import AVFoundation

public protocol OfflineSpeechRecognizerDelegate: class {
    func error(_ offlineSpeechRecognizer: OfflineSpeechRecognizer)
    func result(_ offlineSpeechRecognizer: OfflineSpeechRecognizer, message : String)
    func log(_ offlineSpeechRecognizer: OfflineSpeechRecognizer, message: String)
    func didStopListening(_ offlineSpeechRecognizer: OfflineSpeechRecognizer)
    func didStartListening(_ offlineSpeechRecognizer: OfflineSpeechRecognizer)
}

public class OfflineSpeechRecognizer {
    public static var shared: OfflineSpeechRecognizer = OfflineSpeechRecognizer()
    weak var delegate: OfflineSpeechRecognizerDelegate?
    public var isRecording: Bool { audioEngine.isRunning }

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    public func prepareListening(forLanguage language: String, andCountry country: String,  completion: @escaping ((PrepareResult) -> Void)) {

        isMicrophoneAvailable(completion: { granted in
            if granted {
                SFSpeechRecognizer.requestAuthorization { (status) in
                    switch status {
                    case .authorized:
                        self.setupRecognition(forLanguage: language, andCountry: country, completion: completion)
                    case .denied:
                        completion(.error(ErrorType.speechRecognizerNotAvailable))
                    case .notDetermined, .restricted:
                        completion(.error(ErrorType.technicalError))
                    @unknown default:
                        completion(.error(ErrorType.technicalError))
                    }
                }
            } else {
                completion(.error(ErrorType.microphoneNotAvailable))
            }
        })
    }

    private func setupRecognition(forLanguage language: String, andCountry country: String, completion: @escaping (PrepareResult)-> Void) {

        let locale = Locale(identifier: language + "-" + country.uppercased())

        guard let speechRecognizer = SFSpeechRecognizer(locale: locale) else {
            log(messsage: "Couldn't create SFSpeechRecognizer")
            completion(.error(ErrorType.technicalError))
            return
        }

        if speechRecognizer.supportsOnDeviceRecognition {}
        if #available(iOS 13, *) {
            if speechRecognizer.supportsOnDeviceRecognition {
                self.speechRecognizer = speechRecognizer
                completion(.success)
            } else {
                completion(.error(ErrorType.onDeviceIsNotAvailable))
            }
        } else {
            completion(.error(ErrorType.onDeviceIsNotAvailable))
        }
    }

    private func isMicrophoneAvailable( completion: @escaping ((Bool) -> Void) ){
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            completion(true)
        case AVAudioSessionRecordPermission.denied:
            completion(false)
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission( { granted in
                completion(granted)
            })
        @unknown default:
            completion(false)
        }
    }

   public func startListening() {
        startRecording()
    }

    public func stopListening() {
        resetListening()
    }

    private func startRecording() {

        guard speechRecognizer != nil else {
            log(messsage: "SpeechRecongnizer is not been initalized: Please call prepareFor(locale) before call startRecording()")
            return
        }

        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            delegate?.error(self)
            log(messsage: "recognitionRequest is not initialized.")
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
        } else {
            delegate?.error(self)
            log(messsage: "On device is not supported on iOS less then iOS 13.")
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest ) { result, error in
            var isFinal = false

            if let result = result {
                isFinal = result.isFinal
                self.delegate?.result(self, message: result.bestTranscription.formattedString)
            }

            if error != nil || isFinal {
                self.resetListening()
                self.delegate?.didStopListening(self)
            }
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.multiRoute, mode: .default, options: .mixWithOthers)
            try audioSession.setActive(true, options:  .notifyOthersOnDeactivation)
        } catch {
            log(messsage: "Unexpected error: \(error)")
            delegate?.error(self)
        }

        let format = audioEngine.inputNode.outputFormat(forBus: 0)

        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            delegate?.didStartListening(self)
        } catch {
            delegate?.error(self)
        }
    }

    private func log(messsage: String){
        delegate?.log(self, message: messsage)
    }

    private func resetListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
    }

}

public enum ErrorType: String {
    case microphoneNotAvailable = "MicrophoneNotAvailable"
    case onDeviceIsNotAvailable = "OnDeviceIsNotAvailable"
    case technicalError = "TechnicalError"
    case speechRecognizerNotAvailable = "SpeechRecognizerNotAvailable"
}

public enum PrepareResult {
    case success
    case error(ErrorType)
}

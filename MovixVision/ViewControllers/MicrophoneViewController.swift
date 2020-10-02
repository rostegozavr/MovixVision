//
//  MicrophoneViewController.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import UIKit

class MicrophoneViewController: UIViewController {
    enum Mode {
        case samples
        case microphone
    }
    
    enum State {
        case ready
        case findingMovies
    }
    
    private var isRecording: Bool = false
    private let offlineSpeechRecognizer = OfflineSpeechRecognizer.shared
    
    @IBOutlet var microphoneView: UIView!
    //@IBOutlet var cantAccessMicrophoneView: UIStackView!
    @IBOutlet var samplesView: UIView!
    @IBOutlet var dimmingView: UIView!
    @IBOutlet var tooltip: TooltipView!
    
    @IBOutlet var samplesViewButton: UIButton!
    @IBOutlet var microphoneViewButton: UIButton!
    @IBOutlet var findMoviesButton: UIButton!
    
    var microphone: Microphone?
    var samples: Samples?
    let movieService = MovieService()
    
    var mode: Mode = .samples {
        didSet {
            toggleModes(isMicrophone: mode == .microphone)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var state = State.ready
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        offlineSpeechRecognizer.prepareListening(forLanguage: "ru", andCountry: "RU", completion: { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    print("PrepareListening: Success.")
                    self.offlineSpeechRecognizer.startListening()
                case .error(let error):
                    print("Error: " + String(describing: error))
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Will stop listening")
        self.offlineSpeechRecognizer.stopListening()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSamples()
        setupMicrophone()
        setupDimmingView()
        offlineSpeechRecognizer.delegate = self
        toggleMicrophoneView(nil)
    }
    
    func setupSamples() {
        samples = Samples(samplesView: samplesView)
    }
    
    func setupMicrophone() {
        microphone = Microphone(microphoneView: microphoneView)
    }
    
    func setupDimmingView() {
        view.bringSubviewToFront(dimmingView)
        dimmingView.alpha = 0
    }
    
    @IBAction func findSimilarMovies(_ sender: Any) {
        guard state == .ready else {
            return
        }
        state = .findingMovies
        
        if !tooltip.isHidden {
            tooltip.isHidden = true
        }
        let findMovies: (String?, Error?) -> () = { text, error in
            guard error == nil else {
                return self.presentError(error)
            }
            self.showMovies(by: text!)
        }
        
        switch mode {
        case .microphone:
            print(microphone?.currentText() ?? "??")
            findMovies(microphone?.currentText(), nil)
        case .samples:
            print(samples?.currentSample() ?? "??")
            findMovies(samples?.currentSample(), nil)
        }
    }
    
    func showMovies(by text: String) {
        state = .ready
    }
    
    func presentError(_ error: Error?) {
        let message = NSLocalizedString("An error occurred, please try again.", comment: "Body of alert view")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func toggleSamplesView(_ sender: Any) {
        guard mode == .microphone else {
            return
        }
        mode = .samples
    }
    
    @IBAction func toggleMicrophoneView(_ sender: Any?) {
        guard mode == .samples else {
            return
        }
        mode = .microphone
    }
    
    func toggleModes(isMicrophone: Bool) {
        samplesViewButton.isSelected = !isMicrophone
        microphoneViewButton.isSelected = isMicrophone
        
//        if isMicrophone {
//            offlineSpeechRecognizer.startListening()
//        } else {
//            offlineSpeechRecognizer.stopListening()
//        }

        UIView.animate(withDuration: 0.3) {
            self.samplesView.alpha = isMicrophone ? 0 : 1
            self.microphoneView.alpha = isMicrophone ? 1 : 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DismissingModalViewController {
            dimForModal()
            destination.onDismiss = self.undimOnModalDismissal
        }
    }
    
    func dimForModal() {
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.alpha = 0.8
        }
    }
    
    func undimOnModalDismissal() {
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.alpha = 0.0
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return mode == .microphone ? .lightContent : .default
    }
}

extension MicrophoneViewController: OfflineSpeechRecognizerDelegate {

    public func error(_ offlineSpeechRecognizer: OfflineSpeechRecognizer) {
        print("Something went wrong! Offline Speech Reconition is not possible.")
    }

    public func result(_ offlineSpeechRecognizer: OfflineSpeechRecognizer, message: String) {
        microphone?.label.text = message
        print(message)
    }

    public func log(_ offlineSpeechRecognizer: OfflineSpeechRecognizer, message: String) {
        print(message)
    }

    public func didStopListening(_ offlineSpeechRecognizer: OfflineSpeechRecognizer) {
        print("Did Stop Listening")
        isRecording = false
    }

    public func didStartListening(_ offlineSpeechRecognizer: OfflineSpeechRecognizer) {
        print("Did Start Listening")
        isRecording = true
    }
}

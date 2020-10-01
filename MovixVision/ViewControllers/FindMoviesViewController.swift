//
//  FindMoviesViewController.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import UIKit

class FindMoviesViewController: UIViewController {
    enum Mode {
        case gallery
        case camera
    }
    
    enum State {
        case ready
        case findingMovies
    }
    
    @IBOutlet var cameraView: CameraPreviewView!
    @IBOutlet var cantAccessCameraView: UIStackView!
    @IBOutlet var galleryView: UIView!
    @IBOutlet var dimmingView: UIView!
    @IBOutlet var tooltip: TooltipView!
    
    @IBOutlet var galleryViewButton: UIButton!
    @IBOutlet var cameraViewButton: UIButton!
    @IBOutlet var findMoviesButton: UIButton!
    
    var camera: Camera?
    var gallery: Gallery?
    let movieService = MovieService()
    
    var mode: Mode = .gallery {
        didSet {
            toggleModes(isCamera: mode == .camera)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var state = State.ready
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGallery()
        setupCamera()
        setupDimmingView()
        toggleCameraView(nil)
    }
    
    func setupGallery() {
        gallery = Gallery(galleryView: galleryView)
    }
    
    @IBAction func setupCamera(_ sender: Any? = nil) {
        cantAccessCameraView.isHidden = true
        Camera.build(previewView: cameraView) { camera in
            guard let camera = camera else {
                self.cantAccessCameraView.isHidden = false
                return
            }
            self.camera = camera
        }
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
        let findMovies: (UIImage?, Error?) -> () = { image, error in
            guard error == nil else {
                return self.presentError(error)
            }
            self.showMovies(similarTo: image!)
        }
        
        switch mode {
        case .camera:
            camera?.takePicture(completion: findMovies)
        case .gallery:
            findMovies(gallery?.currentImage(), nil)
        }
    }
    
    func showMovies(similarTo image: UIImage) {
        movieService.findMovies(similarTo: image) { indices, error in
            DispatchQueue.main.async {
                print("show results")
            }
        }
    }
    
    func presentError(_ error: Error?) {
        let message = NSLocalizedString("An error occurred, please try again.", comment: "Body of alert view")
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func toggleGalleryView(_ sender: Any) {
        guard mode == .camera else {
            return
        }
        mode = .gallery
    }
    
    @IBAction func toggleCameraView(_ sender: Any?) {
        guard mode == .gallery else {
            return
        }
        mode = .camera
    }
    
    func toggleModes(isCamera: Bool) {
        galleryViewButton.isSelected = !isCamera
        cameraViewButton.isSelected = isCamera
        
        UIView.animate(withDuration: 0.3) {
            self.galleryView.alpha = isCamera ? 0 : 1
            self.cameraView.alpha = isCamera ? 1 : 0
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
        return mode == .camera ? .lightContent : .default
    }
}

class DismissingModalViewController: UIViewController {
    var onDismiss: (() -> ())?
    
    @IBAction func dismiss(_ sender: Any) {
        super.dismiss(animated: true, completion: nil)
        onDismiss?()
    }
}

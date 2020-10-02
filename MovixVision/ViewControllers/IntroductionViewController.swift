//
//  IntroductionViewController.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import UIKit

class IntroductionViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var icon: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var microphoneButton: UIButton!
    
    @IBOutlet var iconVerticallyCenteredConstraint: NSLayoutConstraint!
    @IBOutlet var iconTopConstraint: NSLayoutConstraint!
    @IBOutlet var iconToTitleConstraint: NSLayoutConstraint!
    @IBOutlet var titleToDescriptionConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playIntroduction()
    }
    
    // MARK: Setup
    func setupButton() {
    }
    
    // MARK: Introduction Animations
    var hasPlayedIntroduction = false
    
    func playIntroduction() {
        guard hasPlayedIntroduction == false else {
            return
        }
        hasPlayedIntroduction = true
        
        let animationElements = [
            AnimationElement(view: titleLabel, constraint: iconToTitleConstraint, delay: 0, float: 8),
            AnimationElement(view: descriptionLabel, constraint: titleToDescriptionConstraint, delay: 0.5, float: 16)
        ]
        let introAnimation = IntroductionAnimator(parent: view, elements: animationElements)
        
        centerIcon()
        introAnimation.setup();
        UIView.animate(withDuration: 1, animations: moveIconToTop)
        introAnimation.animate();
    }
    
    func centerIcon() { swapIcon(center: true) }
    func moveIconToTop() { swapIcon(center: false) }
    func swapIcon(center: Bool) {
        iconTopConstraint.isActive = !center
        iconVerticallyCenteredConstraint.isActive = center
        view.layoutIfNeeded()
    }
}

private class AnimationElement {
    let view: UIView
    let constraint: NSLayoutConstraint
    let constant: CGFloat
    let delay: TimeInterval
    let float: CGFloat
    
    init(view: UIView, constraint: NSLayoutConstraint, delay: TimeInterval, float: CGFloat) {
        self.view = view
        self.constraint = constraint
        self.constant = constraint.constant
        self.delay = delay
        self.float = float
    }
    
    func hide() {
        view.alpha = 0
        constraint.constant = constant + float
    }
    
    func show() {
        view.alpha = 1
        constraint.constant = constant
        view.superview?.layoutIfNeeded()
    }
}

private class IntroductionAnimator {
    let parent: UIView
    let elements: [AnimationElement]
    
    init(parent: UIView, elements: [AnimationElement]) {
        self.parent = parent
        self.elements = elements
    }
    
    func setup() {
        elements.forEach { $0.hide() }
        parent.layoutIfNeeded()
    }
    
    func animate() {
        elements.forEach { element in
            UIView.animate(
                withDuration: 1,
                delay: element.delay,
                options: .curveEaseInOut,
                animations: element.show,
                completion: nil
            )
        }
    }
}

class DismissingModalViewController: UIViewController {
    var onDismiss: (() -> ())?
    
    @IBAction func dismiss(_ sender: Any) {
        super.dismiss(animated: true, completion: nil)
        onDismiss?()
    }
}

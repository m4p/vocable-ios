//
//  HotCornersTrackableViewController.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/22/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class HotCornersTrackableViewController: UIViewController {
    struct Constants {
        static let hotCornerSize = CGSize(width: 48, height: 48)
        static let trackingViewSize = CGSize(width: 60, height: 60)
        static let initialHotCornerBounds = CGRect(origin: CGPoint(x: -24, y: -24), size: Constants.hotCornerSize)
    }
    
    var isUnlocked = true {
        didSet {
            self.currentTrackingEngine?.isUnlocked = self.isUnlocked
        }
    }
    
    let parentTrackingEngine = TrackingEngine()
    var currentTrackingEngine: TrackingEngine? {
        didSet {
            self.currentTrackingEngine?.parent = self.parentTrackingEngine
            self.currentTrackingEngine?.isUnlocked = self.isUnlocked
        }
    }
    
    var showDebug: Bool = true {
        didSet {
            self.configureUI()
        }
    }
    
    var trackingConfiguration: TrackingConfiguration = .headTracking {
        didSet {
            self.configureUI()
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.showDebug = !self.showDebug
        }
    }
    
    func configureUI() {
        guard self.isViewLoaded else { return }
        
        self.screenTrackingViewController.showDebug = self.showDebug
        self.screenTrackingViewController.trackingConfiguration = self.trackingConfiguration
    }
    
    lazy var upperLeftHotCorner: HotCornerView = {
        let view = HotCornerView(location: .upperLeft)
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: Constants.hotCornerSize)
        view.bounds = Constants.initialHotCornerBounds
        view.alpha = 0.0
        return view
    }()
    
    lazy var upperRightHotCorner: HotCornerView = {
        let view = HotCornerView(location: .upperRight)
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: Constants.hotCornerSize)
        view.bounds = Constants.initialHotCornerBounds
        view.alpha = 0.0
        return view
    }()
    
    lazy var lowerLeftHotCorner: HotCornerView = {
        let view = HotCornerView(location: .lowerLeft)
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: Constants.hotCornerSize)
        view.bounds = Constants.initialHotCornerBounds
        view.alpha = 0.0
        return view
    }()
    
    lazy var lowerRightHotCorner: HotCornerView = {
        let view = HotCornerView(location: .lowerRight)
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: Constants.hotCornerSize)
        view.bounds = Constants.initialHotCornerBounds
        view.alpha = 0.0
        return view
    }()
    
    lazy var hotCornerGroup: TrackingGroup = TrackingGroup(widgets: [
        self.upperLeftHotCorner,
        self.upperRightHotCorner,
        self.lowerLeftHotCorner,
        self.lowerRightHotCorner]
    )
    
    lazy var sixButtonKeyboardViewController: SixButtonKeyboardViewController = {
        var component = HotCornerGazeableComponent()
        component.onUpperLeftGaze = { _ in
            self.showPresetsViewController()
        }
        component.upperLeftTitle = "Presets"
        component.lowerLeftTitle = "Pause"
        component.onLowerLeftGaze = { _ in
            self.isUnlocked.toggle()
        }
        let controller = SixButtonKeyboardViewController.get(fromStoryboard: .sixButtonKeyboardViewController, component: component)
        controller.add(to: self)
        return controller
    }()
    
    lazy var presetsViewController: PresetsViewController = {
        var component = HotCornerGazeableComponent()
        component.onUpperLeftGaze = { _ in
            self.showSixButtonKeyboardViewController()
        }
        component.upperLeftTitle = "Back"
        component.lowerLeftTitle = "Pause"
        component.onLowerLeftGaze = { _ in
            self.isUnlocked.toggle()
        }
        let controller = PresetsViewController.get(fromStoryboard: .presets, component: component)
        controller.add(to: self)
        return controller
    }()
    
    let trackingView = CursorView()
    lazy var screenTrackingViewController: ScreenTrackingViewController = {
        let vc = ScreenTrackingViewController()
        vc.add(to: self)
        vc.delegate = self
        return vc
    }()

    var trackingDidBegin: Bool = false
    let trackedPoints: FixedQueue = FixedQueue<CGPoint>(maxSize: 10)

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBackgroundColor
        
        self.screenTrackingViewController.show(in: self.view)
        
        trackingView.frame = CGRect(origin: .zero, size: Constants.trackingViewSize)
        
        self.hotCornerGroup.add(to: self.parentTrackingEngine)
        self.view.addSubview(trackingView)
        
        self.sixButtonKeyboardViewController.show(in: self.containerView)
        self.configure(with: self.sixButtonKeyboardViewController)
        
        self.trackingView.center = self.view.center
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let hotCorners = [self.upperLeftHotCorner, self.upperRightHotCorner, self.lowerLeftHotCorner, self.lowerRightHotCorner]
        hotCorners.forEach { view in
            view.alpha = 0.0
        }
        coordinator.animate(alongsideTransition: nil) { _ in
            self.configureHotCornerCenters()
            hotCorners.forEach { view in
                view.alpha = 1.0
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let hotCorners = [self.upperLeftHotCorner, self.upperRightHotCorner, self.lowerLeftHotCorner, self.lowerRightHotCorner]
        hotCorners.forEach { view in
            view.alpha = 1.0
        }
        self.configureHotCornerCenters()
        self.screenTrackingViewController.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.screenTrackingViewController.delegate = nil
    }
    
    func configureHotCornerCenters() {
        self.upperLeftHotCorner.center = CGPoint(x: 0.0, y: 0.0)
        self.upperRightHotCorner.center = CGPoint(x: self.view.bounds.maxX, y: 0.0)
        self.lowerLeftHotCorner.center = CGPoint(x: 0.0, y: self.view.bounds.maxY)
        self.lowerRightHotCorner.center = CGPoint(x: self.view.bounds.maxX, y: self.view.bounds.maxY)
    }
    
    func configure(with trackable: HotCornerTrackable) {
        self.currentTrackingEngine = trackable.trackingEngine
        self.upperLeftHotCorner.onGaze = trackable.component?.onUpperLeftGaze
        self.upperRightHotCorner.onGaze = trackable.component?.onUpperRightGaze
        self.lowerLeftHotCorner.onGaze = trackable.component?.onLowerLeftGaze
        self.lowerRightHotCorner.onGaze = trackable.component?.onLowerRightGaze
        self.upperLeftHotCorner.text = trackable.component?.upperLeftTitle
        self.upperRightHotCorner.text = trackable.component?.upperRightTitle
        self.lowerLeftHotCorner.text = trackable.component?.lowerLeftTitle
        self.lowerRightHotCorner.text = trackable.component?.lowerRightTitle
    }
    
    func showSixButtonKeyboardViewController() {
        self.presetsViewController.hideFromParentViewController()
        self.sixButtonKeyboardViewController.show(in: self.containerView)
        self.configure(with: self.sixButtonKeyboardViewController)
    }
    
    func showPresetsViewController() {
        self.sixButtonKeyboardViewController.hideFromParentViewController()
        self.presetsViewController.show(in: self.containerView)
        self.configure(with: self.presetsViewController)
    }
}

extension HotCornersTrackableViewController: ScreenTrackingViewControllerDelegate {
    func didGestureForCalibration() {
        // do stuff here
        self.currentTrackingEngine?.isUnlocked = false
        self.parentTrackingEngine.isUnlocked = false
    }
    
    func didFinishCalibrationGesture() {
        self.currentTrackingEngine?.isUnlocked = self.isUnlocked
        self.parentTrackingEngine.isUnlocked = true
    }
    
    func didUpdateTrackedPosition(_ trackedPositionOnScreen: CGPoint?, for screenTrackingViewController: ScreenTrackingViewController) {
        DispatchQueue.main.async {
            if let position = trackedPositionOnScreen {
                self.trackingView.isHidden = false
                let positionInView = self.view.convert(position, from: nil)
                self.updateTrackedPosition(positionInView)
            } else {
                self.trackingView.isHidden = true
            }
        }
    }

    func updateTrackedPosition(_ position: CGPoint) {
        if let engine = currentTrackingEngine {
            _ = engine.updateWithTrackedPoint(position)
        } else {
            _ = parentTrackingEngine.updateWithTrackedPoint(position)
        }

        trackedPoints.add(element: position)
        let velocity = currentVelocity()
        print(velocity)
        guard trackingDidBegin || velocity > 2.0 else {
            return
        }

        trackingDidBegin = velocity >= 1
        let duration = min(Double(1.0 / velocity), 0.5) * 3.0

        let firstAnchorPoint = CGPoint(x: 0.55, y: 0.085)
        let secondAnchorPoint = CGPoint(x: 0.68, y: 0.53)
        let animator = UIViewPropertyAnimator(duration: duration, controlPoint1: firstAnchorPoint, controlPoint2: secondAnchorPoint) {
            self.trackingView.center = position
        }
        animator.startAnimation()
    }

    func currentVelocity() -> CGFloat {
        guard let first = trackedPoints.elements.first, let last = trackedPoints.elements.last else {
            return 0
        }

        return first.distance(from: last) / CGFloat(trackedPoints.elements.count)
    }
}

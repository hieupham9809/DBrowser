//
//  DBrowserInterface.swift
//  DBrowser
//
//  Created by Harley Pham on 03/05/2022.
//

import Foundation
import SwiftUI
import UIKit

public final class DBrowserInterface {
    public static let shared = DBrowserInterface()
    var wrappedViewController: UIHostingController<FloatingControlView>?
    var wrappedView: UIView?
    var fullscreenFrame: CGRect = .zero
    var compactFrame: CGRect = CGRect(x: 0, y: 40, width: FloatingControlView.size, height: FloatingControlView.size)
    var mode: ControlDisplayingMode = .compact
    public static func dbrowserView(filePath: String) -> some View {
        FloatingControlView(filePath: filePath, delegate: nil)
    }
}

extension DBrowserInterface {
    public func displayUIKit(
        filePath: String, on viewController: UIViewController, displayingOnTopMost: Bool = true
    ) {

        let wrappedViewController = UIHostingController(
            rootView: FloatingControlView(filePath: filePath, delegate: Self.shared)
        )
        wrappedViewController.view.translatesAutoresizingMaskIntoConstraints = true
        wrappedViewController.view.isOpaque = false
        wrappedViewController.view.backgroundColor = .clear

        guard let wrappedView = wrappedViewController.view else { return }
        let passthroughView = PassthroughView()
        passthroughView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        var frame: CGRect
        if displayingOnTopMost, let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(passthroughView)
            frame = window.bounds
        }
        else {
            viewController.view.addSubview(passthroughView)
            frame = viewController.view.bounds
        }
//        var frame: CGRect
//        var safeAreaLayoutFrame: CGRect
//        if displayingOnTopMost, let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
//            window.addSubview(passthroughView)
//            frame = window.bounds
//            safeAreaLayoutFrame = window.safeAreaLayoutGuide.layoutFrame
//        }
//        else {
//            viewController.view.addSubview(passthroughView)
//            frame = viewController.view.bounds
//            safeAreaLayoutFrame = UIApplication.shared.windows.first?.safeAreaLayoutGuide.layoutFrame ?? .zero
//        }
//
//        var adjustedFrame = frame
//        if safeAreaLayoutFrame != .zero {
//            adjustedFrame = CGRect(
//                x: frame.minX + safeAreaLayoutFrame.origin.x, y: frame.minY + safeAreaLayoutFrame.origin.y,
//                width: safeAreaLayoutFrame.width, height: safeAreaLayoutFrame.height
//            )
//        }

        passthroughView.frame = frame
        wrappedViewController.view = passthroughView
        passthroughView.addSubview(wrappedView)
        wrappedView.frame = compactFrame
        fullscreenFrame = frame
        viewController.addChild(wrappedViewController)

        self.wrappedViewController = wrappedViewController
        self.wrappedView = wrappedView

        setupGestures(for: wrappedView)
        registerEvents()
    }

    private func setupGestures(for view: UIView) {
        let draggingGesture = UIPanGestureRecognizer(target: Self.shared, action: #selector(panHandler(sender:)))
        view.addGestureRecognizer(draggingGesture)
        view.isUserInteractionEnabled = true
    }

    private func registerEvents() {
        NotificationCenter.default.addObserver(
            Self.shared,
            selector: #selector(rotationChangeHandler),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc func panHandler(sender: UIPanGestureRecognizer) {
        guard mode == .compact else { return }
        guard let wrappedViewController = wrappedViewController, let wrappedView = wrappedView else { return }
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: wrappedViewController.view)
            wrappedView.center = CGPoint(
                x: wrappedView.center.x + translation.x, y: wrappedView.center.y + translation.y
            )
            sender.setTranslation(.zero, in: wrappedViewController.view)
        case .ended:
            let superViewWidth = wrappedViewController.view.frame.width
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    if wrappedView.center.x > superViewWidth / 2 {
                        wrappedView.frame.origin.x = superViewWidth - wrappedView.frame.width
                    }
                    else {
                        wrappedView.frame.origin.x = 0
                    }
                },
                completion: { _ in
                    self.compactFrame = wrappedView.frame
                })
        default:
            break
        }
    }

    @objc func rotationChangeHandler() {
        if mode == .regular, let bounds = wrappedViewController?.view.bounds {
            wrappedView?.frame.size.width = bounds.width
            wrappedView?.frame.size.height = bounds.height
        }
    }
}

extension DBrowserInterface: FloatingControlViewDelegate {
    func didChangeToMode(_ mode: ControlDisplayingMode) {
        self.mode = mode
        if mode == .compact {
            self.wrappedView?.frame = self.compactFrame
        }
        else if mode == .regular {
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.wrappedView?.frame = self.fullscreenFrame
                }
            )
        }
    }

    func didClose() {
        // TODO:
    }
}

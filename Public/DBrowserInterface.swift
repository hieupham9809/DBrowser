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
    var compactFrame: CGRect = CGRect(x: 40, y: 40, width: 80, height: 80)
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

        passthroughView.frame = frame
        wrappedViewController.view = passthroughView
        passthroughView.addSubview(wrappedView)
        wrappedView.frame = compactFrame
        fullscreenFrame = frame
        let draggingGesture = UIPanGestureRecognizer(target: Self.shared, action: #selector(panHandler(sender:)))
        wrappedView.addGestureRecognizer(draggingGesture)
        wrappedView.isUserInteractionEnabled = true
        viewController.addChild(wrappedViewController)

        self.wrappedViewController = wrappedViewController
        self.wrappedView = wrappedView
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
}

extension DBrowserInterface: FloatingControlViewDelegate {
    func didChangeToMode(_ mode: ControlDisplayingMode) {
        self.mode = mode
        UIView.animate(
            withDuration: 0.3,
            animations: {
                if mode == .compact {
                    self.wrappedView?.frame = self.compactFrame
                }
                else if mode == .regular {
                    self.wrappedView?.frame = self.fullscreenFrame
                }
            }
        )
    }

    func didClose() {
        
    }


}

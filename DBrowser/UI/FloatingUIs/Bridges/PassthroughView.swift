//
//  PassthroughView.swift
//  DBrowser
//
//  Created by Harley Pham on 07/05/2022.
//

import UIKit

final class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self { return nil }
        return hitView
    }
}

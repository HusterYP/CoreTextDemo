//
//  PenOffsetViewController.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/19/25.
//

import Foundation
import UIKit

class PenOffsetViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let myView = PenOffsetView(frame: .init(x: 10, y: 100, width: view.bounds.width - 20, height: view.bounds.width - 20))
        view.addSubview(myView)
    }
}

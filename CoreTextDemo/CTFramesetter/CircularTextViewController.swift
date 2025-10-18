//
//  CircularTextViewController.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit

class CircularTextViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let myView = CircularTextView(frame: .init(x: 0, y: 100, width: view.bounds.width, height: view.bounds.width))
        view.addSubview(myView)
    }
}

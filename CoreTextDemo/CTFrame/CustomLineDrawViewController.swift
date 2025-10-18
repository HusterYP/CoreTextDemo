//
//  CustomLineDrawViewController.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit

class CustomLineDrawViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let myView = CustomLineDrawView(frame: .init(x: 10, y: 100, width: view.bounds.width - 20, height: view.bounds.width - 20))
        view.addSubview(myView)
    }
}

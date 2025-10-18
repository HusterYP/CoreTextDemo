//
//  ViewController.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let attr = NSAttributedString(string: "这是第一段文本\n这是第二段文本", attributes: [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ])
        let framesetter = CTFramesetterCreateWithAttributedString(attr)
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: 400, height: 600), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        let range = CTFrameGetStringRange(frame)
        print(frame, attr.attributedSubstring(from: NSRange(location: range.location, length: range.length)))
    }
}

//
//  DynamicHeightViewController.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit

class DynamicHeightViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let myView = DynamicHeightTextView()
        myView.translatesAutoresizingMaskIntoConstraints = false
        let myString = "你好，世界！这是一个 CTFramesetter 的例子。\n它演示了如何绘制文本，并使用 CTFramesetterSuggestFrameSizeWithConstraints 来动态计算所需的高度。"
        let myAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22),
            .foregroundColor: UIColor.black,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 5
                return style
            }()
        ]
        myView.attributedText = NSAttributedString(string: myString, attributes: myAttributes)
        view.addSubview(myView)
        // 给定宽度，让高度由内容撑开
        NSLayoutConstraint.activate([
            myView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            myView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            myView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200)
        ])
    }
}

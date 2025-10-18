//
//  MultiColumnView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit
import CoreText

class MultiColumnView: UIView {
    let attributedText: NSAttributedString = {
        // ... (使用一个很长的 NSAttributedString) ...
        let longText = String(repeating: "这是一个分栏布局的例子。Core Text 允许我们将一个长的属性字符串（CFAttributedString）流动到多个不同的路径（CGPath）中。我们只需要创建一个 CTFramesetter，然后循环调用 CTFramesetterCreateFrame。每次调用后，我们使用 CTFrameGetStringRange 来找出有多少文本被排入了当前的框架，然后将下一个框架的起始索引设置为这个范围的末尾。 ", count: 10)
        return NSAttributedString(string: longText, attributes: [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkText
        ])
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // --- 坐标系翻转 ---
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // 模拟微信读书的分页效果
        // 1. 定义两个分栏的路径
        let columnWidth = (bounds.width - 10) / 2
        let columnRect1 = CGRect(x: 0, y: 0, width: columnWidth, height: bounds.height)
        let columnRect2 = CGRect(x: columnWidth + 10, y: 0, width: columnWidth, height: bounds.height)

        let paths = [
            CGPath(rect: columnRect1, transform: nil),
            CGPath(rect: columnRect2, transform: nil)
        ]

        // (可选) 绘制边框
        context.setStrokeColor(UIColor.gray.cgColor)
        context.addPath(paths[0])
        context.addPath(paths[1])
        context.strokePath()

        // 2. 创建 CTFramesetter
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)

        // 3. 循环布局
        var currentStringIndex = 0
        let totalLength = attributedText.length

        for path in paths {
            // 如果所有文本都已排版，就停止
            guard currentStringIndex < totalLength else { break }

            // 4. 创建 CTFrame，注意 CFRange 的 location 是变化的
            let frame = CTFramesetterCreateFrame(
                framesetter,
                CFRange(location: currentStringIndex, length: 0), // length 为 0 表示 "排到末尾"
                path,
                nil
            )

            // 5. 绘制
            CTFrameDraw(frame, context)

            // 6. 更新索引！
            // 获取这个 frame 实际排版了多少字符
            let frameRange = CTFrameGetVisibleStringRange(frame)
            currentStringIndex += frameRange.length
        }
    }
}

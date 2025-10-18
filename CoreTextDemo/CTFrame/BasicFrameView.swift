//
//  BasicFrameView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit
import CoreText

class BasicFrameView: UIView {

    private let attributedText: NSAttributedString = {
        let string = "你好，世界！\n这是一个 CTFrameDraw 的基础示例。\n它简单地将整个框架一次性绘制出来。"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.blue,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 8
                return style
            }()
        ]
        return NSAttributedString(string: string, attributes: attributes)
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
        // --- 1. 通用设置 (翻转坐标系) ---
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // --- 2. 准备工作：创建 CTFrame ---
        // (这一步是 CTFramesetter 的工作, 但它是获取 CTFrame 的前提)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)

        // 我们在视图内留出 10pt 的边距
        let drawRect = bounds.insetBy(dx: 10, dy: 10)
        let path = CGPath(rect: drawRect, transform: nil)

        let ctFrame = CTFramesetterCreateFrame(
            framesetter,
            CFRange(location: 0, length: 0),
            path,
            nil
        )

        // --- 3. 核心 API：CTFrameDraw ---
        // 这一行代码就会将所有排版好的文本绘制到上下文中
        CTFrameDraw(ctFrame, context)

        // (可选) 绘制出我们用于布局的路径边框，以便观察
        context.setStrokeColor(UIColor.red.cgColor)
        context.addPath(path)
        context.strokePath()
    }
}

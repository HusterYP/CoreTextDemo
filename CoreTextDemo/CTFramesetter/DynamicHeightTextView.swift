//
//  DynamicHeightTextView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit
import CoreText

class DynamicHeightTextView: UIView {
    var attributedText: NSAttributedString? {
        didSet {
            // 当文本改变时，需要重绘并重新计算固有内容大小
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    override var bounds: CGRect {
        didSet {
            if needRelayout {
                setNeedsDisplay()
                invalidateIntrinsicContentSize()
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }

    var needRelayout = false

    // 1. 使用 CTFramesetter 计算固有内容大小
    override var intrinsicContentSize: CGSize {
        guard let attributedText = attributedText else {
            return .zero
        }

        // 创建 CTFramesetter
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)

        // 我们需要一个宽度约束来计算高度。这里我们使用视图的 bounds.width。
        // 如果 bounds.width 是 0，我们使用一个很大的宽度。
        let width = bounds.width > 0 ? bounds.width : CGFloat.greatestFiniteMagnitude

        // autolayout时，初始bounds宽度为0，计算出的高度有问题，需要等bounds宽度确定再重布局
        needRelayout = bounds.width <= 0

        // 设置约束尺寸，宽度固定，高度不限
        let constraints = CGSize(width: width, height: .greatestFiniteMagnitude)

        // 声明一个 CFRange 变量来接收实际适应的范围
        var fitRange = CFRange(location: 0, length: 0)

        // 调用 CTFramesetterSuggestFrameSizeWithConstraints 来获取建议的尺寸
        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRange(location: 0, length: attributedText.length), // 整个字符串
            nil, // 框架属性，这里不需要
            constraints,
            &fitRange // 接收实际排版范围
        )

        // 返回计算出的尺寸。我们给高度增加 1 点来避免可能的截断。
        return CGSize(width: suggestedSize.width, height: ceil(suggestedSize.height) + 1)
    }

    // 2. 使用 CTFramesetter 和 CTFrame 绘制
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
              let attributedText = attributedText else {
            return
        }

        // --- 坐标系翻转 ---
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // 创建 CTFramesetter
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)

        // 创建用于绘制的路径，这里就是整个视图的 bounds
        let path = CGPath(rect: bounds, transform: nil)

        // 使用 CTFramesetterCreateFrame 创建 CTFrame
        // CFRange(location: 0, length: 0) 表示 "整个字符串"
        let frame = CTFramesetterCreateFrame(
            framesetter,
            CFRange(location: 0, length: 0),
            path,
            nil // 框架属性
        )

        // 使用 CTFrameDraw 将框架绘制到上下文中
        CTFrameDraw(frame, context)
    }

    // 初始化时设置背景色为透明，以便看到绘制内容
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
}

//
//  PenOffsetView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/19/25.
//

import Foundation
import UIKit
import CoreText

class PenOffsetView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .lightGray
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1, y: -1)

        let attrString = NSAttributedString(string: "Hello CoreText", attributes: [
            .font: UIFont.systemFont(ofSize: 24)
        ])
        let line = CTLineCreateWithAttributedString(attrString)

        let lineWidth = CTLineGetTypographicBounds(line, nil, nil, nil)
        let flushWidth: CGFloat = bounds.width
        let flushFactor: CGFloat = 0.5 // 居中
//        let flushFactor: CGFloat = 0 // 左对齐
//        let flushFactor: CGFloat = 1 // 右对齐

        let penOffset = CTLineGetPenOffsetForFlush(line, flushFactor, flushWidth)
        let textPosition = CGPoint(x: penOffset, y: bounds.midY)
        // 设置绘制位置
        context.textPosition = textPosition
        CTLineDraw(line, context)

        // 绘制视觉bounds
        do {
            let lcoalRect = CTLineGetImageBounds(line, nil)
            // 将局部 rect 平移到实际绘制的位置
            let globalRect = lcoalRect.offsetBy(dx: textPosition.x, dy: textPosition.y)
            context.setFillColor(UIColor.red.withAlphaComponent(0.3).cgColor)
            context.fill(globalRect)
        }

        // 绘制布局bounds
        do {
            let newTextPosition = CGPoint(x: textPosition.x, y: textPosition.y - 40)
            context.textPosition = newTextPosition
            CTLineDraw(line, context)

            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            context.setFillColor(UIColor.green.withAlphaComponent(0.3).cgColor)
            let localRect = CGRect(x: newTextPosition.x, y: newTextPosition.y - descent, width: lineWidth, height: ascent + descent + leading)
            context.fill(localRect)
        }
    }
}

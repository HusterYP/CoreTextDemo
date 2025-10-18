//
//  CustomLineDrawView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit
import CoreText

class CustomLineDrawView: UIView {

    private let attributedText: NSAttributedString = {
        let string = "第一行：没有高亮。\n第二行：有黄色高亮背景。\n第三行：也没有高亮。"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 10
                return style
            }()
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    required init?(coder: NSCoder) { super.init(coder: coder); backgroundColor = .white }

    override func draw(_ rect: CGRect) {
        // --- 1. 通用设置 (翻转坐标系) ---
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // --- 2. 准备工作：创建 CTFrame ---
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
        let path = CGPath(rect: bounds.insetBy(dx: 10, dy: 10), transform: nil)
        let ctFrame = CTFramesetterCreateFrame(
            framesetter,
            CFRange(location: 0, length: 0),
            path,
            nil
        )

        // --- 3. 核心 API：CTFrameGetLines 和 CTFrameGetLineOrigins ---

        // 3a. 获取 CTLine 数组
        guard let lines = CTFrameGetLines(ctFrame) as? [CTLine] else { return }

        // 3b. 获取 CTLine 的原点 (CGPoint) 数组
        var lineOrigins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(ctFrame, CFRange(location: 0, length: 0), &lineOrigins)

        // 3c. 遍历每一行并自定义绘制
        // 注意：我们不再调用 CTFrameDraw(ctFrame, context)
        // 而是手动绘制每一行 CTLineDraw(line, context)

        for (index, line) in lines.enumerated() {

            // 获取这一行的原点
            let origin = lineOrigins[index]

            // 计算高亮矩形
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)

            // lineOrigin.y 是基线 (baseline) 的位置
            // ascent 是基线之上的高度
            // descent 是基线之下的高度
            let highlightRect = CGRect(
                x: origin.x,
                y: origin.y - descent, // 从基线向下 descent 开始
                width: CGFloat(lineWidth),
                height: ascent + descent // 高度为 ascent + descent
            )

            // --- 自定义绘制逻辑 ---
            if index == 1 { // 只高亮第二行 (索引为 1)
                context.saveGState()
                context.setFillColor(UIColor.yellow.cgColor)
                context.fill(highlightRect)
                context.restoreGState()
            }

            // --- 绘制文本 ---
            // 必须设置文本的绘制位置
            context.textPosition = CGPoint(x: origin.x, y: origin.y)
            CTLineDraw(line, context)
        }
    }
}

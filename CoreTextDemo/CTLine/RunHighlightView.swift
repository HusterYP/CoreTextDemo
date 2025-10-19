//
//  RunHighlightView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/19/25.
//

import Foundation
import UIKit
import CoreText

class RunHighlightView: UIView {

    let attributedString: NSAttributedString = {
        let string = NSMutableAttributedString(string: "点击 ", attributes: [
            .font: UIFont.systemFont(ofSize: 24)
        ])

        // 添加一个 "这里"
        string.append(NSAttributedString(string: "这里", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.blue,
            kCTUnderlineStyleAttributeName as NSAttributedString.Key: NSNumber(value: CTUnderlineStyle.single.rawValue)
        ]))

        string.append(NSAttributedString(string: " 来查看详情。", attributes: [
            .font: UIFont.systemFont(ofSize: 24)
        ]))

        return string
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

        // --- 2. 创建 CTLine ---
        let line = CTLineCreateWithAttributedString(attributedString)

        // --- 3. 测量与定位 ---
        let drawPosition = CGPoint(x: 20, y: bounds.midY)
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        CTLineGetTypographicBounds(line, &ascent, &descent, nil)

        // --- 4. 遍历 CTLine 中的所有 CTRun ---
        guard let runs = CTLineGetGlyphRuns(line) as? [CTRun] else { return }

        for run in runs {
            // 4a. 获取 run 的属性，检查是不是我们想要的那个
            guard let attributes = CTRunGetAttributes(run) as? [NSAttributedString.Key: Any],
                  let font = attributes[.font] as? UIFont else {
                continue
            }

            // 4b. 检查是否为粗体 (这是我们用来识别 "这里" 的方法)
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) {

                // 4c. 找到了！现在测量这个 run
                let runRange = CTRunGetStringRange(run)

                // 4d. 获取 run 的 X 轴起始位置 (相对于 line 的 0 点)
                let xStart = CTLineGetOffsetForStringIndex(line, runRange.location, nil)

                // 4e. 获取 run 的 X 轴结束位置
                // (注意：是 run 范围的 location + length)
                let xEnd = CTLineGetOffsetForStringIndex(line, runRange.location + runRange.length, nil)

                // 4f. 构建高亮矩形 (坐标是局部的)
                let highlightRect = CGRect(
                    x: xStart,
                    y: -descent, // Y 轴从基线向下 descent 开始
                    width: xEnd - xStart,
                    height: ascent + descent
                )

                // 4g. 将局部矩形平移到全局绘制位置
                let globalRect = highlightRect.offsetBy(dx: drawPosition.x, dy: drawPosition.y)

                // 4h. 绘制高亮
                context.setFillColor(UIColor.yellow.withAlphaComponent(0.5).cgColor)
                context.fill(globalRect)
            }
        }

        // --- 5. 最后，在顶部绘制整行文本 ---
        context.textPosition = drawPosition
        CTLineDraw(line, context)
    }
}

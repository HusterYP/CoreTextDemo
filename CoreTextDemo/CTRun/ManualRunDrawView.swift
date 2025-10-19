//
//  ManualRunDrawView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/19/25.
//

import Foundation
import UIKit
import CoreText

class ManualRunDrawView: UIView {

    let attributedString: NSAttributedString = {
        let string = NSMutableAttributedString(string: "红色的, ", attributes: [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.red
        ])

        string.append(NSAttributedString(string: "绿色的, ", attributes: [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.green
        ]))

        string.append(NSAttributedString(string: "蓝色的。", attributes: [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.blue
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

        // --- 3. 设置绘制基线位置 ---
        let drawPosition = CGPoint(x: 20, y: bounds.midY)
        context.textPosition = drawPosition // CTRunDraw 也依赖这个！

        // --- 4. 核心 API：CTLineGetGlyphRuns ---
        guard let runs = CTLineGetGlyphRuns(line) as? [CTRun] else { return }

        // --- 5. 遍历所有 CTRun 并手动绘制 ---
        // 我们不再调用 CTLineDraw(line, context)
        for run in runs {

            // 5a. 核心 API：CTRunGetAttributes
            // 获取这个 run 独有的属性字典
            guard let attributes = CTRunGetAttributes(run) as? [NSAttributedString.Key: Any] else {
                continue
            }

            // 5b. 从属性中获取颜色
            let color = attributes[.foregroundColor] as? UIColor ?? .black

            // 5c. 设置上下文的填充色
            context.setFillColor(color.cgColor)

            // 5d. 核心 API：CTRunDraw
            // 在 context.textPosition 处绘制这个 run
            // CFRange(location: 0, length: 0) 表示绘制整个 run
            CTRunDraw(run, context, CFRange(location: 0, length: 0))
        }
    }
}

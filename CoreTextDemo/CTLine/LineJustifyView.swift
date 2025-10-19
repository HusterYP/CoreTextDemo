//
//  LineJustifyView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import Foundation
import UIKit
import CoreText

class LineJustifyView: UIView {
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
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1, y: -1)

        let text = "Justified text using Core Text."
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20)
        ]
        let attrString = NSAttributedString(string: text, attributes: attrs)
        let line = CTLineCreateWithAttributedString(attrString)

        // 计算原宽度
        let width = CTLineGetTypographicBounds(line, nil, nil, nil)
        print("original width = ", width)

        // 创建对齐后的行（目标宽度 400）
        let justifiedLine = CTLineCreateJustifiedLine(line, 1.0, 400)!
//        let justifiedLine = CTLineCreateJustifiedLine(line, 0, 400)!
//        let justifiedLine = CTLineCreateJustifiedLine(line, 0.5, 400)!

        // 绘制原始行
        context.textPosition = .init(x: 10, y: 200)
        CTLineDraw(line, context)

        // 绘制对齐后的行
        context.textPosition = .init(x: 10, y: 150)
        CTLineDraw(justifiedLine, context)
    }
}

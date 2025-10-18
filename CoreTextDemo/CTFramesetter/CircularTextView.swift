//
//  CircularTextView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit
import CoreText

class CircularTextView: UIView {
    let attributedText: NSAttributedString = {
        let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi. Proin porttitor, orci nec nonummy molestie, enim est eleifend mi, non fermentum diam nisl sit amet erat. Duis semper. Duis arcu massa, scelerisque vitae, consequat in, pretium a, enim. Pellentesque congue. Ut in risus volutpat libero pharetra tempor. Cras vestibulum bibendum augue."
        return NSAttributedString(string: text, attributes: [
            .font: UIFont(name: "TimesNewRomanPS-ItalicMT", size: 14) ?? .systemFont(ofSize: 14),
            .foregroundColor: UIColor.black
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

        // 1. 创建 CTFramesetter
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)

        // 2. 创建一个圆形的 CGPath (在 bounds 内部留出 10pt 的边距)
        let path = CGPath(
            ellipseIn: bounds.insetBy(dx: 10, dy: 10),
            transform: nil
        )

        // (可选) 绘制圆形路径，以便我们能看到边界
        context.addPath(path)
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1.0)
        context.strokePath()

        // 3. 使用 CTFramesetterCreateFrame 在该圆形路径中创建 CTFrame
        let frame = CTFramesetterCreateFrame(
            framesetter,
            CFRange(location: 0, length: 0),
            path,
            nil
        )

        // 4. 绘制 CTFrame
        CTFrameDraw(frame, context)
    }
}

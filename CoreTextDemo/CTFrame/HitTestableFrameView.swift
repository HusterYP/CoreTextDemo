//
//  HitTestableFrameView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/18/25.
//

import UIKit
import CoreText

class HitTestableFrameView: UIView {

    private var ctFrame: CTFrame?
    private let attributedText: NSAttributedString = {
        let string = "点击我！\n你可以点击这个视图中的任何一个字符，\n控制台会打印出你点击的字符索引。\n试试看吧！"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 42),
            .foregroundColor: UIColor.black
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // --- 1. 坐标系翻转 ---
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // --- 2. 创建并存储 CTFrame ---
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
        let path = CGPath(rect: bounds, transform: nil)

        // 创建 CTFrame 并将其存储在属性中，以便手势处理器可以访问它
        let frame = CTFramesetterCreateFrame(
            framesetter,
            CFRange(location: 0, length: 0),
            path,
            nil
        )
        self.ctFrame = frame

        // --- 3. 绘制 ---
        CTFrameDraw(frame, context)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let ctFrame = self.ctFrame else { return }

        // --- 1. 获取点击位置 (UIKit) ---
        let tapLocationInView = gesture.location(in: self)

        // --- 2. 转换为 CoreText 坐标 (左下角原点) ---
        let tapLocationInCT = CGPoint(
            x: tapLocationInView.x,
            y: bounds.height - tapLocationInView.y
        )

        // --- 3. 获取所有行和它们的原点 ---
        guard let lines = CTFrameGetLines(ctFrame) as? [CTLine] else { return }
        var lineOrigins = [CGPoint](repeating: .zero, count: lines.count)
        // 注意：CTFrameGetLineOrigins 是相对于 CTFrame 的 path 原点的
        // 因为我们的 path 是从 (10, 10) 开始的 (insetBy)，所以原点坐标会包含这个偏移
        CTFrameGetLineOrigins(ctFrame, CFRange(location: 0, length: 0), &lineOrigins)

        // --- 4. 遍历每一行，找到被点击的行 ---
        for (index, line) in lines.enumerated() {
            let lineOrigin = lineOrigins[index]

            // 获取行边界
            var ascent: CGFloat = 0, descent: CGFloat = 0, leading: CGFloat = 0
            let lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)

            // 构造行的 bounding box (使用 CoreText 坐标系)
            // 注意：lineOrigin.y 是基线 (baseline)
            let lineRect = CGRect(
                x: lineOrigin.x,
                y: lineOrigin.y - descent, // 矩形底部
                width: CGFloat(lineWidth),
                height: ascent + descent   // 矩形高度
            )

            // 检查 Y 坐标是否在行内
            if tapLocationInCT.y >= lineRect.minY && tapLocationInCT.y <= lineRect.maxY {

                // --- 5. 【修正的核心逻辑】 ---
                // 遍历行内的每一个字符索引，检查 X 坐标

                let lineRange = CTLineGetStringRange(line)

                // 遍历从第一个字符到最后一个字符
                for i in lineRange.location..<(lineRange.location + lineRange.length) {
                    let charIndex = i
                    let nextCharIndex = i + 1

                    // 获取当前字符的左边界 (leading offset)
                    let leadingOffset = CTLineGetOffsetForStringIndex(line, charIndex, nil)

                    // 获取下一个字符的左边界 (即当前字符的右边界, trailing offset)
                    let trailingOffset = CTLineGetOffsetForStringIndex(line, nextCharIndex, nil)

                    // 将偏移量转换成 CTFrame 的坐标
                    let charLeftEdge = lineOrigin.x + leadingOffset
                    let charRightEdge = lineOrigin.x + trailingOffset

                    // 检查点击的 X 坐标是否落在这个字符的宽度范围内
                    if tapLocationInCT.x >= charLeftEdge && tapLocationInCT.x < charRightEdge {
                        // 找到了!
                        if let char = self.character(at: charIndex) {
                            print("点击了第 \(index) 行, 字符索引: \(charIndex), 字符: '\(char)'")
                        }
                        return
                    }
                }

                // 如果循环结束还没找到 (可能点击了行尾的空白处)，
                // 我们可以认为点击了最后一个字符，但这取决于业务逻辑。
                // 为清晰起见，这里我们只处理精确落在字符边界内的情况。
            }
        }

        print("点击位置在文本之外")
    }

    // 辅助函数：根据索引获取字符
    private func character(at index: Int) -> Character? {
        let string = attributedText.string
        guard index >= 0 && index < string.count else { return nil }
        let stringIndex = string.index(string.startIndex, offsetBy: index)
        return string[stringIndex]
    }
}

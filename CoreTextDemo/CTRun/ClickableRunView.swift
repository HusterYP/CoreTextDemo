//
//  ClickableRunView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/19/25.
//

import Foundation
import UIKit
import CoreText

// 1. 定义一个自定义属性 Key 来存储 URL
private let kMyLinkAttributeName = NSAttributedString.Key("MyLinkURL")

class ClickableRunView: UIView {

    let attributedString: NSAttributedString = {
        let string = NSMutableAttributedString(string: "请访问我们的网站: ", attributes: [
            .font: UIFont.systemFont(ofSize: 20)
        ])

        string.append(NSAttributedString(string: "www.example.com", attributes: [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            kMyLinkAttributeName: URL(string: "https://www.example.com")! // <-- 存储 URL
        ]))

        return string
    }()

    // 用于存储可点击区域和它们对应的数据
    private var clickableRects: [(rect: CGRect, url: URL)] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    required init?(coder: NSCoder) { super.init(coder: coder); backgroundColor = .white }

    override func draw(_ rect: CGRect) {
        // --- 1. 通用设置 (翻转坐标系) ---
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // --- 2. 准备工作 ---
        // 在每次重绘时，清空旧的矩形
        clickableRects.removeAll()

        let framesetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
        let path = CGPath(rect: bounds, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)

        // --- 3. 遍历所有行和 Run，计算并存储矩形 ---
        guard let lines = CTFrameGetLines(frame) as? [CTLine] else { return }
        var lineOrigins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(frame, CFRange(location: 0, length: 0), &lineOrigins)

        for (index, line) in lines.enumerated() {
            let lineOrigin = lineOrigins[index]

            guard let runs = CTLineGetGlyphRuns(line) as? [CTRun] else { continue }

            for run in runs {
                // 4a. 检查属性中是否有我们的 "link" key
                guard let attributes = CTRunGetAttributes(run) as? [NSAttributedString.Key: Any],
                      let url = attributes[kMyLinkAttributeName] as? URL else {
                    continue
                }

                // 4b. 找到了！测量这个 Run (与示例 2 相同)
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                let runWidth = CTRunGetTypographicBounds(run, CFRange(location: 0, length: 0), &ascent, &descent, nil)

                // 4c. 核心 API：CTRunGetImageBounds (更紧密的边界)
                // 或者我们可以用 GetTypographicBounds 来构建
                // 这里我们用另一种方式获取 X 偏移
                var glyphPosition: CGPoint = .zero
                CTRunGetPositions(run, CFRange(location: 0, length: 1), &glyphPosition) // 获取第一个字形的位置
                let xOffset = glyphPosition.x // xOffset 是相对于 lineOrigin.x 的

                // 4d. 构建 *局部* 矩形
                let localRect = CGRect(
                    x: xOffset,
                    y: -descent,
                    width: CGFloat(runWidth),
                    height: ascent + descent
                )

                // 4e. 将 *局部* 矩形平移到 *全局* (视图) 坐标
                // 注意：Core Text 坐标系！
                let globalCTRect = localRect.offsetBy(dx: lineOrigin.x, dy: lineOrigin.y)

                // 4f. 将矩形从 *Core Text* 坐标系转回 *UIKit* 坐标系 (Y 轴翻转)
                let uiKitRect = CGRect(
                    x: globalCTRect.origin.x,
                    y: bounds.height - globalCTRect.origin.y - globalCTRect.height,
                    width: globalCTRect.width,
                    height: globalCTRect.height
                )

                // 4g. 存储矩形和 URL
                clickableRects.append((rect: uiKitRect, url: url))
            }
        }

        // --- 5. 正常绘制整个 Frame ---
        CTFrameDraw(frame, context)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: self)

        // 遍历我们存储的矩形
        for hitBox in clickableRects {
            if hitBox.rect.contains(tapLocation) {
                print("点击了链接: \(hitBox.url)")
                // 在这里可以打开 URL
                // UIApplication.shared.open(hitBox.url)
                return
            }
        }
        print("没有点击到链接")
    }
}

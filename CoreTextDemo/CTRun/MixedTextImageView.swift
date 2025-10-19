//
//  MixedTextImageView.swift
//  CoreTextDemo
//
//  Created by 袁平 on 10/19/25.
//

import Foundation
import UIKit
import CoreText

// 阶段一，步骤 1：定义你的数据 (必须是 Class)
// 这个对象将被 Core Text 持有
class ImageInfo {
    let image: UIImage
    let ascent: CGFloat
    let descent: CGFloat
    let width: CGFloat

    init(image: UIImage, font: UIFont) {
        self.image = image

        // 简单的对齐：让图片底部和字体基线对齐
        // 你可以根据需求实现更复杂的对齐
        self.ascent = image.size.height
        self.descent = 0
        self.width = image.size.width * (image.size.height / font.lineHeight) // 简单缩放
    }
}


// 阶段一，步骤 2：定义回调函数
// 这些必须是 C 风格的函数，通常定义在全局或静态上下文中

// dealloc 回调：当 CTRunDelegate 被销毁时，释放 refCon
private let deallocCallback: CTRunDelegateDeallocateCallback = { refCon in
    print("Delegate dealloc")
    // 从 refCon (void*) 转回 Unmanaged，然后释放它
    Unmanaged<ImageInfo>.fromOpaque(refCon).release()
}

// Ascent 回调：返回上行高度
private let ascentCallback: CTRunDelegateGetAscentCallback = { refCon in
    // 从 refCon 获取 Swift 对象 (不增加引用计数)
    let info = Unmanaged<ImageInfo>.fromOpaque(refCon).takeUnretainedValue()
    return info.ascent
}

// Descent 回调：返回下行深度
private let descentCallback: CTRunDelegateGetDescentCallback = { refCon in
    let info = Unmanaged<ImageInfo>.fromOpaque(refCon).takeUnretainedValue()
    return info.descent
}

// Width 回调：返回宽度
private let widthCallback: CTRunDelegateGetWidthCallback = { refCon in
    let info = Unmanaged<ImageInfo>.fromOpaque(refCon).takeUnretainedValue()
    return info.width
}


// --- 视图实现 ---

class MixedTextImageView: UIView {

    private var attributedText: NSAttributedString

    // 用于绘制图片的数据
    private var imageDrawInfos: [(image: UIImage, rect: CGRect)] = []

    override init(frame: CGRect) {
        // --- 准备工作：创建带 CTRunDelegate 的属性字符串 ---
        let finalString = NSMutableAttributedString()
        let font = UIFont.systemFont(ofSize: 24)

        // 1. 添加一些文本
        finalString.append(NSAttributedString(string: "这是一些文字, ", attributes: [.font: font]))

        // 2. 准备图片和 Delegate
        let image = UIImage(systemName: "star.fill")!
        let imageInfo = ImageInfo(image: image.withRenderingMode(.alwaysOriginal), font: font)

        // 3. 阶段一，步骤 3：创建 CTRunDelegate
        var callbacks = CTRunDelegateCallbacks(
            version: kCTRunDelegateVersion1,
            dealloc: deallocCallback,
            getAscent: ascentCallback,
            getDescent: descentCallback,
            getWidth: widthCallback
        )

        // 3a. 将 Swift 对象转换为 void* (refCon)
        // Unmanaged.passRetained() 增加引用计数，Core Text 会持有它
        let refCon = Unmanaged.passRetained(imageInfo).toOpaque()

        // 3b. 创建 delegate
        guard let delegate = CTRunDelegateCreate(&callbacks, refCon) else {
            fatalError("Could not create CTRunDelegate")
        }

        // 4. 阶段一，步骤 4：附加 Delegate
        // 4a. 创建占位符 \uFFFC
        let placeholderString = NSAttributedString(string: "\u{FFFC}", attributes: [
            kCTRunDelegateAttributeName as NSAttributedString.Key: delegate,
            // 存储一份引用，方便阶段二（绘制）时快速访问
            NSAttributedString.Key("MyImageInfo"): imageInfo
        ])

        finalString.append(placeholderString)

        // 5. 添加更多文本
        finalString.append(NSAttributedString(string: " 这是一个图标。", attributes: [.font: font]))

        self.attributedText = finalString

        super.init(frame: frame)
        self.backgroundColor = .white
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func draw(_ rect: CGRect) {
        // --- 通用设置 (翻转坐标系) ---
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // 在重绘前清空
        imageDrawInfos.removeAll()

        // --- 阶段一，步骤 5：正常布局 ---
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText)
        let path = CGPath(rect: bounds, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)

        // --- 阶段二，步骤 1：绘制文本 (留下空白) ---
        CTFrameDraw(frame, context)

        // --- 阶段二：遍历 Run 并“填洞” ---
        guard let lines = CTFrameGetLines(frame) as? [CTLine] else { return }
        var lineOrigins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(frame, CFRange(location: 0, length: 0), &lineOrigins)

        for (lineIndex, line) in lines.enumerated() {
            let lineOrigin = lineOrigins[lineIndex]

            guard let runs = CTLineGetGlyphRuns(line) as? [CTRun] else { continue }

            for run in runs {
                // 阶段二，步骤 3 & 4：找到我们的占位符 Run
                guard let attributes = CTRunGetAttributes(run) as? [NSAttributedString.Key: Any],
                      let imageInfo = attributes[NSAttributedString.Key("MyImageInfo")] as? ImageInfo else {
                    // 这不是我们的图片 run，跳过
                    continue
                }

                // 阶段二，步骤 5：计算绘制位置
                // 5a. 获取 run 的 X 偏移
                let stringRange = CTRunGetStringRange(run)
                let xOffset = CTLineGetOffsetForStringIndex(line, stringRange.location, nil)

                // 5b. 构建 *全局* 矩形
                // Y 轴：(基线Y - 下行深度Y)
                let runRect = CGRect(
                    x: lineOrigin.x + xOffset,
                    y: lineOrigin.y - imageInfo.descent, // 基线向下
                    width: imageInfo.width,
                    height: imageInfo.ascent + imageInfo.descent
                )

                // 阶段二，步骤 6：手动绘制
                // 注意：由于坐标系已翻转，我们需要再次翻转图片
                context.saveGState()
                context.translateBy(x: runRect.origin.x, y: runRect.origin.y)
                context.scaleBy(x: 1.0, y: -1.0)
                // 绘制的位置是 (0, 0)，因为我们已经平移了 context
                // Y 轴是负的，因为我们翻转了
                let flippedRect = CGRect(x: 0, y: -runRect.height, width: runRect.width, height: runRect.height)
                imageInfo.image.draw(in: flippedRect)
                context.restoreGState()

                // (可选) 绘制边框以便调试
                context.setStrokeColor(UIColor.red.cgColor)
                context.stroke(runRect)
            }
        }
    }
}

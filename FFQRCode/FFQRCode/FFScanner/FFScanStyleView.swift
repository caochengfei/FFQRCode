//
//  FFScanContentView.swift
//  FFQRCode
//
//  Created by kidstone on 2018/5/24.
//  Copyright © 2018年 caochengfei. All rights reserved.
//

import UIKit

public let screenW   = UIScreen.main.bounds.width
public let screenH   = UIScreen.main.bounds.height
public let contentW  = screenW * 0.7
public let marginW   = 0.5 * (screenW - contentW)
public let marginH   = 0.5 * (screenH - contentW)

class FFScanStyleView: UIView {

    var lineImageView : UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        setUpClearRect()
        setUpFourBorder()
        setUpMovingLine()
    }
}

extension FFScanStyleView {

    fileprivate func setUpClearRect() {
        let mainRect = UIScreen.main.bounds
        let clearRect = CGRect(x: marginW, y: marginH, width: contentW, height: contentW)
        UIColor.black.withAlphaComponent(0.6).setFill()
        UIRectFill(mainRect)
        UIColor.clear.setFill()
        UIRectFill(clearRect)

    }

    fileprivate func setUpFourBorder() {

        let lineW : CGFloat = 2

        let upLeftPoint = CGPoint(x: marginW + lineW * 0.5, y: marginH + lineW * 0.5)
        let upLeftPoints = [
            upLeftPoint,
            CGPoint(x: upLeftPoint.x + 20, y: upLeftPoint.y),
            upLeftPoint,
            CGPoint(x: upLeftPoint.x, y: upLeftPoint.y + 20)]

        let upRightPoint = CGPoint(x: marginW + contentW - lineW * 0.5, y: marginH + lineW * 0.5)
        let upRightPoints = [
            upRightPoint,
            CGPoint(x: upRightPoint.x - 20, y: upRightPoint.y),
            upRightPoint,
            CGPoint(x: upRightPoint.x, y: upRightPoint.y + 20)]

        let downLeftPoint = CGPoint(x: marginW + lineW * 0.5, y: marginH + contentW - lineW * 0.5)
        let downLeftPoints = [
            downLeftPoint,
            CGPoint(x: downLeftPoint.x + 20, y: downLeftPoint.y),
            downLeftPoint,
            CGPoint(x: downLeftPoint.x, y: downLeftPoint.y - 20)]

        let downRightPoint = CGPoint(x: marginW + contentW - lineW * 0.5, y: marginH + contentW - lineW * 0.5)
        let downRightPoints = [
            downRightPoint,
            CGPoint(x: downRightPoint.x - 20, y: downRightPoint.y),
            downRightPoint,
            CGPoint(x: downRightPoint.x, y: downRightPoint.y - 20)]

        let components: [CGFloat] = [141/255,250/255,84/255,1]
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(lineW)
        ctx?.setStrokeColor(CGColor.init(colorSpace: CGColorSpaceCreateDeviceRGB(), components: components)!)
        ctx?.setLineCap(CGLineCap.square)
        ctx?.strokeLineSegments(between: upLeftPoints)
        ctx?.strokeLineSegments(between: upRightPoints)
        ctx?.strokeLineSegments(between: downLeftPoints)
        ctx?.strokeLineSegments(between: downRightPoints)
    }

    fileprivate func setUpMovingLine() {
        guard lineImageView == nil else { return }

        lineImageView = UIImageView()
        lineImageView!.contentMode = UIViewContentMode.scaleToFill
        lineImageView!.image = UIImage(named: "scanningLine")
        lineImageView!.sizeToFit()
        lineImageView!.frame.size.width = contentW - 20
        lineImageView!.center = CGPoint(x: screenW * 0.5, y: marginH + lineImageView!.frame.size.height * 0.5)
        addSubview(lineImageView!)

        startMoveLine()
    }

    func startMoveLine() {
        guard lineImageView != nil else {return}

        let animation = CABasicAnimation()
        animation.keyPath = "position.y"
        animation.fromValue = lineImageView!.frame.origin.y
        animation.toValue = marginH + contentW
        animation.duration = 3
        animation.repeatCount = MAXFLOAT
        lineImageView!.layer.add(animation, forKey: "move_lineView")
    }

    func stopMoveLine() {
        guard lineImageView != nil else {return}
        lineImageView!.layer.removeAllAnimations()
    }
}

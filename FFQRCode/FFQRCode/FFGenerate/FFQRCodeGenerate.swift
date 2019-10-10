//
//  FFQRCodeGenerate.swift
//  FFQRCode
//
//  Created by kidstone on 2018/5/29.
//  Copyright © 2018年 caochengfei. All rights reserved.
//

import UIKit
import CoreImage

struct FFQRCodeGenerate {

    static func qrCodeWithString(string: String, size: CGFloat) -> UIImage? {
        // 创建二维码滤镜实例
        let filter = CIFilter(name: "CIQRCodeGenerator")
        // 滤镜恢复默认设置
        filter?.setDefaults()
        // 给滤镜添加数据
        let data = string.data(using: .utf8)
        // 给filter赋值
        filter?.setValue(data, forKey: "inputMessage")
        //设置纠错等级越高；即识别越容易，值可设置为L(Low) |  M(Medium) | Q | H(High)
        filter?.setValue("Q", forKey: "inputCorrectionLevel")

        guard var ciimage = filter?.outputImage else { return nil }
        let scale = min(size / ciimage.extent.width, size/ciimage.extent.height)

        let transfrom = CGAffineTransform.init(scaleX: scale, y: scale)
        ciimage = ciimage.transformed(by: transfrom)

        return UIImage(ciImage: ciimage)
    }

    static func createQRCodeWithString(string: String, icon: String, size: CGFloat) -> UIImage? {

        guard let sourceImage = self.qrCodeWithString(string: string, size: size) else {
            return nil
        }
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))

        sourceImage.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size, height: size)))
        guard let iconImage = UIImage(named: icon) else {
            return sourceImage
        }

        let iconW = size * 0.3
        let iconH = iconW / (iconImage.size.width / iconImage.size.height)
        let iconX = (size - iconW) * 0.5
        let iconY = (size - iconH) * 0.5

        iconImage.draw(in: CGRect(origin: CGPoint(x: iconX, y: iconY),
                               size: CGSize(width: iconW, height: iconH) ))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

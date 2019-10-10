//
//  FFQRCodeGenerate.swift
//  FFQRCode
//
//  Created by kidstone on 2018/5/25.
//  Copyright © 2018年 caochengfei. All rights reserved.
//

import UIKit
import Photos

class FFQRCodeGenerateController: UIViewController {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 300, height: 300)
        imageView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        view.addSubview(imageView)
        return imageView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "我的二维码"
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveImage))

        imageView.image = FFQRCodeGenerate.createQRCodeWithString(string: "我是二维码", icon: "icon_head.jpg", size: imageView.bounds.width)
    }

    @objc func saveImage() {

        requestAuthorization {[unowned self] (success, msg) in
            if success == true {
                UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                guard msg != nil else { return }
                self.showAlert(message: msg!)
            }
        }
    }

    @objc func image(image: UIImage,didFinishSavingWithError error: Error?,contextInfo: AnyObject) {
        guard error != nil else {
            showAlert(message: "保存成功")
            return
        }
        showAlert(message: error?.localizedDescription ?? "保存失败")
    }

    func requestAuthorization(success: @escaping ((_ success: Bool, _ message: String?)->())) {

        let status = PHPhotoLibrary.authorizationStatus()

        switch status {
        case .authorized:
            success(true,nil)
        case .denied:
            success(false,"请前往系统设置中，允许访问相册")
        case .restricted:
            success(false,"由于系统限制，无法访问")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (state) in
                DispatchQueue.main.async {
                    if state == .authorized {
                        success(true,nil)
                    } else {
                        success(false,nil)
                    }
                }
            }
        }
    }

}


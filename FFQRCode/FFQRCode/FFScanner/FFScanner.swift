//
//  FFScanner.swift
//  FFQRCode
//
//  Created by kidstone on 2018/5/24.
//  Copyright © 2018年 caochengfei. All rights reserved.
//

import UIKit
import AVFoundation

class FFScanner: UIViewController {

    // 扫描元数据类型：qr 二维码 | outher 条形码
    private lazy var metadataObjectTypes : [AVMetadataObject.ObjectType] = {
        return [AVMetadataObject.ObjectType.qr,
                AVMetadataObject.ObjectType.ean8,
                AVMetadataObject.ObjectType.ean13,
                AVMetadataObject.ObjectType.code128]
    }()

    private lazy var device: AVCaptureDevice? = {
        // 设备类型
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        return device
    }()

    private lazy var session: AVCaptureSession = {
        // 会话
        let session = AVCaptureSession()

        guard let inputDevice = device else {
            showAlert(message: "未检测到摄像头")
            return session
        }
        // 获取输入源
        guard let input = try? AVCaptureDeviceInput(device: inputDevice) else {
            showAlert(message: "初始化输入设备失败")
            return session
        }
        // 添加输入源
        session.addInput(input)

        // 设置输出源
        var metaDataOutPut = AVCaptureMetadataOutput()
        session.addOutput(metaDataOutPut)
        // 指定识别类型这一步一定要在输出添加到会话之后，否则设备的课识别类型会为空，程序会出现崩溃
        // 二维码/条形码
        metaDataOutPut.metadataObjectTypes = metadataObjectTypes
        metaDataOutPut.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // 该rect 是按照横屏的左上角为原点，x轴为竖屏的高  y轴为竖屏的宽
        metaDataOutPut.rectOfInterest = CGRect(x:marginH / screenH , y: marginW / screenW, width: contentW / screenH, height: contentW / screenW)

        // 设置视频输出，用于光感
        var videoOutPut = AVCaptureVideoDataOutput()
        session.addOutput(videoOutPut)
        videoOutPut.setSampleBufferDelegate(self, queue: DispatchQueue.main)

        // 高质量采样
        session.sessionPreset = AVCaptureSession.Preset.high

        return session
    }()


    fileprivate lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        return previewLayer
    }()

    fileprivate lazy var qrCodeView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    fileprivate lazy var contentView : FFScanStyleView = {
        let view = FFScanStyleView(frame: UIScreen.main.bounds)

        var autoresizing = UIViewAutoresizing()
        autoresizing.insert(UIViewAutoresizing.flexibleWidth)
        autoresizing.insert(UIViewAutoresizing.flexibleHeight)
        view.autoresizingMask = autoresizing

        return view
    }()

    fileprivate lazy var descriptionLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()


    fileprivate lazy var torchBtn : UIButton = { [unowned self] in
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(UIImage(named:"icon_flashlight_off"), for: UIControlState.normal)
        button.setImage(UIImage(named: "icon_flashlight_on"), for: UIControlState.selected)
        button.alpha = 0
        button.sizeToFit()
        button.bounds.size = CGSize(width: button.bounds.width * 0.6, height: button.bounds.height * 0.6)
        button.center = CGPoint(x: screenW / 2, y: screenH - marginH - button.bounds.height / 2)
        button.addTarget(self, action: #selector(torchBtnAction), for: UIControlEvents.touchUpInside)
        view.addSubview(button)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        requestAuthorization {[unowned self] (success, msg) in
            if success == true {
                NotificationCenter.default.addObserver(self, selector: #selector(self.applicationBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.applicationActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

                self.setUpUI()
                self.startScanning()
            } else {
                guard msg != nil else { return }
                self.showAlert(message: msg!)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    func requestAuthorization(success: @escaping ((_ success: Bool, _ message: String?)->())) {

        guard device != nil else {
            success(false,"未检测到摄像头")
            return
        }
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized:
            success(true,nil)
        case .denied:
            success(false,"请前往系统设置中，允许访问相机权限")
        case .restricted:
            success(false,"由于系统限制，无法访问")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (state) in
                DispatchQueue.main.async {
                    if state == true {
                        success(true,nil)
                    } else {
                        success(false,nil)
                    }
                }
            }
        }
    }

    fileprivate func setUpUI() {
        view.layer.insertSublayer(previewLayer, at: 0)
        view.addSubview(contentView)
        view.insertSubview(qrCodeView, at: 0)
    }

    fileprivate func startScanning() {
        if device != nil && session.isRunning == false {
            session.startRunning()
            contentView.startMoveLine()
        }
    }

    fileprivate func stopScanning() {
        if device != nil && session.isRunning == true {
            session.stopRunning()
            contentView.stopMoveLine()
        }
    }

    @IBAction func pushToNewController(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            let generate = FFQRCodeGenerateController()
            generate.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(generate, animated: true)

        case 1:
            let picker = UIImagePickerController()
            picker.navigationBar.isTranslucent = true
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true, completion: nil)

        default: break

        }
    }
}

// MARK: - torchBtnAction
extension FFScanner {
    @objc func torchBtnAction() {
        if (device?.hasTorch)! == false { return }
        if (device?.isTorchAvailable)! == false { return }

        do {
            try device?.lockForConfiguration()
            if torchBtn.isSelected == false {

                do {
                    try device?.setTorchModeOn(level: 0.3)
                } catch {
                    print("Could not set torch leve")
                }

                device?.torchMode = .on
                torchBtn.isSelected = true

            } else  {
                device?.torchMode = .off
                torchBtn.isSelected = false
            }

        } catch {
            print("Torch could not be used")
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension FFScanner : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        guard let ciimage = CIImage(image: image) else {
            return
        }
        let options = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        let context = CIContext(options: nil)
        guard let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: context, options: options) else {
            return
        }
        let results = detector.features(in: ciimage)
        if results.count == 0 {
            scanResults(string: "没有获取到信息")
            return
        }
        for result in results {
            guard let object = result as? CIQRCodeFeature else { return }
            qrCodeView.frame = object.bounds
            scanResults(string: object.messageString!)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension FFScanner : AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        qrCodeView.frame = .zero
        for metadataObject in metadataObjects {
            guard let object = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            // 二维码
            if object.type == AVMetadataObject.ObjectType.qr {
                let qrCodeObject = previewLayer.transformedMetadataObject(for: object)
                qrCodeView.frame = qrCodeObject!.bounds
            } else {
                // 条形码
                let barCodeObject = previewLayer.transformedMetadataObject(for: object)
                qrCodeView.frame = barCodeObject!.bounds
            }
            scanResults(string: object.stringValue!)
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let metadataDict = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        guard let metadata = metadataDict as? Dictionary<CFString, Any> else {
            return
        }
        guard let exifMetadata = metadata[kCGImagePropertyExifDictionary] as? Dictionary<CFString, Any> else {
            return
        }
        guard let brightnessValue = exifMetadata[kCGImagePropertyExifBrightnessValue] as? Double else {
            return
        }
        // 出现手电筒按钮
        if brightnessValue < -1 {
            torchBtn.alpha = 1
        } else {
            if torchBtn.isSelected == false {
                torchBtn.alpha = 0
            }
        }
    }
}

// MARK: - Processing scan results
extension FFScanner {

    func scanResults(string: String) {
        stopScanning()

        showMessage(message: string)
        guard let url = URL(string: string) else {
            return
        }

        guard #available(iOS 10.0, *) else {
            // Fallback on earlier versions
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
            return
        }
        UIApplication.shared.open(url, options: [:]) { (success) in
        }
    }
}

// MARK: - showMessage
extension FFScanner {

    func showMessage(message: String) {
        if view.subviews.contains(descriptionLabel) == false {
            view.addSubview(descriptionLabel)
        }
        descriptionLabel.text = message
        descriptionLabel.bounds.size = CGSize(width: screenW - marginW * 2, height: marginH - 49)
        descriptionLabel.center = CGPoint(x: screenW / 2, y: screenH - marginH + descriptionLabel.bounds.height / 2 + 5)
    }
}

// MARK: - UIApplicationState
extension FFScanner {
    @objc func applicationBackground() {
        stopScanning()
    }

    @objc func applicationActive() {
        startScanning()
    }
}



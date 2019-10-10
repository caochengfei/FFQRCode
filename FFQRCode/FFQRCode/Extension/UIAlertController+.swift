//
//  UIAlertController+.swift
//  FFQRCode
//
//  Created by kidstone on 2018/5/29.
//  Copyright © 2018年 caochengfei. All rights reserved.
//

import UIKit

typealias alertControllerClickBlock = (_ index: Int) -> Void

extension UIViewController {

    func showAlert(message: String, actionClick: alertControllerClickBlock? = nil) {
        let alertController = UIAlertController(title: "提醒", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "知道了", style: UIAlertActionStyle.cancel) {(cancelAction) in
            if actionClick != nil {
                actionClick!(alertController.actions.index(of: cancelAction)!)
            }
        }

        if message.contains("系统设置") {
            let action =  UIAlertAction(title: "前往", style: UIAlertActionStyle.default) { (alertAction) in
                let urlObj = URL(string: UIApplicationOpenSettingsURLString)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlObj!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(urlObj!)
                }
            }
            alertController.addAction(action)
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}

extension UIView {
    func showAlert(message: String, actionClick: alertControllerClickBlock? = nil) {

        let viewController = currentViewController()
        viewController?.showAlert(message: message, actionClick: actionClick)
    }

    // 获取当前显示的视图控制器
    func currentViewController() -> UIViewController? {
        var next:UIView? = self
        repeat{
            if let nextResponder = next?.next, ((nextResponder as? UIViewController) != nil) {
                return nextResponder as? UIViewController
            }
            next = next?.superview
        } while next != nil
        return nil
    }
}

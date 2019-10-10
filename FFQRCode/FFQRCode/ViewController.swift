//
//  ViewController.swift
//  FFQRCode
//
//  Created by kidstone on 2018/5/23.
//  Copyright © 2018年 caochengfei. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        print(self)
        let scanner = FFScanner()
        navigationController?.pushViewController(scanner, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


    }
}


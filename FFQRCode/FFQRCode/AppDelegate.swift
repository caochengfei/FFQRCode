//
//  AppDelegate.swift
//  FFQRCode
//
//  Created by kidstone on 2018/5/23.
//  Copyright © 2018年 caochengfei. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 9.0, *) {


            let icon = UIApplicationShortcutIcon(templateImageName: "icon_shortcut_scan")
            let shortcutScanItem = UIApplicationShortcutItem(type: "caochengfei.FFQRCode.openScan", localizedTitle: "扫一扫", localizedSubtitle: nil, icon: icon, userInfo: nil)

            var shortcutItems = UIApplication.shared.shortcutItems
            if shortcutItems?.count == 0 {
                shortcutItems?.append(shortcutScanItem)
            }

            for item in shortcutItems! {
                if item.icon == shortcutScanItem.icon {
                    continue
                } else {
                    // do any sing
                    shortcutItems?.append(shortcutScanItem)
                    UIApplication.shared.shortcutItems = shortcutItems
                }
            }
            UIApplication.shared.shortcutItems = shortcutItems
        }



        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.localizedTitle == "扫一扫" {
            print("进入扫一扫")
        }
    }


}


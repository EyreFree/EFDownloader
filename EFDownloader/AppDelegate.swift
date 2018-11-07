//
//  AppDelegate.swift
//  EFDownloader
//
//  Created by EyreFree on 2018/10/5.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    static var handles = [EFKuaiShou]()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        var successUserCount: Int = 0
        var successVideoCount: Int = 0
        var failUserCount: Int = 0
        var failVideoCount: Int = 0
        let idList = [
            "wenyou666",
            "3x3k7ay3dw638ue",
            "Lm_921206"
        ]
        for id in idList {
            let object = EFKuaiShou(id: id) { [weak self] (successCount: Int, failCount: Int)in
                if let _ = self {
                    successVideoCount += successCount
                    if failCount > 0 {
                        failVideoCount += failCount
                        failUserCount += 1
                    } else {
                        successUserCount += 1
                    }

                    print("failUserCount: \(failUserCount), successUserCount: \(successUserCount), idList.count: \(idList.count)")
                    if (failUserCount + successUserCount) >= idList.count {
                        print("\n----------------------------------------------")
                        if failUserCount > 0 {
                            print("有 \(failUserCount) 个用户的共 \(failVideoCount) 个视频未下载完成，请稍后重试！\n有 \(successVideoCount) 个视频已下载成功保存于 \(EFPath.shared.project + "/download 目录下！")")
                        } else {
                            print("全部视频下载完成，保存于 \(EFPath.shared.project + "/download 目录下！")")
                        }
                    }
                }
            }
            object.getVideos()
            AppDelegate.handles.append(object)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }
}

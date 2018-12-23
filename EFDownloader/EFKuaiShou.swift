//
//  EFKuaiShou.swift
//  EFDownloader
//
//  Created by EyreFree on 2018/10/5.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class EFKuaiShouItem: BaseNetworkModel {

    var caption: String?
    var timestamp: String?
    var playUrl: String?
    var musicName: String?

    required init(json: JSON) {
        caption = json["caption"].string
        timestamp = json["timestamp"].intString
        playUrl = json["playUrl"].string
        musicName = json["musicName"].string
        super.init(json: json)
    }
}

class EFKuaiShouList: TypeBaseListNetworkModel<EFKuaiShouItem> {

    var pcursor: String?

    required init(json: JSON) {
        pcursor = json["pcursor"].string
        super.init(json: json)
    }
}

class EFKuaiShou: NSObject {

    let retryCount: Int = 3

    var id: String
    var dataItemList: [EFKuaiShouItem] = [EFKuaiShouItem]()
    var completion: ((_ successCount: Int, _ failCount: Int) -> Void)? = nil

    init(id: String, completion: ((_ successCount: Int, _ failCount: Int) -> Void)? = nil) {
        self.id = id
        self.completion = completion
        super.init()
    }

    func getVideos() {
        EFNetwork.shared.request("http://live.kuaishou.com/profile/\(id)") { [weak self] (data) in
            if let strongSelf = self {
                guard let data = data else {
                    return
                }
                let htmlString = String(data: data, encoding: String.Encoding.utf8)
                if let jsonString = htmlString?
                    .components(separatedBy: "window.VUE_MODEL_INIT_STATE['profileModel']=")
                    .last?
                    .components(separatedBy: "</script>")
                    .first?
                    .clean()
                    .removeSuffix(string: ";") {
                    let json = JSON(parseJSON: jsonString)
                    let list = EFKuaiShouList(json: json["profile"]["tabDatas"]["open"])

                    strongSelf.dataItemList = [EFKuaiShouItem]()
                    strongSelf.dataItemList.append(contentsOf: list.list ?? [])

                    strongSelf.getNextVideosWith(pcursor: list.pcursor)
                }
            }
        }
    }

    func getNextVideosWith(pcursor: String?) {
        guard let pcursor = pcursor?.clean() else {
            return
        }
        if pcursor == "no_more" || pcursor.isEmpty {
            downloadVideoFile()
            return
        }
        let parameters: [String: Any] = [
            "count": 24,
            "pcursor": pcursor,
            "principalId": id,
            "privacy": "public"
        ]
        EFNetwork.shared.request("http://live.kuaishou.com/feed/profile", method: .post, parameters: parameters) { [weak self] (data) in
            if let strongSelf = self {
                guard let data = data else {
                    return
                }
                if let jsonString = String(data: data, encoding: String.Encoding.utf8) {
                    let json = JSON(parseJSON: jsonString)
                    let list = EFKuaiShouList(json: json)

                    strongSelf.dataItemList.append(contentsOf: list.list ?? [])

                    strongSelf.getNextVideosWith(pcursor: list.pcursor)
                }
            }
        }
    }

    func downloadVideoFile() {
        func finishCheck(successCount: Int, failCount: Int, totalCount: Int) {
            if (successCount + failCount) >= totalCount {
                print("\(self.id) 视频下载完成！")
                self.completion?(successCount, failCount)
            }
        }

        let allCount: Int = dataItemList.count
        var finishCount: Int = 0
        var failCount: Int = 0
        dataItemList = dataItemList.filter({ [weak self] (item) -> Bool in
            guard let _ = self else {
                return false
            }
            return item.playUrl?.clean().hasSuffix(".mp4") == true
        })
        let effectCount: Int = dataItemList.count
        print("\(id) 作品列表获取完成，包含 \(dataItemList.count)/\(allCount) 个有效 mp4 视频作品，开始下载：")
        for dataItem in dataItemList {
            let fileName: String = "\(dataItem.timestamp?.bigClean() ?? "")_\(dataItem.caption?.bigClean().cutSuffix(count: 10) ?? "")_\(dataItem.musicName?.bigClean().cutSuffix(count: 10) ?? "").mp4"
            let fileNameFull: String = "\(dataItem.timestamp?.bigClean() ?? "")_\(dataItem.caption?.bigClean() ?? "")_\(dataItem.musicName?.bigClean() ?? "").mp4"
            let fileNameID: String = "\(dataItem.timestamp?.bigClean() ?? "未知").mp4"
            if let videoURL = dataItem.playUrl {
                let pathString = EFPath.shared.project + "/Download/KuaiShou/\(id)/\(fileName)"
                let pathFullString = EFPath.shared.project + "/Download/KuaiShou/\(id)/\(fileNameFull)"
                let pathIDString = EFPath.shared.project + "/Download/KuaiShou/\(id)/\(fileNameID)"
                if pathString.isExistAtPath() || pathFullString.isExistAtPath() || pathIDString.isExistAtPath() {
                    print("\(id) 进度：\(finishCount + 1)/\(effectCount)" + "，文件已存在，忽略下载任务")
                    finishCount += 1
                    finishCheck(successCount: finishCount, failCount: failCount, totalCount: effectCount)
                } else {
                    func downloadFinish(err: String?, downloadCount: Int = 0) {
                        if let err = err {
                            if downloadCount >= retryCount {
                                print("\(self.id) 进度：\(finishCount + 1)/\(effectCount)" + "，重试失败：" + err + "，请稍后手动重试！")
                                failCount += 1
                            } else {
                                print("\(self.id) 进度：\(finishCount + 1)/\(effectCount)" + "，任务失败，即将重试...")
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
                                    if let _ = self {
                                        videoURL.downloadVideo(savePath: pathIDString) { [weak self] (err) in
                                            if let _ = self {
                                                downloadFinish(err: err, downloadCount: downloadCount + 1)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            print("\(self.id) 进度：\(finishCount + 1)/\(effectCount)" + "，下载完成！")
                            finishCount += 1
                        }
                        finishCheck(successCount: finishCount, failCount: failCount, totalCount: effectCount)
                    }
                    videoURL.downloadVideo(savePath: pathIDString) { [weak self] (err) in
                        if let _ = self {
                            downloadFinish(err: err)
                        }
                    }
                }
            }
        }
    }
}

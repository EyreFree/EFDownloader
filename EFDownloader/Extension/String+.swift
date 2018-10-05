//
//  String+.swift
//  EFDownloader
//
//  Created by EyreFree on 2018/10/6.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

import Foundation
import Alamofire
import SDWebImage

extension String {

    // [] 操作符重载
    subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }

    // Param encode
    func paramEncode() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    func utf8Encode() -> String? {
        let customAllowedSet = NSCharacterSet(charactersIn: "`#%^{}\"[]|\\<> ").inverted
        return self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
    }

    // 是否符合输入的正则表达式
    func conform(regex: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }

    // 子串数量
    func occurrencesOf(subString: String) -> Int {
        return self.components(separatedBy: subString).count - 1
    }

    // 替换某个子字符串为另一字符串
    func replace(_ string: String, with: String, options: CompareOptions? = nil) -> String {
        if let options = options {
            return self.replacingOccurrences(of: string, with: with, options: options, range: nil)
        }
        return self.replacingOccurrences(of: string, with: with)
    }

    // 替换尾缀
    func replaceSuffix(string: String, with: String) -> String {
        if self.hasSuffix(string) {
            return String(self.dropLast(string.count)) + with
        }
        return self
    }

    // 替换前缀
    func replacePrefix(string: String, with: String) -> String {
        if self.hasPrefix(string) {
            return with + String(self.dropFirst(string.count))
        }
        return self
    }

    // 清除字符串左右空格和换行
    func clean() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func bigClean() -> String {
        return self.remove(string: " ").remove(string: "\n").remove(string: "\r").clean()
    }

    // 移除某个子串
    func remove(string: String) -> String {
        return self.replace(string, with: "")
    }

    // 移除某个前缀
    func removePrefix(string: String) -> String {
        return self.replacePrefix(string: string, with: "")
    }

    // 移除某个尾缀
    func removeSuffix(string: String) -> String {
        return self.replaceSuffix(string: string, with: "")
    }

    // 截取头部
    func cutPrefix(count: Int) -> String {
        let finalCount: Int = min(self.count, count)
        return String(self[..<self.index(self.startIndex, offsetBy: finalCount)])
    }

    // 截取尾部
    func cutSuffix(count: Int) -> String {
        let finalCount: Int = max(0, self.count - count)
        return String(self[self.index(self.startIndex, offsetBy: finalCount)...])
    }

    // 整数
    func i() -> Int? {
        return Int(self)
    }
    //长整数
    func li() -> Int64? {
        return Int64(self)
    }

    // 是图片地址
    func isImageURL() -> Bool {
        let formats = [".jpg", ".png"]
        for format in formats {
            if self.hasSuffix(format) {
                return true
            }
        }
        return false
    }

    ///判断路径文件是否存在
    func isExistAtPath() -> Bool {
        return FileManager.default.fileExists(atPath: self)
    }

    // 下载图片
    func downloadImage() {
        if self.clean().isEmpty == false {
            if let url = URL(unexpectedString: self) {
                SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: SDWebImageDownloaderOptions.continueInBackground, progress: nil, completed: { (image, data, error, finished) in


                })
            }
        }
    }

    // 下载视频
    func downloadVideo(savePath: String, completion: ((String?) -> Void)? = nil) {
        if self.clean().isEmpty == false {
            Alamofire.download(self.clean()) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                if let customUrl = URL(unexpectedString: "file://" + savePath) {
                    return (destinationURL: customUrl, options: DownloadRequest.DownloadOptions.createIntermediateDirectories)
                }
                return DownloadRequest.suggestedDownloadDestination()(url, response)
            }.response { response in // method defaults to `.get`
                var errStr: String? = nil
                if let errorString = response.error?.localizedDescription {
                    errStr = errorString + "(\(response.response?.statusCode ?? 0))"
                }
                if let statusCode = response.response?.statusCode, !(200 ... 399).contains(statusCode) {
                    errStr = "Network error.(\(response.response?.statusCode ?? 0))"
                }
                completion?(errStr)
            }
        }
    }
}

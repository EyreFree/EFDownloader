//
//  EFPath.swift
//  EFDownloader
//
//  Created by EyreFree on 2018/10/6.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

import Foundation

class EFPath {

    static let shared = EFPath()

    // 程序执行路径
    let base = FileManager.default.currentDirectoryPath

    // Xcode 工程路径
    lazy var project: String = {
        if let projectFilePath = Bundle.main.path(forResource: "PROJECT_DIR", ofType: nil) {
            return (try? String(contentsOfFile: projectFilePath, encoding: String.Encoding.utf8).clean()) ?? ""
        }
        return ""
    }()
}

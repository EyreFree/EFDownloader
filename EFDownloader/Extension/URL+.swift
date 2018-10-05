//
//  URL+.swift
//  EFDownloader
//
//  Created by EyreFree on 2018/10/6.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

import Foundation

extension URL {

    init?(unexpectedString: String?) {
        if let tryString = unexpectedString?.clean()/*.replacePrefix(string: "http:", with: "https:")*/ {
            if nil != URL(string: tryString) {
                self.init(string: tryString)
            } else {
                if let encodeString = tryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    self.init(string: encodeString)
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
    }
}

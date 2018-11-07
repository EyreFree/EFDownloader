//
//  JSON+.swift
//  EFDownloader
//
//  Created by EyreFree on 2018/10/16.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

import SwiftyJSON

extension JSON {

    var intString: String? {
        if nil != self.string {
            return self.string
        }
        if let intVal = self.int64 {
            return "\(intVal)"
        }
        return nil
    }
}

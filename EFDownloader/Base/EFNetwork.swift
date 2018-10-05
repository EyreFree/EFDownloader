//
//  EFNetwork.swift
//  EFDownloader
//
//  Created by EyreFree on 2018/10/6.
//  Copyright © 2018年 EyreFree. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class BaseNetworkModel: NSObject {

    required init(json: JSON) {
        super.init()

    }
}

class TypeBaseListNetworkModel<T: BaseNetworkModel>: BaseNetworkModel {

    var list: [T]?

    required init(json: JSON) {
        list = json["list"].array?.map { T(json: $0) }
        super.init(json: json)
    }
}

class EFNetworkManager: SessionManager {

    init(requestTimeout: TimeInterval = 8, customHeader: HTTPHeaders? = nil) {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = customHeader ?? SessionManager.defaultHTTPHeaders
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = requestTimeout // 秒
        configuration.timeoutIntervalForResource = 2 * requestTimeout
        super.init(configuration: configuration)
    }
}

class EFNetwork: NSObject {

    static let shared = EFNetwork()

    func request(_ url: URLConvertible, method: HTTPMethod = .get, parameters: [String : Any]? = nil, requestTimeout: TimeInterval = 8, customHeader: [String: String]? = nil, completion: @escaping (Data?) -> Void) {
        func manager(requestTimeout: TimeInterval = 8, customHeader: [String: String]? = nil) -> EFNetworkManager {
            struct Anchors {
                static var managerDict = [TimeInterval: EFNetworkManager]()
            }
            if let manager = Anchors.managerDict[requestTimeout] {
                return manager
            }
            let manager = EFNetworkManager(requestTimeout: requestTimeout, customHeader: customHeader)
            Anchors.managerDict.updateValue(manager, forKey: requestTimeout)
            return manager
        }

        var header = SessionManager.defaultHTTPHeaders
        for item in customHeader ?? [:] {
            header.updateValue(item.value, forKey: item.key)
        }

        manager(requestTimeout: requestTimeout, customHeader: header).request(
            url,
            method: method,
            parameters: parameters,
            encoding: JSONEncoding(),
            headers: header
            ).response { [weak self] (response) in
                if let _ = self {
                    guard let data = response.data else {
                        return print("数据异常:\(response.response?.statusCode ?? 0)")
                    }
                    if let errorString = response.error?.localizedDescription {
                        return print(errorString + "\(response.response?.statusCode ?? 0)")
                    }
                    if let statusCode = response.response?.statusCode, !(200 ... 399).contains(statusCode) {
                        return print("请求失败:" + "\(response.response?.statusCode ?? 0)")
                    }
                    completion(data)
                }
        }
    }
}

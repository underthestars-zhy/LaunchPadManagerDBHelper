//
//  URL.swift
//  
//
//  Created by 朱浩宇 on 2022/6/27.
//

import Foundation

extension URL {
    init(universalFilePath: String) {
        if #available(macOS 13, *) {
            self.init(filePath: universalFilePath)
        } else {
            self.init(fileURLWithPath: universalFilePath)
        }
    }

    func universalPath() -> String {
        if #available(macOS 13, *) {
            return self.path().removingPercentEncoding ?? self.path()
        } else {
            return self.path.removingPercentEncoding ?? self.path
        }
    }
}

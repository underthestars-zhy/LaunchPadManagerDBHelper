//
//  URL.swift
//  
//
//  Created by 朱浩宇 on 2022/6/27.
//

import Foundation

extension URL {
    init(universalFilePath: String) {
        self.init(fileURLWithPath: universalFilePath)
    }

    func universalPath() -> String {
        return self.path.removingPercentEncoding ?? self.path
    }
}

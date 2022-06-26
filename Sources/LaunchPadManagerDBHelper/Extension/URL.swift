//
//  URL.swift
//  
//
//  Created by 朱浩宇 on 2022/6/26.
//

import Foundation

extension URL {
    func universalPath() -> String {
        if #available(iOS 16, macOS 13, *) {
            return self.path()
        } else {
            return self.path
        }
    }
}

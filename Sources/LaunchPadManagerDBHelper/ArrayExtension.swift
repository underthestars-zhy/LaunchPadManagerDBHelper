//
//  ArrayExtension.swift
//  
//
//  Created by 朱浩宇 on 2022/12/21.
//

import Foundation

extension Array where Self: Hashable {
    func removeSameValue() -> Self {
        Set(self).map { $0 }
    }
}

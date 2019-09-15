//
//  StringUtil.swift
//  MobileTrek
//
//  Created by Steve Fisher on 11/8/18.
//  Copyright © 2018 RecoveryTrek. All rights reserved.
//

class StringUtil {
    
    static func unescapeString(_ value: String) -> String {
        return value.replacingOccurrences(of: "\"", with: "")
    }
}


extension Array {
    func canSupport(index: Int ) -> Bool {
        return index >= startIndex && index < endIndex
    }
}

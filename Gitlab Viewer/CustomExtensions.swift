//
//  CustomExtensions.swift
//  Gitlab Viewer
//
//  Created by Asif on 28/06/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation

extension URL {
    func queryParams() -> [String:String] {
        let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems
        let queryTuples: [(String, String)] = queryItems?.compactMap{
            guard let value = $0.value else { return nil }
            return ($0.name, value)
        } ?? []
        return Dictionary(uniqueKeysWithValues: queryTuples)
    }
}

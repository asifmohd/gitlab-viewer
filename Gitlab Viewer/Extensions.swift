//
//  Extensions.swift
//  Gitlab Viewer
//
//  Created by Asif on 04/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation

extension Array where Element: Identifiable {
    func isLast(item: Element) -> Bool {
        return self.last?.id == item.id
    }
}

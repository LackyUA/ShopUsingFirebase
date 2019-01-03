//
//  Item.swift
//  ShopApp
//
//  Created by Dmytro Dobrovolskyy on 11/7/18.
//  Copyright © 2018 YellowLeaf. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JSONAbleType {
    static func fromJSON(_: [String: Any], withID id: String) -> Self
}

final class Item: NSObject, JSONAbleType {
    let id: String
    let name: String
    let categories: [String]
    let images: [String]
    
    
    init(id: String, name: String, categories: [String], images: [String]) {
        self.id = id
        self.name = name
        self.categories = categories
        self.images = images
    }

    static func fromJSON(_ json:[String: Any], withID id: String) -> Item {
        let json = JSON(json)

        let name = json[id]["name"].stringValue
        
        var categories = [String]()
        for category in json[id]["categories"].dictionaryValue.keys {
            categories.append(category)
        }
        
        var images = [String]()
        for image in json[id]["images"].arrayValue {
            images.append(image.stringValue)
        }
        
        return Item(id: id, name: name, categories: categories, images: images)
    }
}

//
//  TaskModel.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import Foundation
import RealmSwift

class TaskModel: Object {
    
    dynamic var id = 0
    dynamic var folderId = 0
    dynamic var title = ""
    dynamic var createDate = Date()
    dynamic var updateDate = Date()
    
    override static func primaryKey() -> String? {
        return "id"
        
    }
    
}

extension TaskModel: NSCopying {
    
    func copy(with zone:  NSZone?) -> Any {
        let copyObject = TaskModel()
        copyObject.id = id
        copyObject.folderId = folderId
        copyObject.title = title
        copyObject.createDate = createDate
        copyObject.updateDate = updateDate
        
        return copyObject
    }
}

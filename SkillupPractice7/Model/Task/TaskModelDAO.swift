//
//  TaskModelDAO.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import Foundation
import RealmSwift

final class TaskModelDAO {
    
    static let dao = RealmDaoHelper<TaskModel>()
    
    static func add(model: TaskModel) {
        
        let object = TaskModel()
        object.id = TaskModelDAO.dao.newId()!
        object.folderId = model.folderId
        object.title = model.title
        object.createDate = model.createDate
        object.updateDate = model.updateDate
        
        TaskModelDAO.dao.add(d: object)
    }
    
    static func update(model: TaskModel) {
        
        guard let object = dao.findFirst(key: model.id as AnyObject) else {
            return
        }
        
        
        _ = dao.update(d: object,block:{() -> Void in
            object.title = model.title
            object.updateDate = model.updateDate
        })
        
        
    }
    
    static func delete(id: Int) {
        
        guard let object = dao.findFirst(key: id as AnyObject) else {
            return
        }
        dao.delete(d: object)
    }
    
    static func deleteAll() {
        dao.deleteAll()
    }
    
    static func findByID(id: Int) -> TaskModel? {
        guard let object = dao.findFirst(key: id as AnyObject) else {
            return nil
        }
        return object
    }
    
    static func findFilter(predicate: NSPredicate) -> [TaskModel]  {
        return dao.findFilter(predicate: predicate).map { TaskModel(value: $0) }
        
    }
    
    static func findAll() -> [TaskModel] {
        let objects =  TaskModelDAO.dao.findAll()
        return objects.map { TaskModel(value: $0) }
    }
}

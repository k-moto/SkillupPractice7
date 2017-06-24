//
//  FolderModelDAO.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import Foundation
import RealmSwift

final class FolderModelDAO {
    
    static let dao = RealmDaoHelper<FolderModel>()
    
    static func add(model: FolderModel) {
        
        let object = FolderModel()
        object.id = FolderModelDAO.dao.newId()!
        object.title = model.title
        object.createDate = model.createDate
        object.updateDate = model.updateDate
        
        FolderModelDAO.dao.add(d: object)
    }
    
    static func update(model: FolderModel) {
        
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
    
    static func findByID(id: Int) -> FolderModel? {
        guard let object = dao.findFirst(key: id as AnyObject) else {
            return nil
        }
        return object
    }
    
    static func findFilter(predicate: NSPredicate) -> [FolderModel]  {
        return dao.findFilter(predicate: predicate).map { FolderModel(value: $0) }

    }
    
    static func findAll() -> [FolderModel] {
        let objects =  FolderModelDAO.dao.findAll()
        return objects.map { FolderModel(value: $0) }
    }
}

//
//  TaskModelDAOTest.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import Foundation
import STV_Extensions
import XCTest
@testable import SkillupPractice7

class TaskModelDAOTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
        TaskModelDAO.deleteAll()
    }
    
    func testAdd(){
        let object = TaskModel()
        
        let createDate = "2016/01/01 10:00"
        let updateDate = "2016/01/01 18:30"
        let format = "yyyy/MM/dd HH:mm"
        
        object.id = 1
        object.title = "テストタイトル1"
        object.createDate = createDate.toDate(dateFormat: format)
        object.updateDate = updateDate.toDate(dateFormat: format)
        
        TaskModelDAO.add(model:object)
        
        verifyItem(id: 1, title: "テストタイトル1", createDateStr: createDate, updateDateStr: updateDate)
    }
    
    func testUpdate(){
        
        let object = TaskModel()
        
        let createDate = "2016/01/01 10:00"
        let updateDate = "2016/01/01 18:30"
        let format = "yyyy/MM/dd HH:mm"
        
        object.id = 1
        object.title = "テストタイトル1"
        object.createDate = createDate.toDate(dateFormat: format)
        object.updateDate = updateDate.toDate(dateFormat: format)
        
        TaskModelDAO.add(model:object)
        
        object.id = 1
        object.title = "テストタイトル2"
        object.updateDate = "2016/01/01 20:30".toDate(dateFormat: format)
        
        TaskModelDAO.update(model:object)
        
        verifyItem(id: 1, title: "テストタイトル2", createDateStr: createDate, updateDateStr: "2016/01/01 20:30")
    }
    
    func testDelete(){
        
        let object = TaskModel()
        
        let startTime = "2016/01/01 10:00"
        let endTime = "2016/01/01 18:30"
        let format = "yyyy/MM/dd HH:mm"
        
        object.id = 1
        object.title = "テストタイトル1"
        object.createDate = startTime.toDate(dateFormat: format)
        object.updateDate = endTime.toDate(dateFormat: format)
        
        TaskModelDAO.add(model:object)
        
        TaskModelDAO.delete(id: 1)
        
        verifyCount(count:0)
    }
    
    func testFindByID(){
        
        let object = TaskModel()
        
        let startTime = "2016/01/01 10:00"
        let endTime = "2016/01/01 18:30"
        let format = "yyyy/MM/dd HH:mm"
        
        object.id = 1
        object.title = "テストタイトル1"
        object.createDate = startTime.toDate(dateFormat: format)
        object.updateDate = endTime.toDate(dateFormat: format)
        
        TaskModelDAO.add(model:object)
        
        let result = TaskModelDAO.findByID(id: 1)
        
        XCTAssertEqual(result?.id, 1)
    }
    
    func testFindAll(){
        
        let tasks = [TaskModel(),TaskModel(),TaskModel()]
        
        _ = tasks.map {
            TaskModelDAO.add(model:$0)
        }
        
        verifyCount(count:3)
    }
    
    //MARK:-private method
    private func verifyItem(id: Int, title: String, createDateStr: String, updateDateStr: String) {
        
        let format = "yyyy/MM/dd HH:mm"
        
        let result = TaskModelDAO.findAll()
        
        XCTAssertEqual(result.first?.id, id)
        
        XCTAssertEqual(result.first?.title, title)
        
        XCTAssertEqual(result.first?.createDate.toStr(dateFormat: format), createDateStr)
        
        XCTAssertEqual(result.first?.updateDate.toStr(dateFormat: format), updateDateStr)
        
    }
    
    private func verifyCount(count: Int) {
        
        let result = TaskModelDAO.findAll()
        XCTAssertEqual(result.count, count)
    }
}

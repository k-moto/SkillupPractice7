//
//  TaskModelTest.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import Foundation
import XCTest
import STV_Extensions
@testable import SkillupPractice7

class TaskModelTest: XCTestCase {
    
    let item = TaskModel()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTaskModelDefault(){
        let format = "yyyy/MM/dd HH:mm"
        
        XCTAssertEqual(item.id, 0)
        XCTAssertEqual(item.title, "")
        XCTAssertEqual(item.createDate.toStr(dateFormat: format), Date().toStr(dateFormat: format))
        XCTAssertEqual(item.updateDate.toStr(dateFormat: format), Date().toStr(dateFormat: format))
        
    }
    
    func testTaskModel(){
        
        let createDate = "2016/01/01 10:00"
        let updateDate = "2016/01/01 18:30"
        let format = "yyyy/MM/dd HH:mm"
        
        item.id = 1
        item.title = "テストタイトル1"
        item.createDate = createDate.toDate(dateFormat: format)
        item.updateDate = updateDate.toDate(dateFormat: format)
        
        XCTAssertEqual(item.id, 1)
        XCTAssertEqual(item.title, "テストタイトル1")
        XCTAssertEqual(item.createDate.toStr(dateFormat: format),createDate)
        XCTAssertEqual(item.updateDate.toStr(dateFormat: format),updateDate)
        
    }
}

//
//  TaskViewCellTest.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import Foundation
import XCTest
import STV_Extensions
@testable import SkillupPractice7

class TaskViewCellTest: XCTestCase {
    
    var tableView: UITableView!
    let dataSource = FakeDataSource()
    var cell: TaskViewCell!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Task", bundle: nil)
        let controller = storyboard
            .instantiateViewController(
                withIdentifier: "TaskViewController")
            as! TaskViewController
        
        _ = controller.view
        
        tableView = controller.taskTable
        tableView?.dataSource = dataSource
        
        cell = tableView?.dequeueReusableCell(
            withIdentifier: "TaskViewCell",
            for: IndexPath(row: 0, section: 0)) as! TaskViewCell
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
    
    func testSetNameLabel(){
        
        let updateDate = "2016/01/01 18:30"
        let format = "yyyy/MM/dd HH:mm"
        
        let task = TaskModel()
        task.title = "タスクタイトル"
        task.updateDate = updateDate.toDate(dateFormat: format)
        
        cell.task = task
        
        XCTAssertEqual(cell.taskName.text, "タスクタイトル")
        
    }
    
    func testSetDateLabel(){
        
        let updateDate = "2016/01/01 18:30"
        let format = "yyyy/MM/dd HH:mm"
        
        let task = TaskModel()
        task.title = "タスクタイトル"
        task.updateDate = updateDate.toDate(dateFormat: format)
        
        cell.task = task
        
        XCTAssertEqual(cell.taskDate.text, "2016/01/01")
        
    }
    
}

extension TaskViewCellTest {
    
    class FakeDataSource: NSObject, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
    }
}

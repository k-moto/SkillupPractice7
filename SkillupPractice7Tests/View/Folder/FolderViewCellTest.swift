//
//  FolderViewCellTest.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import Foundation
import XCTest
import STV_Extensions
@testable import SkillupPractice7

class FolderViewCellTest: XCTestCase {
    
    var tableView: UITableView!
    let dataSource = FakeDataSource()
    var cell: FolderViewCell!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Folder", bundle: nil)
        let controller = storyboard
            .instantiateViewController(
                withIdentifier: "FolderViewController")
            as! FolderViewController
        
        _ = controller.view
        
        tableView = controller.folderTable
        tableView?.dataSource = dataSource
        
        cell = tableView?.dequeueReusableCell(
            withIdentifier: "FolderViewCell",
            for: IndexPath(row: 0, section: 0)) as! FolderViewCell
    }
    
    override func tearDown() {
        super.tearDown()
        TaskModelDAO.deleteAll()
        
    }
    
    func testSetNameLabel(){
        let folder = FolderModel()
        folder.title = "フォルダタイトル"
        
        cell.folder = folder
        
        XCTAssertEqual(cell.folderName.text, "フォルダタイトル")
        
    }
    
    func testSetTaskCountLabelZero(){
        let folder = FolderModel()
        folder.title = "フォルダタイトル"
        
        cell.folder = folder
        
        XCTAssertEqual(cell.taskCount.text, "0")
        
    }
    
    func testSetTaskCountLabel(){
        
        let dummyFolderId = 50000
        
        let folder = FolderModel()
        folder.id = dummyFolderId
        folder.title = "フォルダタイトル"
        
        let object = TaskModel()
        
        let createDate = "2016/01/01 10:00"
        let updateDate = "2016/01/01 18:30"
        let format = "yyyy/MM/dd HH:mm"
        
        object.id = 1
        object.folderId = dummyFolderId
        object.title = "テストタスク1"
        object.createDate = createDate.toDate(dateFormat: format)
        object.updateDate = updateDate.toDate(dateFormat: format)
        
        TaskModelDAO.add(model:object)
        
        object.id = 2
        object.folderId = dummyFolderId
        object.title = "テストタスク2"
        object.createDate = createDate.toDate(dateFormat: format)
        object.updateDate = updateDate.toDate(dateFormat: format)
        
        TaskModelDAO.add(model:object)
        
        cell.folder = folder
        
        XCTAssertEqual(cell.taskCount.text, "2")
        
    }
    
}

extension FolderViewCellTest {
    
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

//
//  TaskList.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

//
//  FolderList.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import UIKit
import STV_Extensions

class TaskList: NSObject, UITableViewDataSource {
    
    var dataList: [TaskModel] = []
    
    func add(dataList: [TaskModel]){
        self.dataList = dataList
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskViewCell.identifier,for: indexPath) as! TaskViewCell
        
        cell.task = dataList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        TaskModelDAO.delete(id: dataList[indexPath.row].id)
        dataList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
    }
    
    
}

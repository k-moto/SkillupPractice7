//
//  FolderList.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import UIKit
import STV_Extensions

class FolderList: NSObject, UITableViewDataSource {

    var dataList: [FolderModel] = []
    
    func add(dataList: [FolderModel]){
        self.dataList = dataList
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FolderViewCell.identifier,for: indexPath) as! FolderViewCell
        
        cell.folder = dataList[indexPath.row]
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        FolderModelDAO.delete(id: dataList[indexPath.row].id)
        dataList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
    }


}

//
//  TaskViewCell.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//


import UIKit

final class TaskViewCell: UITableViewCell {
    
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var taskDate: UILabel!
    
    
    static var identifier: String {
        get {
            return String(describing: self)
        }
    }
    
    var task: TaskModel? {
        didSet {
            taskName.text = task?.title
            taskDate.text = task?.updateDate.toStr(dateFormat: "yyyy/MM/dd")
            
        }
    }
}

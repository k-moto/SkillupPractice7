//
//  FolderViewCell.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import UIKit

final class FolderViewCell: UITableViewCell {
    
    @IBOutlet weak var folderName: UILabel!
    @IBOutlet weak var taskCount: UILabel!
    
    
    static var identifier: String {
        get {
            return String(describing: self)
        }
    }
    
    var folder: FolderModel? {
        didSet {
            folderName.text = folder?.title
            
            let predicate = NSPredicate(format: "folderId == %d", folder?.id ?? 0)
            let taskDataCount = TaskModelDAO.findFilter(predicate: predicate).count
            taskCount.text = taskDataCount.description
            
        }
    }
    
}

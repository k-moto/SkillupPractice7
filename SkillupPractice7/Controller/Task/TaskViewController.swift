//
//  TaskViewController.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import Foundation

import UIKit

class TaskViewController: UIViewController {
    
    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var addTask: UIBarButtonItem!
    
    var selectFolderId: Int!
    var folderName: String!
    
    let taskList = TaskList()
    var taskData: [TaskModel] = []
    var saveButton: UIAlertAction?
    
    
    let center = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTable.dataSource = taskList
        taskTable.delegate = self
        
        self.navigationItem.title = folderName
        self.navigationItem.rightBarButtonItem = editButtonItem
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadTableData()
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        addTask.title =  editing ? "すべて削除" : "タスク追加"
        taskTable.setEditing(editing, animated: animated)
        
    }
    
    fileprivate func reloadTableData(){
        let predicate = NSPredicate(format: "folderId == %d", selectFolderId)
        taskData = TaskModelDAO.findFilter(predicate: predicate).sorted(by: { $0.updateDate > $1.updateDate })
        taskList.add(dataList: taskData)
        taskTable.reloadData()
        
    }
    
    fileprivate func updeteFolderDate(){
        if let folderModel = FolderModelDAO.findByID(id: selectFolderId)?.copy() as? FolderModel {
            folderModel.updateDate = Date()
            FolderModelDAO.update(model: folderModel)
        }
    }
    
    @IBAction func pushAddTask(_ sender: UIBarButtonItem) {
        
        if taskTable.isEditing {
            let actionSheet = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet)
            
            
            actionSheet.addAction(UIAlertAction(title: "すべて削除", style: .destructive, handler: { action in
                for task in self.taskData {
                    TaskModelDAO.delete(id: task.id)
                    self.taskList.add(dataList: [])
                    self.taskTable.reloadData()
                    
                }
            }))
            
            actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
            self.present(actionSheet, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(
                title: nil,
                message: "このタスクの名前を入力してください。",
                preferredStyle: .alert)
            
            saveButton = UIAlertAction(title: "保存", style: .default, handler: { action in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                if textFields != nil {
                    for textField:UITextField in textFields! {
                        let taskModel = TaskModel()
                        taskModel.folderId = self.selectFolderId
                        taskModel.title = textField.text!
                        taskModel.createDate = Date()
                        taskModel.updateDate = Date()
                        
                        TaskModelDAO.add(model: taskModel)
                        
                        self.updeteFolderDate()
                        
                    }
                }
                self.reloadTableData()
                self.center.removeObserver(self,
                                           name: .UITextFieldTextDidChange,
                                           object: nil)
                
            })
            saveButton?.isEnabled = false
            alert.addAction(saveButton!)
            
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: {
                action in
                self.center.removeObserver(self,
                                           name: .UITextFieldTextDidChange,
                                           object: nil)
            }))
            
            alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                text.placeholder = "このタスクの名前を入力してください。"
            })
            
            center.addObserver(self, selector: #selector(alertTextChange), name: .UITextFieldTextDidChange, object: alert.textFields?[0])
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    @objc fileprivate func alertTextChange(notification: NSNotification){
        let textFieldString = notification.object as! UITextField
        guard let inputText = textFieldString.text else {
            return
        }
        
        saveButton?.isEnabled = inputText.characters.count > 0
        
    }
    
}

extension TaskViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO　編集モードのみ編集
        if tableView.isEditing {
            let alert = UIAlertController(
                title: nil,
                message: "このタスクの新しい名前を入力してください。",
                preferredStyle: .alert)
            
            
            saveButton = UIAlertAction(title: "保存", style: .default, handler: { action in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                if textFields != nil {
                    for textField:UITextField in textFields! {
                        if let taskModel = TaskModelDAO.findByID(id: self.taskData[indexPath.row].id)?.copy() as? TaskModel {
                            taskModel.folderId = self.selectFolderId
                            taskModel.title = textField.text!
                            taskModel.updateDate = Date()
                            
                            TaskModelDAO.update(model: taskModel)
                            self.updeteFolderDate()
                        }
                    }
                }
                
                self.reloadTableData()
                self.center.removeObserver(self,
                                           name: .UITextFieldTextDidChange,
                                           object: nil)
            })
            
            alert.addAction(saveButton!)
            
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: {
                action in
                self.center.removeObserver(self,
                                           name: .UITextFieldTextDidChange,
                                           object: nil)
            }))
            
            alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                text.placeholder = "このタスクの新しい名前を入力してください。"
                text.text = self.taskData[indexPath.row].title
            })
            
            center.addObserver(self, selector: #selector(alertTextChange), name: .UITextFieldTextDidChange, object: alert.textFields?[0])
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
}

//
//  FolderViewController.swift
//  SkillupPractice7
//
//  Created by k_motoyama on 2017/06/24.
//  Copyright © 2017年 k_moto. All rights reserved.
//

import UIKit

class FolderViewController: UIViewController {
    
    @IBOutlet weak var folderTable: UITableView!
    @IBOutlet weak var addFolderButton: UIBarButtonItem!
    
    let folderList = FolderList()
    var folderData: [FolderModel] = []
    var saveButton: UIAlertAction?
    let center = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        folderTable.dataSource = folderList
        folderTable.delegate = self
        
        self.navigationItem.title = "メモ"
        self.navigationItem.rightBarButtonItem = editButtonItem
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTableData()
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        addFolderButton.title =  editing ? "すべて削除" : "新規フォルダ"
        folderTable.setEditing(editing, animated: animated)
        
    }
    
    fileprivate func reloadTableData() {
        folderData = FolderModelDAO.findAll().sorted(by: { $0.updateDate > $1.updateDate })
        folderList.add(dataList: folderData)
        folderTable.reloadData()
        
    }
    
    @IBAction func pushAddFolder(_ sender: UIBarButtonItem) {
        
        if folderTable.isEditing {
            let actionSheet = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet)
            
            
            actionSheet.addAction(UIAlertAction(title: "すべて削除", style: .destructive, handler: { action in
                FolderModelDAO.deleteAll()
                self.folderList.add(dataList: [])
                self.folderTable.reloadData()
                TaskModelDAO.deleteAll()
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
            
            self.present(actionSheet, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(
                title: nil,
                message: "このフォルダの名前を入力してください。",
                preferredStyle: .alert)
            
            saveButton = UIAlertAction(title: "保存", style: .default, handler: { action in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                if textFields != nil {
                    for textField:UITextField in textFields! {
                        let folderModel = FolderModel()
                        folderModel.title = textField.text!
                        folderModel.createDate = Date()
                        folderModel.updateDate = Date()
                        
                        FolderModelDAO.add(model: folderModel)
                        
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
                text.placeholder = "このフォルダの名前を入力してください。"
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

extension FolderViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing {
            let alert = UIAlertController(
                title: nil,
                message: "このフォルダの新しい名前を入力してください。",
                preferredStyle: .alert)
            
            saveButton = UIAlertAction(title: "保存", style: .default, handler: { action in
                let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                if textFields != nil {
                    for textField:UITextField in textFields! {
                        
                        if let folderModel = FolderModelDAO.findByID(id: self.folderData[indexPath.row].id)?.copy() as? FolderModel {
                            folderModel.title = textField.text!
                            folderModel.createDate = Date()
                            folderModel.updateDate = Date()
                            
                            FolderModelDAO.update(model: folderModel)
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
                text.placeholder = "このフォルダの新しい名前を入力してください。"
                text.text = self.folderData[indexPath.row].title
            })
            
            center.addObserver(self, selector: #selector(alertTextChange), name: .UITextFieldTextDidChange, object: alert.textFields?[0])
            
            self.present(alert, animated: true, completion: nil)
            
            
        } else {
            let task = UIStoryboard.viewController(storyboardName: "Task", identifier: "TaskViewController") as! TaskViewController
            
            let selectData = folderData[indexPath.row]
            task.selectFolderId = selectData.id
            task.folderName = selectData.title
            
            self.navigationController?.pushViewController(task, animated: true)
            
        }
    }
    
    
}

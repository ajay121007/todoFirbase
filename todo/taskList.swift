//
//  taskList.swift
//  todo
//
//  Created by Appzorro on 05/06/19.
//  Copyright © 2019 Appzorro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class taskList: UIViewController {
    var ref: DatabaseReference!
    var databaseHandle : DatabaseHandle!

    @IBOutlet var taskTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

      //  ref = Database.database().reference()
        ref = Database.database().reference()
        
        
       
    }
    override func viewWillAppear(_ animated: Bool) {
        

        
        // Chacke Firebace Connection
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                taskDataList.removeAll()
                self.addFirBaseObserve()
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    if let taskS = UserDefaults.standard.value(forKey: "taskList")
                    {
                        taskDataList = taskS as! [NSDictionary]
                        self.taskTable.reloadData()
                    }
                    
                })
            }
        })
      
     
        
        
        
      
    
    }
    
    func addFirBaseObserve()
    {
        
        
        //observe for new task add
        databaseHandle = ref.child("task").observe(.childAdded, with: { (dataAdd) in
            let name : String = (dataAdd.value as? String ?? "")
            let key : String = (dataAdd.key as? String ?? "")
            debugPrint(key)
            debugPrint(name)
            let dic =  ["Id":key,"Task":name]
            
            taskDataList.append(dic as NSDictionary)
            self.taskTable.reloadData()
            
            
        })
        
        //observe for task edit
        databaseHandle = ref.child("task").observe(.childChanged, with: { (dataAdd) in
            let name : String = (dataAdd.value as? String ?? "")
            let key : String = (dataAdd.key as? String ?? "")
            debugPrint(key)
            debugPrint(name)
            let dic =  ["Id":key,"Task":name]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                taskDataList.append(dic as NSDictionary)
                self.taskTable.reloadData()
            })
            
        })
    }
  
    @IBAction func addNewTask(_ sender: Any) {
        
        
        let alertController = UIAlertController(title:"New Task", message: "Writer a task Description", preferredStyle:.alert)
        let Action = UIAlertAction.init(title: "Ok", style: .default) { (UIAlertAction) in
            self.ref.child("task").childByAutoId().setValue(alertController.textFields?.first?.text)
            }
        alertController.addTextField { (fild) in
            fild.placeholder = "task data"
        }
        alertController.addAction(Action)
        self.present(alertController, animated: true, completion: nil)
        
    }
}
extension taskList : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = taskDataList[indexPath.row].value(forKey: "Task") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        
        let Delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, index) in
            let alertView = UIAlertController(title: "Delete Action", message: "", preferredStyle: UIAlertController.Style.alert)
            alertView.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action) in
                debugPrint("delete action")
                let id = taskDataList[indexPath.row].value(forKey: "Id")as! String
                let updateRef = Database.database().reference().child("task").child(id)
                updateRef.removeValue(completionBlock: { (error, updateRef) in
                    if error == nil{
                        let idx = taskDataList.firstIndex(of: taskDataList[indexPath.row])!
                        taskDataList.remove(at: idx)
                        self.taskTable.reloadData()
                    }
                })
                
               }))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
        }
        let edit = UITableViewRowAction(style: .destructive, title: "Edit") { (action, index) in
            let alertView = UIAlertController(title: "Edit Action", message: "", preferredStyle: UIAlertController.Style.alert)
            alertView.addTextField(configurationHandler: { (textFeld) in
                textFeld.text = taskDataList[indexPath.row].value(forKey: "Task") as? String
            })
            alertView.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
                debugPrint("Edit action")
                let id = taskDataList[indexPath.row].value(forKey: "Id")as! String
                let updateRef = Database.database().reference().child("task")
                
               
                updateRef.updateChildValues([
                    "\(id)":"\(alertView.textFields?.first?.text ?? "")"], withCompletionBlock: { (error, updatRef) in
                        if error == nil
                        {
                            let idx = taskDataList.firstIndex(of: taskDataList[indexPath.row])!
                            taskDataList.remove(at: idx)
                            self.taskTable.reloadData()
                        }
                })
                
            }))
                
            
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
        }


        edit.backgroundColor = UIColor.blue

        return [Delete, edit]
    }
}
    


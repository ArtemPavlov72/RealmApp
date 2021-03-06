//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import RealmSwift

class TasksViewController: UITableViewController {
    
    var taskList: TaskList!
    
    private var currentTasks: Results<Task>! //текущие задачи
    private var completedTasks: Results<Task>! //выполненные задачи
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name //название заметки
        currentTasks = taskList.tasks.filter("isComplete = false") //сортируем на текущие задачи
        completedTasks = taskList.tasks.filter("isComplete = true") // сортируем на выполненые задачи
        
        //добавляем кнопку добавления
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add, //тип кнопки
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem] //добавляем кнопки добавления и редактирования в навигейшн бар
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count // если секция имеет значение индекса 0, то берем количество элементов из коллекции currentTasks, иначе из completedTasks
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS" // название секции
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name // название заметки в строке
        content.secondaryText = task.note //название текста заметки
        cell.contentConfiguration = content
        return cell
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    // MARK: - UITableViewDelegate
    
     /*   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let taskListVC = segue.destination as? TaskListViewController else { return }
        let currentTasks = currentTasks[indexPath.row]
            taskListVC.currentTasks = currentTasks
        
    } */
}
extension TasksViewController {
    
    private func showAlert() {
        
        let alert = AlertController.createAlert(withTitle: "New Task", andMessage: "What do you want to do?")
        
        alert.action { newValue, note in
            self.saveTask(withName: newValue, andNote: note)
        }
        
        present(alert, animated: true)
    }
    
    private func saveTask(withName name: String, andNote note: String) {
        let task = Task(value: [name, note]) //создаем экземпляр модели Task и передадим туда значения name и note (название и текст заметки)
        StorageManager.shared.save(task, to: taskList) //сохраняем экземпляр в базу
        let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0) //индекс по которому необходимо добавить строку
        tableView.insertRows(at: [rowIndex], with: .automatic) // обновляем визуально таблицу
    }
}


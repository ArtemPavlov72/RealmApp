//
//  TaskListsViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import RealmSwift
import UIKit

class TaskListViewController: UITableViewController {
    
    var currentTasks: Results<Task>!
    
    private var taskLists: Results<TaskList>! // Results - результаты коллекции TaskList
    //var taskList: TaskList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTempData() // заполняем примерами при первом запуске приложения
        taskLists = StorageManager.shared.realm.objects(TaskList.self) //делаем запрос из базы данных realm, и ищем объекты с типом TaskList
        
        //currentTasks = StorageManager.shared.realm.objects(Task.self)
        //currentTasks = taskList.tasks.filter("isComplete = false")
        
        navigationItem.leftBarButtonItem = editButtonItem // кнопка редактирования
    }
    // обновляем экран
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let taskList = taskLists[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = taskList.name
        content.secondaryText = "\(taskList.tasks.count)" //отображаем количество задач
        //content.secondaryText = "\(currentTasks.count)"//добавил
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - UITableViewDelegate
    // настраиваем свайп по строчке
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskList = taskLists[indexPath.row]
        
        //настраиваем удаление: destructive - красный тип кнопки, название Delete
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(taskList) //вызываем метод удаления из базы
            tableView.deleteRows(at: [indexPath], with: .automatic) //удаляем строчку
        }
        
        //настраиваем метод редактирования, последний объект ({_, _, isDone} - определяем в каком момент заканчиваем работу над пользовательским действием ячейки
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") {_, _, isDone in
            StorageManager.shared.done(taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        //красим кнопку редактирования в оранжевый
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return } //индекс строки на которую пользователь тапает
        guard let tasksVC = segue.destination as? TasksViewController else { return } // экземпляр вьюконтроллера на который переходим
        let taskList = taskLists[indexPath.row] // извлекаем из массива список по текущей строки
        tasksVC.taskList = taskList // передаем список на другой экран
    }

    @IBAction func  addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
    }
    
    
    
    private func createTempData() {
        DataManager.shared.createTempData {
            self.tableView.reloadData()
        }
    }
}

extension TaskListViewController {
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let alert = AlertController.createAlert(withTitle: "New List", andMessage: "Please insert new value")
        
        alert.action(with: taskList) { newValue in
            //если получилось извлечь taskList и completion
            if let taskList = taskList, let completion = completion {
                // то вызываем метод редактирования и передаем новое значение
                StorageManager.shared.edit(taskList, newValue: newValue)
                //вызываем completion, чтобы реализовать обновление интерфейса
                completion()
            } else {
                // иначе сохранение
                self.save(newValue)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(_ taskList: String) {
        let taskList = TaskList(value: [taskList]) //создаем экземпляр модели TaskList
        StorageManager.shared.save(taskList) // теперь сохраняем этот экземпляр в базе
        let rowIndex = IndexPath(row: taskLists.index(of: taskList) ?? 0, section: 0) //индекс по корому  нужно добавить строку
        tableView.insertRows(at: [rowIndex], with: .automatic) //добавляем строку с автоматической анимацией
    }
    
}

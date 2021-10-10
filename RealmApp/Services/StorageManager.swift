//
//  StorageManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 07.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    let realm = try! Realm()
    
    private init() {}
    
    // MARK: - TaskList
    //сохраняем списки, вызывается автоматически один раз, когда загружаем приложение
    func save(_ taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }
    
    //сохраняем новый список
    func save(_ taskList: TaskList) {
        write {
            realm.add(taskList)
        }
    }
    
    //удаление
    func delete(_ taskList: TaskList) {
        write {
            realm.delete(taskList.tasks) // сначала удаляем объекты из списков
            realm.delete(taskList) // потом удаляем уже сами списки, чтобы не копить в потерянные списки в базе
        }
    }
    
    //редактирование (вводим список, который редактируем и новое значение, которое будет ввозить пользователь)
    func edit(_ taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }
    
    //помечаем задачи как выполненные у списка
    func done(_ taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    // MARK: - Tasks
    //метод для добавления новой задачи в список
    func save(_ task: Task, to taskList: TaskList) {
        write {
            taskList.tasks.append(task) //список в который необходимо добавить задачу
        }
    }
    
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch let error {
            print(error)
        }
    }
}

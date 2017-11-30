//
//  HistoryViewController.swift
//  Awenew
//
//  Created by Иван on 28.04.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Ссылка на нашу таблицу
    @IBOutlet weak var tableWithHistory: UITableView!
    
    // Хранит массив с элементами таблицы
    var itemToShow = Int()
    
    // Массив словарей с предыдущими запросами
    var allItems = [[String: String]]()
    
    let currentHours = NSCalendar.current.component(.hour, from: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarTitleColor()
        
        // Загружаем все элементы
        allItems = FileProcessor.loadChecklistItems(key: "PreviousRequests")
        
        // Инициализируем tableViewHistory
        tableWithHistory.delegate = self
        tableWithHistory.dataSource = self
    }
    
    // Управляет количичеством секций в таблице
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Управляет количеством строк в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allItems.count
    }
    
    // Записывает в ячейки таблицы информацию
    func tableView(_ cellForRowAttableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableWithHistory.dequeueReusableCell(withIdentifier: "RequestItem", for: indexPath)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 60 / 255, green: 65 / 255, blue: 92 / 255, alpha: 1)
        cell.selectedBackgroundView = bgColorView
        
        let row = indexPath.row
        
        let dateLabel = cell.viewWithTag(1000) as! UILabel
        dateLabel.text = (allItems[row]["Date"])!
        
        let locationLabel = cell.viewWithTag(1001) as! UILabel
        locationLabel.text = "\((allItems[row]["City"])!) (\((allItems[row]["Latitude"])!), \((allItems[row]["Longitude"])!))"
        
        return cell
    }
    
    // Если сейчас осуществится переход по какому-либо segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMoreInfo" {
            // Получили доступ к MoreInfoViewController
            let controller = segue.destination as! MoreInfoViewController
            // Записали в переменную MoreInfoViewController-а numberOfItemToShow значение ячейки, которое нужно показать
            controller.numberOfItemToShow = itemToShow
        }
    }
    
    // Если коснулись какой-либо ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Проверяем, есть ли такая ячейка
        if tableWithHistory.cellForRow(at: indexPath) != nil {
            itemToShow = indexPath.row
            // Осуществляем переход в MoreInfoViewController
            self.performSegue(withIdentifier: "ShowMoreInfo", sender: self)
        }
        // Делаем данную ячейку невыбранной (обычного белого цвета)
        tableWithHistory.deselectRow(at: indexPath, animated: true)
        
    }
    

}

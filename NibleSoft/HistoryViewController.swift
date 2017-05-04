//
//  HistoryViewController.swift
//  NibleSoft
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
        
        // Загружаем все элементы
        allItems = FileProcessor.loadChecklistItems(key: "PreviousRequests")
        
        // Инициализируем tableViewHistory
        tableWithHistory.delegate = self
        tableWithHistory.dataSource = self
        
        if (currentHours > 20 || currentHours < 5) {
            self.tableWithHistory.backgroundColor = UIColor.init(red: 25.0/255.0, green: 25.0/255.0, blue: 112.0/255.0, alpha: 1)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let row = indexPath.row
        
        let dateLabel = cell.viewWithTag(1000) as! UILabel
        dateLabel.text = (allItems[row]["Date"])!
        
        let locationLabel = cell.viewWithTag(1001) as! UILabel
        locationLabel.text = "\((allItems[row]["City"])!)(\((allItems[row]["Latitude"])!), \((allItems[row]["Longitude"])!))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (currentHours < 20 || currentHours < 5) {
            cell.backgroundColor = UIColor.clear
            
            let dateLabel = cell.viewWithTag(1000) as! UILabel
            dateLabel.textColor = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 102.0/255.0, alpha: 1)
            
            let locationLabel = cell.viewWithTag(1001) as! UILabel
            locationLabel.textColor = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 102.0/255.0, alpha: 1)
            
        }
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


//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Tihomir Dimitrov on 2/14/18.
//  Copyright © 2018 Tihomir Dimitrov. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeTableViewController{

    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none
        
        tableView.rowHeight = 80.0
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        cell.textLabel?.text = categories[indexPath.row].name
        
        guard let categoryColor = UIColor(hexString : categories[indexPath.row].color!) else {fatalError()}
        
        cell.backgroundColor = categoryColor
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        
        return cell
    }
    
    //MARK: - TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error, \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
      
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
           categories = try context.fetch(request)
        } catch {
            print("Fetching error: \(error)")
        }

    }
    
    //MARK: - Delete data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        self.context.delete(self.categories[indexPath.row])
        self.categories.remove(at: indexPath.row)
        do {
            try self.context.save()
        } catch {
            print("Error, \(error)")
        }
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            
            self.categories.append(newCategory)
            
            self.saveCategories()

        }
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            textField.placeholder = "Add a new category"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}




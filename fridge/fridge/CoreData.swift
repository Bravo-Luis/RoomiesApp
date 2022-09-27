//
//  CoreData.swift
//  fridge
//
//  Created by Luis Bravo on 9/24/22.
//

import Foundation
import CoreData

class CoreDataViewModel : ObservableObject {
    
    @Published var fridge : [FoodItem] = []
    
    let container : NSPersistentContainer
    
    init(){
        container = NSPersistentContainer(name: "fridge")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error Loading Core Data. \(error)")
            }
        }
        fetchFridge()
    }
    
    func fetchFridge(){
        let request = NSFetchRequest<FoodItem>(entityName: "FoodItem")
        do {
            fridge = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching \(error)")
        }
    }
    
    func addFoodItem(name : String, status : String, location: String){
        let newFoodItem = FoodItem(context: container.viewContext)
        
        newFoodItem.name = name
        newFoodItem.status = status
        newFoodItem.location = location
        
        saveData()
        fetchFridge()
        
    }
    
    func saveData(){
        do {
            try container.viewContext.save()
            fetchFridge()
        } catch let error {
            print("Error Saving. \(error)")
        }
    }
    
    func deleteFoodItem(indexSet : IndexSet){
        guard let index = indexSet.first else {return}
        let foodItem = fridge[index]
        container.viewContext.delete(foodItem)
        saveData()
    }
    
    
    
}

//
//  LocalService.swift
//  AppStoreTest
//
//  Created by Juan Manuel Jimenez Sanchez on 15/02/17.
//  Copyright © 2017 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import Foundation
import CoreData

class LocalService {
    let remoteService = RemoteService()
    let coreDataStack = CoreDataStack.sharedInstance
    
    /**
     Consulta el WS por las categorías pero mientras tanto entrega las de Core Data, cuando obtiene las categorías del WS
     actualiza las de Core Data y luego retorta estas ya actualizadas.
     
     - parameters:
        - localHandler: entrega las categorías sin actualizar
        - remoteHandler: entrega las categorías ya actualizadas desde el WS
     */
    func getCategories(localHandler: ([CategoryApp]?) -> Void, remoteHandler: @escaping ([CategoryApp]?) -> Void) {
        
        //Obtenemos las categorías desde Core Data
        localHandler(self.queryCategories())
        
        //Obtenemos las categorías desde el WS (array de diccionarios)
        self.remoteService.getCategories { (categories) in
            if let categories = categories {
                //Marcamos todas las categorías en Core Data como: no sincronizadas
                self.markAllCategoriesAsUnsync()
                
                //Recorremos el arreglo de diccionarios (cada categoría quedará marcada como sincronizada)...
                for categoryDictionary in categories {
                    //Si la categoría no existía en Core Data entonces la creamos
                    if let category = self.getCategoryById(id: categoryDictionary["id"]!) {
                        self.updateCategory(categoryDictionary: categoryDictionary, category: category)
                    } else {
                        self.insertCategory(categoryDictionary: categoryDictionary)
                    }
                }
                //Ahora borramos las categorías no sincronizadas (estas son las categorías que pudieron haber salido del top)
                self.removeOldCategories()
                //Como ya actualizamos Core Data entonces devolvemos los datos de allí
                remoteHandler(self.queryCategories())
            } else {
                remoteHandler(nil)
            }
        }
    }
    
    /**
     Consulta a Core Data las categorías existentes
     
     - returns:
     Un array de categorías
     */
    func queryCategories() -> [CategoryApp]? {
        let context = coreDataStack.persistentContainer.viewContext
        let request: NSFetchRequest<CategoryApp> = CategoryApp.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let fechedCategories = try context.fetch(request)
            
            var categories: [CategoryApp] = [CategoryApp]()
            for category in fechedCategories {
                categories.append(category)
            }
            
            return categories
        } catch {
            print("Error obteniendo las categorías")
            return nil
        }
    }
    
    ///Marcamos todas las categorías en Core Data como: no sincronizadas
    func markAllCategoriesAsUnsync() {
        let context = coreDataStack.persistentContainer.viewContext
        let request: NSFetchRequest<CategoryApp> = CategoryApp.fetchRequest()
        
        do {
            let fetchedCategories = try context.fetch(request)
            
            for category in fetchedCategories {
                category.sync = false
            }
            
            try context.save()
        } catch {
            print("Error actualizando las categorías")
        }
    }

    ///Consultamos la categoría en Core Data
    func getCategoryById(id: String) -> CategoryApp? {
        let context = coreDataStack.persistentContainer.viewContext
        let request: NSFetchRequest<CategoryApp> = CategoryApp.fetchRequest()
        
        let predicate = NSPredicate(format: "id = \(id)")
        request.predicate = predicate
        
        do {
            let fetchedCategories = try context.fetch(request)
            if fetchedCategories.count > 0 {
                return fetchedCategories.last
            } else {
                return nil
            }
        } catch {
            print("Error obteniendo la categoría")
            return nil
        }
    }
    
    ///Insertamos la nueva categoría en Core Data
    func insertCategory(categoryDictionary: [String:String]) {
        let context = coreDataStack.persistentContainer.viewContext
        let category = CategoryApp(context: context)
        
        category.id = categoryDictionary["id"]
        category.title = categoryDictionary["title"]
        category.sync = true//Se marca como sincronizada porque las que no lo estén, deben ser eliminadas
        
        do {
            try context.save()
        } catch {
            print("Error mientras actualizabamos Core Data")
        }
    }
    
    ///Actualizamos la categoría en Core Data
    func updateCategory(categoryDictionary: [String:String], category: CategoryApp) {
        let context = coreDataStack.persistentContainer.viewContext
        
        category.title = categoryDictionary["title"]
        category.sync = true//Se marca como sincronizada porque las que no lo estén, deben ser eliminadas
        
        do {
            try context.save()
        } catch {
            print("Error mientras actualizabamos Core Data")
        }
    }
    
    ///Eliminamos todas las categorías que no estén sincronizadas (esto se da porque el listado de categorías va cambiando, unas entran, otra salen)
    func removeOldCategories() {
        let context = coreDataStack.persistentContainer.viewContext
        let request: NSFetchRequest<CategoryApp> = CategoryApp.fetchRequest()
        
        let predicate = NSPredicate(format: "sync = \(false)")
        request.predicate = predicate
        
        do {
            let fetchedCategories = try context.fetch(request)
            for category in fetchedCategories {
                context.delete(category)
            }
            
            try context.save()
        } catch {
            print("Error mientras borrabamos de Core Data")
        }
    }
}

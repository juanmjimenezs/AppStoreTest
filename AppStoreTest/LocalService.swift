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
    
    // MARK: - Categorías
    
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
                    //Si la categoría existe en Core Data entonces la actualizamos, sino entonces la creamos
                    if let category = self.getCategory(byId: categoryDictionary["id"]!) {
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
    func getCategory(byId id: String) -> CategoryApp? {
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
    
    // MARK: - Aplicaciones
    
    /**
     Consulta el WS por las apps pero mientras tanto entrega las apps almacenadas en Core Data, cuando obtiene las apps del WS
     actualiza las de Core Data y luego retorta estas ya actualizadas.
     
     - parameters:
        - byCategory: el id de la categoría de la que queremos obtener la lista de aplicaciones
        - localHandler: entrega las apps sin actualizar
        - remoteHandler: entrega las apps ya actualizadas desde el WS
     */
    func getApps(byCategory categoryId: String, localHandler: ([TopApp]?) -> Void, remoteHandler: @escaping ([TopApp]?) -> Void) {
        
        //Obtenemos las apps desde Core Data
        localHandler(self.queryApps(byCategory: categoryId))
        
        //Obtenemos las apps desde el WS (array de diccionarios)
        self.remoteService.getApps { (apps) in
            if let apps = apps {
                //Marcamos todas las apps en Core Data como: no sincronizadas
                self.markAllAppsAsUnsync()
                
                //Recorremos el arreglo de diccionarios (cada app quedará marcada como sincronizada)...
                for appDictionary in apps {
                    //Si la app existe en Core Data entonces la actualizamos, sino la creamos
                    if let app = self.getApp(byId: appDictionary["id"]!) {
                        self.updateApp(appDictionary: appDictionary, app: app)
                    } else {
                        self.insertApp(appDictionary: appDictionary)
                    }
                }
                //Ahora borramos las apps no sincronizadas (estas son las apps que pudieron haber salido del top)
                self.removeOldApps()
                //Como ya actualizamos Core Data entonces devolvemos los datos de allí
                remoteHandler(self.queryApps(byCategory: categoryId))
            } else {
                remoteHandler(nil)
            }
        }
    }
    
    /**
     Consulta a Core Data las apps de una categoría especifica

     - parameters:
        - byCategory: la categoría de la que queremos obtener la lista de aplicaciones

     - returns:
     Un array de TopApp
     */
    func queryApps(byCategory categoryId: String) -> [TopApp]? {
        let context = coreDataStack.persistentContainer.viewContext
        let request: NSFetchRequest<TopApp> = TopApp.fetchRequest()
        
        let predicate = NSPredicate(format: "categoryId = \(categoryId)")
        request.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let fechedApps = try context.fetch(request)
            
            var apps: [TopApp] = [TopApp]()
            for app in fechedApps {
                apps.append(app)
            }
            
            return apps
        } catch {
            print("Error obteniendo las apps")
            return nil
        }
    }
    
    ///Marcamos todas las aplicaciones en Core Data como: no sincronizadas
    func markAllAppsAsUnsync() {
        let context = coreDataStack.persistentContainer.viewContext
        let request: NSFetchRequest<TopApp> = TopApp.fetchRequest()
        
        do {
            let fechedApps = try context.fetch(request)
            
            for app in fechedApps {
                app.sync = false
            }
            
            try context.save()
        } catch {
            print("Error actualizando las apps")
        }
    }
    
    ///Consultamos la app en Core Data
    func getApp(byId id: String) -> TopApp? {
        let context = coreDataStack.persistentContainer.viewContext
        let request: NSFetchRequest<TopApp> = TopApp.fetchRequest()
        
        let predicate = NSPredicate(format: "id = \(id)")
        request.predicate = predicate
        
        do {
            let fetchedApps = try context.fetch(request)
            if fetchedApps.count > 0 {
                return fetchedApps.last
            } else {
                return nil
            }
        } catch {
            print("Error obteniendo la app")
            return nil
        }
    }
    
    ///Insertamos la nueva app en Core Data
    func insertApp(appDictionary: [String:String]) {
        let context = coreDataStack.persistentContainer.viewContext
        let app = TopApp(context: context)
        
        app.id = appDictionary["id"]
        self.updateApp(appDictionary: appDictionary, app: app)
    }
    
    ///Actualizamos la app en Core Data
    func updateApp(appDictionary: [String:String], app: TopApp) {
        let context = coreDataStack.persistentContainer.viewContext
        
        if let price = appDictionary["price"] {
            app.price = Float(price)!
        } else {
            app.price = 0.0
        }
        app.name = appDictionary["name"]
        app.company = appDictionary["company"]
        app.categoryId = appDictionary["categoryId"]
        app.releaseDate = appDictionary["releaseDate"]
        app.summary = appDictionary["summary"]
        app.link = appDictionary["link"]
        app.image = appDictionary["image"]
        app.sync = true//Se marca como sincronizada porque las que no lo estén, deben ser eliminadas
        
        do {
            try context.save()
        } catch {
            print("Error mientras actualizabamos Core Data")
        }
    }
    
    ///Eliminamos todas las apps que no estén sincronizadas (esto se da porque el listado de apps va cambiando, unas entran, otra salen)
    func removeOldApps() {
        let context = coreDataStack.persistentContainer.viewContext
        let request: NSFetchRequest<TopApp> = TopApp.fetchRequest()
        
        let predicate = NSPredicate(format: "sync = \(false)")
        request.predicate = predicate
        
        do {
            let fetchedApps = try context.fetch(request)
            for app in fetchedApps {
                context.delete(app)
            }
            
            try context.save()
        } catch {
            print("Error mientras borrabamos de Core Data")
        }
    }
}

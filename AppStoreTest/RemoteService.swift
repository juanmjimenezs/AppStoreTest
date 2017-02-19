//
//  RemoteService.swift
//  AppStoreTest
//
//  Created by Juan Manuel Jimenez Sanchez on 15/02/17.
//  Copyright © 2017 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RemoteService {
    
    let urlApps = "https://itunes.apple.com/us/rss/topfreeapplications/limit=100/json"
    
    /**
     Nos trae las categorías (no repetidas) que encuentre entre las apps del WS
     
     - parameters:
        - completionHandler: array de diccionarios con la información de cada categoría
     */
    func getCategories(completionHandler: @escaping ([[String:String]]?) -> Void) {
        let url = URL(string: self.urlApps)!
        
        Alamofire.request(url, method: .get).validate().responseJSON() { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    var result = [[String:String]]()//Listado de categorías
                    var uniqueIds = [String]()//Lista de id's de categoría para asegurarnos de no repetir una
                    
                    let entries = json["feed"]["entry"].arrayValue
                    
                    for entry in entries {
                        let id = entry["category"]["attributes"]["im:id"].stringValue
                        
                        //Agregamos la categoría solo si no existe en el array
                        if !uniqueIds.contains(id) {
                            var item = [String:String]()
                            
                            item["id"] = id
                            item["title"] = entry["category"]["attributes"]["label"].stringValue

                            uniqueIds.append(id)
                            result.append(item)
                        }
                        
                    }
                    
                    completionHandler(result)
                }
            case .failure(let error):
                print(error)
                completionHandler(nil)//Si hay un problema con el Internet o con el WS
            }
        }
    }
    
    /**
     Nos trae las apps del top 100
     
     - parameters:
     - completionHandler: array de diccionarios con la información de cada categoría
     */
    func getApps(completionHandler: @escaping ([[String:String]]?) -> Void) {
        let url = URL(string: self.urlApps)!
        
        Alamofire.request(url, method: .get).validate().responseJSON() { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    var result = [[String:String]]()//Listado de apps
                    
                    let entries = json["feed"]["entry"].arrayValue
                    
                    for entry in entries {
                        
                        var item = [String:String]()
                        
                        if let image = entry["im:image"].arrayValue.last {
                            item["image"] = image["label"].stringValue.replacingOccurrences(of: "100x100", with: "500x500")
                        }

                        item["id"] = entry["id"]["attributes"]["im:id"].stringValue
                        item["link"] = entry["id"]["label"].stringValue
                        item["name"] = entry["im:name"]["label"].stringValue
                        item["categoryId"] = entry["category"]["attributes"]["im:id"].stringValue
                        item["summary"] = entry["summary"]["label"].stringValue
                        item["price"] = entry["im:price"]["attributes"]["amount"].stringValue
                        item["company"] = entry["im:artist"]["label"].stringValue
                        item["releaseDate"] = entry["im:releaseDate"]["attributes"]["label"].stringValue
                        
                        
                        result.append(item)
                        
                    }
                    
                    completionHandler(result)
                }
            case .failure(let error):
                print(error)
                completionHandler(nil)//Si hay un problema con el Internet o con el WS
            }
        }
    }

}

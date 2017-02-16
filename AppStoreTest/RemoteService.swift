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
    
    /**
     Nos trae el top 100 de aplicaciones gratuitas de iTunes
     
     - parameters:
     - completionHandler: array de diccionarios con la información de cada categoría
     */
    func getTopApps(completionHandler: @escaping ([[String:String]]?) -> Void) {
        let url = URL(string: "https://itunes.apple.com/us/rss/topfreeapplications/limit=100/json")!
        
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
                completionHandler(nil)
            }
        }
    }

}

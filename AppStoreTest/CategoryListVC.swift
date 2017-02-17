//
//  CategoryListVC.swift
//  AppStoreTest
//
//  Created by Juan Manuel Jimenez Sanchez on 15/02/17.
//  Copyright © 2017 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import UIKit

class CategoryListVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var categoryList: [CategoryApp] = [CategoryApp]()
    let dataProvider = LocalService()
    let refresh = UIRefreshControl()
    let padding: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        //Cargamos la lista de categorías
        self.loadCategories()
        
        //Pull to refresh...
        self.refresh.addTarget(self, action: #selector(loadCategories), for: UIControlEvents.valueChanged)
        self.collectionView.refreshControl?.tintColor = UIColor.white
        self.collectionView.refreshControl = self.refresh
    }
    
    ///Primero cargamos la lista de Core Data y luego si descargamos datos del WS la volvemos a actualizar
    func loadCategories() {
        self.dataProvider.getCategories(localHandler: { (categories) in
            if let categories = categories {
                self.categoryList = categories
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }, remoteHandler: { (categories) in
            if let categories = categories {
                self.categoryList = categories
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.refresh.endRefreshing()
                }
            }
        })
    }
    
    ///Calculamos el ancho de la celda
    func cellSizeWidht() -> CGFloat {
        let screenWidth: CGFloat = self.view.frame.width
        var itemSize: CGFloat = screenWidth - self.padding * 2
        
        if screenWidth > 414 && screenWidth < 768 {
            itemSize = (screenWidth - self.padding * 4)/2
        } else if screenWidth >= 768 {
            itemSize = (screenWidth - self.padding * 6)/3
        }
        
        return itemSize
    }
    
    //Cuando se vaya a girar el dispositivo recargamos la collectionView para que redimensione correctamente las celdas
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CategoryListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        let currentCategory = self.categoryList[indexPath.row]
        
        cell.lblCategory.text = currentCategory.title
        
        return cell
    }
    
    //Configuramos el tamaño de la celda...
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.cellSizeWidht(), height: 50)
    }
    
    //Configuramos el pading entre celdas
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.padding, left: self.padding, bottom: self.padding, right: self.padding)
    }
    
    //Configuramos el padding entre filas
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.padding
    }
}

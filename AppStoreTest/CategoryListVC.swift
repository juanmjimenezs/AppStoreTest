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
    
    @IBAction func showInfo(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "The Author", message: "Juan Manuel Jiménez Sánchez built this app in approximately 25 hours.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
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
            } else {
                //Si no hay conexión...
                DispatchQueue.main.async {
                    let alertController = self.dataProvider.noInternetAlert()
                    self.present(alertController, animated: true, completion: { 
                        self.refresh.endRefreshing()
                    })
                }
            }
        })
    }
    
    /**
     Calculamos el ancho de la celda
     
     - returns:
     Retornamos el ancho que debe tener cada celda
     */
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AppList" {
            if let indexPathSelectedCell = self.collectionView.indexPathsForSelectedItems?.last {
                let appListVC = segue.destination as! AppListVC
                
                appListVC.category = self.categoryList[indexPathSelectedCell.row]
                
                //Así le quitamos el texto de "Back" al botón de la barra de navegación
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
            }
        }
    }

}

extension CategoryListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        let currentCategory = self.categoryList[indexPath.row]
        
        cell.lblCategory.text = currentCategory.title

        //Asi le damos una sombra muy bonita
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.layer.shadowOpacity = 0.6
        cell.layer.shadowRadius = 4.0
        cell.layer.masksToBounds = false
        
        return cell
    }
    
    //Configuramos el tamaño de la celda...
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.cellSizeWidht(), height: 80)
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

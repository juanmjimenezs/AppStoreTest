//
//  AppListVC.swift
//  AppStoreTest
//
//  Created by Juan Manuel Jimenez Sanchez on 17/02/17.
//  Copyright © 2017 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import UIKit
import Kingfisher

class AppListVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var category: CategoryApp = CategoryApp()
    var appList: [TopApp] = [TopApp]()
    let dataProvider = LocalService()
    let refresh = UIRefreshControl()
    let padding: CGFloat = 10

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        //Cargamos la lista de categorías
        self.loadApps()

        //Pull to refresh...
        self.refresh.addTarget(self, action: #selector(loadApps), for: UIControlEvents.valueChanged)
        self.collectionView.refreshControl?.tintColor = UIColor.white
        self.collectionView.refreshControl = self.refresh
        
        //Asignamos el titulo según la categoría en la que nos encontremos
        self.navigationItem.title = "Apps: \(self.category.title!)"
    }
    
    func loadApps() {
        self.dataProvider.getApps(byCategory: self.category.id!, localHandler: { (apps) in
            if let apps = apps {
                self.appList = apps
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }, remoteHandler: { (apps) in
            if let apps = apps {
                self.appList = apps
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

extension AppListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.appList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppCell", for: indexPath) as! AppCell
        
        let currentApp = self.appList[indexPath.row]
        
        if let imageUrl = currentApp.image {
            cell.imageView.kf.setImage(with: ImageResource(downloadURL: URL(string: imageUrl)!), placeholder: #imageLiteral(resourceName: "default-image"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        cell.lblAppName.text = currentApp.name
        cell.lblCompanyName.text = currentApp.company
        cell.lblPrice.text = String(format: "$%.02f", locale: Locale.current, arguments: [currentApp.price])
        cell.lblSummary.text = currentApp.summary?.replacingOccurrences(of: "\n", with: "")
        
        return cell
    }
    
    //Configuramos el tamaño de la celda...
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.cellSizeWidht(), height: 110)
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

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.loadCategories()
    }
    
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
                }
            }
        })
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

extension CategoryListVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        let currentCategory = self.categoryList[indexPath.row]
        
        cell.lblCategory.text = currentCategory.title
        
        return cell
    }
}

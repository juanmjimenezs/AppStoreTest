//
//  AppDetailVC.swift
//  AppStoreTest
//
//  Created by Juan Manuel Jimenez Sanchez on 17/02/17.
//  Copyright © 2017 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import UIKit
import Kingfisher

class AppDetailVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblReleaseDate: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var summary: UITextView!
    
    //Tanto el objeto con la app como el objeto de la categoría se cargan desde el prepare de la lista de apps
    var app: TopApp = TopApp()
    var category: CategoryApp = CategoryApp()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.app.name
        
        self.loadData()
    }

    //Asignamos todos los valores a los diferentes elementos de la interfaz
    func loadData() {
        
        if let imageUrl = self.app.image {
            self.imageView.kf.setImage(with: ImageResource(downloadURL: URL(string: imageUrl)!), placeholder: #imageLiteral(resourceName: "default-image"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        self.lblCompany.text = self.app.company
        self.lblReleaseDate.text = self.app.releaseDate
        self.lblCategory.text = self.category.title
        self.lblPrice.text = String(format: "$%.02f", locale: Locale.current, arguments: [self.app.price])
        self.summary.text = self.app.summary
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.summary.scrollRangeToVisible(NSMakeRange(0,0))
    }
}

//
//  AppListVC.swift
//  AppStoreTest
//
//  Created by Juan Manuel Jimenez Sanchez on 17/02/17.
//  Copyright © 2017 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import UIKit

class AppListVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //Así quitamos el texto del botón "Back" en la barra de navegación
        self.navigationController?.navigationBar.topItem?.title = ""
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

//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 8/31/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataManager = DataManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let navigationController = window?.rootViewController as! UINavigationController
        let vc = navigationController.topViewController as! MapViewController
        let vm = MapViewModel(fetcherDelegate: vc, dataManager: dataManager)
        vc.viewModel = vm
        return true
    }

}


//
//  AppDelegate.swift
//  CarouselListDemo
//
//  Created by Alexandra Homan
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)

        let networkService = NetworkService()
        let cacheService = ImageCacheService()
        let imageLoader = ImageLoader(networkService: networkService, cacheService: cacheService)
        let dataProvider = RemoteDataProvider(networkService: networkService)
        let presenter = MainPresenter()
        let interactor = MainInteractor(dataProvider: dataProvider, presenter: presenter)
        let mainVC = MainViewController(interactor: interactor, imageLoader: imageLoader)

        presenter.viewController = mainVC

        window.rootViewController = mainVC
        window.backgroundColor = .appBackground
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}

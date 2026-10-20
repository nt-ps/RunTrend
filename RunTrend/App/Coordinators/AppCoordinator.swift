import UIKit

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let container: DependencyContainer
    private let navigationController = UINavigationController()
    
    private let children = ChildCoordinators()

    init(window: UIWindow, container: DependencyContainer) {
        self.window = window
        self.container = container
    }

    func start() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([DashboardViewController()], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

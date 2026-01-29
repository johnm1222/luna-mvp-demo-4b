import SwiftUI

@main
struct FacebookSwiftUITemplateApp: App {
    init() {
        NavigationBarFontSetup.configure()
        TouchWindowSetup.shared.setup()
        
        // Permanently hide native tab bar since we use custom FDSTabBar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = .clear
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().isHidden = true
        
        // Permanently hide native navigation bar since we use custom FDS navigation bars
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = .clear
        navBarAppearance.shadowColor = .clear
        navBarAppearance.setBackIndicatorImage(UIImage(), transitionMaskImage: UIImage())
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().isHidden = true
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TodaysSnapshotScrollView()
            }
        }
    }
}

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
        
        // Hide navigation bar globally for all views
        navigationBar.isHidden = true
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Ensure navigation bar stays hidden throughout lifecycle
        navigationBar.isHidden = true
    }
}

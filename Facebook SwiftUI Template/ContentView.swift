import SwiftUI

// MARK: - Tab Router

class TabRouter: ObservableObject {
    @Published var selection: TabSelection = .home
}

enum TabSelection: String, CaseIterable, FDSTab {
    case home = "Home"
    case friends = "Friends"
    case reels = "Reels"
    case marketplace = "Marketplace"
    case notifications = "Notifications"
    case more = "More"
    
    var iconFilled: String {
        switch self {
        case .home: return "news-feed-home-filled"
        case .friends: return "friends-filled"
        case .reels: return "app-facebook-reels-filled"
        case .marketplace: return "marketplace-filled"
        case .notifications: return "notifications-filled"
        case .more: return "more-filled"
        }
    }
    
    var iconOutline: String {
        switch self {
        case .home: return "news-feed-home-outline"
        case .friends: return "friends-outline"
        case .reels: return "app-facebook-reels-outline"
        case .marketplace: return "marketplace-outline"
        case .notifications: return "notifications-outline"
        case .more: return "more-outline"
        }
    }
    
    var usesDarkTabBar: Bool {
        self == .reels
    }
}

struct ContentView: View {
    @StateObject private var tabRouter = TabRouter()
    
    var body: some View {
        FDSTabView(selection: $tabRouter.selection) { tab, tabHeight in
            switch tab {
            case .home:
                HomeTab(bottomPadding: tabHeight)
            case .friends:
                NavigationStack {
                    FriendsTab(bottomPadding: tabHeight)
                        .withNavigationDestinations(bottomPadding: tabHeight)
                }
            case .reels:
                NavigationStack {
                    ReelsTabView()
                        .withNavigationDestinations(bottomPadding: tabHeight)
                }
            case .marketplace:
                NavigationStack {
                    MarketplaceTabView(bottomPadding: tabHeight)
                        .withNavigationDestinations(bottomPadding: tabHeight)
                }
            case .notifications:
                NavigationStack {
                    NotificationsTab(bottomPadding: tabHeight)
                        .withNavigationDestinations(bottomPadding: tabHeight)
                }
            case .more:
                NavigationStack {
                    MoreTabView(bottomPadding: tabHeight)
                        .withNavigationDestinations(bottomPadding: tabHeight)
                }
            }
        }
        .environmentObject(tabRouter)
        .touchVisualizer()
    }
}

// MARK: - Navigation Modifier

struct NavigationDestinations: ViewModifier {
    let bottomPadding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: PostData.self) { post in
                PostPermalinkView(post: post)
            }
            .navigationDestination(for: String.self) { identifier in
                destinationView(for: identifier, bottomPadding: bottomPadding)
            }
            .navigationDestination(for: GroupNavigationValue.self) { groupNav in
                if let groupData = groupDataMap[groupNav.groupImage] {
                    GroupView(group: groupData)
                }
            }
    }
    
    @ViewBuilder
    private func destinationView(for identifier: String, bottomPadding: CGFloat) -> some View {
        if identifier.hasPrefix("nav:") {
            let destination = identifier.replacingOccurrences(of: "nav:", with: "")
            switch destination {
            case "groupsTab":
                GroupsTabView(bottomPadding: bottomPadding)
            case "friends":
                FriendsTab(bottomPadding: bottomPadding)
            case "marketplace":
                MarketplaceTabView(bottomPadding: bottomPadding)
            case "search":
                SearchView()
            case "prototypeSettings":
                PrototypeSettings()
            default:
                EmptyView()
            }
        } else {
            if let profileData = profileDataMap[identifier] {
                ProfileView(profile: profileData)
            }
        }
    }
}

extension View {
    func withNavigationDestinations(bottomPadding: CGFloat) -> some View {
        modifier(NavigationDestinations(bottomPadding: bottomPadding))
    }
    func apply<V: View>(@ViewBuilder transform: (Self) -> V) -> some View {
        transform(self)
    }
}

// MARK: Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

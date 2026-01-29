import SwiftUI

struct ProductItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let navigationValue: String?
    
    init(name: String, icon: String, navigationValue: String? = nil) {
        self.name = name
        self.icon = icon
        self.navigationValue = navigationValue
    }
}

struct MoreTabView: View {
    var bottomPadding: CGFloat = 0
    
    private let products = [
        ProductItem(name: "Groups", icon: "app-facebook-groups-outline", navigationValue: "nav:groupsTab"),
        ProductItem(name: "Events", icon: "calendar-star-outline"),
        ProductItem(name: "Memories", icon: "on-this-day-outline"),
        ProductItem(name: "Saved", icon: "bookmark-outline"),
        ProductItem(name: "Reels", icon: "app-facebook-reels-outline"),
        ProductItem(name: "Marketplace", icon: "marketplace-outline", navigationValue: "nav:marketplace"),
        ProductItem(name: "Friends", icon: "friends-outline", navigationValue: "nav:friends"),
        ProductItem(name: "Feeds", icon: "feeds-outline")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                navigationBar
                
                VStack(spacing: 12) {
                    profileCell
                    productGrid
                    seeMoreButton
                    settingsCells
                    prototypeSettingsButton
                    logOutButton
                }
                .padding(.top, 0)
                .padding(.bottom, bottomPadding + 12)
            }
        }
        .background(Color("surfaceBackground"))
    }
    
    private var navigationBar: some View {
        FDSNavigationBar(
            title: "Menu",
            icon1: {
                NavigationLink(value: "nav:search") {
                    Image("magnifying-glass-outline")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color("primaryIcon"))
                }
            },
            icon2: {
                FDSIconButton(icon: "app-messenger-outline", action: {})
            }
        )
    }
    
    private var profileCell: some View {
        NavigationLink(value: "profile1") {
            FDSListCell(
                headlineText: "Daniela Giménez",
                leftAddOn: .profilePhoto("profile1")
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var productGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ], spacing: 8) {
            ForEach(products) { product in
                FDSActionTile(
                    topAddOn: .icon(product.icon),
                    headline: product.name,
                    action: product.navigationValue == nil ? {} : nil,
                    navigationValue: product.navigationValue
                )
            }
        }
        .padding(.horizontal, 12)
    }
    
    private var seeMoreButton: some View {
        FDSButton(
            type: .secondary,
            label: "See more",
            size: .medium
        ) {
            // Action
        }
        .padding(.horizontal, 12)
    }
    
    private var settingsCells: some View {
        VStack(spacing: 0) {
            FDSListCell(
                headlineText: "Help & support",
                leftAddOn: .icon("comment-questions-outline", iconSize: 24),
                rightAddOn: .chevron,
                action: {}
            )
            
            FDSListCell(
                headlineText: "Settings & privacy",
                leftAddOn: .icon("settings-outline", iconSize: 24),
                rightAddOn: .chevron,
                action: {}
            )
            
            FDSListCell(
                headlineText: "Professional access",
                leftAddOn: .icon("more-shapes-outline", iconSize: 24),
                rightAddOn: .chevron,
                action: {}
            )
            
            FDSListCell(
                headlineText: "Also from Meta",
                leftAddOn: .icon("grid-9-outline", iconSize: 24),
                rightAddOn: .chevron,
                action: {}
            )
        }
    }
    
    private var prototypeSettingsButton: some View {
        FDSButton(
            type: .secondary,
            label: "Prototype settings",
            size: .medium,
            navigationValue: "nav:prototypeSettings"
        )
        .padding(.horizontal, 12)
    }
    
    private var logOutButton: some View {
        FDSButton(
            type: .secondary,
            label: "Log out",
            size: .medium
        ) {
            // Log out action
        }
        .padding(.horizontal, 12)
    }
}

#Preview {
    MoreTabView()
        .environmentObject(FDSTabBarHelper())
}

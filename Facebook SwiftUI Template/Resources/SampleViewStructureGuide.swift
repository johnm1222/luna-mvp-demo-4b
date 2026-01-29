import SwiftUI

// MARK: - View Structure Examples
// See .cursorrules for complete documentation on view patterns

// MARK: - Tab View Example

struct SampleTabView: View {
    var bottomPadding: CGFloat = 0
    @State private var selectedSubNavIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                FDSNavigationBar(
                    title: "Sample tab",
                    icon1: { FDSIconButton(icon: "plus-square-outline", action: {}) },
                    icon2: { FDSIconButton(icon: "profile-outline", action: {}) },
                    icon3: { FDSIconButton(icon: "magnifying-glass-outline", action: {}) }
                )
                
                FDSSubNavigationBar(
                    items: [
                        SubNavigationItem("For you"),
                        SubNavigationItem("Following"),
                        SubNavigationItem("Discover")
                    ],
                    selectedIndex: $selectedSubNavIndex
                )
                
                // Your content here
                FDSListCell(
                    hierarchyLevel: .level4,
                    headlineText: "Tap to see detail view example",
                    bodyText: "Shows navigation structure",
                    leftAddOn: .icon("square-dashed-outline", iconSize: 24),
                    rightAddOn: .chevron
                ) {
                    SampleDetailView()
                }
            }
            .padding(.bottom, bottomPadding)
        }
        .background(Color("surfaceBackground"))
    }
}

// MARK: - Detail View Example

struct SampleDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Detail view",
                backAction: { dismiss() },
                icon1: { FDSIconButton(icon: "share-outline", action: {}) },
                icon2: { FDSIconButton(icon: "bookmark-outline", action: {}) },
                icon3: { FDSIconButton(icon: "dots-3-horizontal-outline", action: {}) }
            )
            
            ScrollView {
                VStack(spacing: 0) {
                    // Your content here
                    Text("This is a detail view")
                        .headline2EmphasizedTypography()
                        .foregroundStyle(Color("primaryText"))
                        .padding()
                }
            }
            .background(Color("surfaceBackground"))
        }
        .hideFDSTabBar(true)
    }
}

// MARK: - Previews
#Preview("Tab View") {
    NavigationStack {
        SampleTabView()
    }
    .environmentObject(FDSTabBarHelper())
}

#Preview("Detail View") {
    NavigationStack {
        SampleDetailView()
    }
    .environmentObject(FDSTabBarHelper())
}


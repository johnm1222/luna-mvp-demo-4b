import SwiftUI

// MARK: - FDSNavigationBar (Original - Logo/Title + Icons)
struct FDSNavigationBar<Icon1: View, Icon2: View, Icon3: View>: View {
    // MARK: - Properties
    let title: String?
    let logoAction: (() -> Void)?
    let backAction: (() -> Void)?
    let onMedia: Bool
    let icon1: Icon1
    let icon2: Icon2
    let icon3: Icon3
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isPresented
    
    // MARK: - Initializer
    init(
        title: String? = nil,
        logoAction: (() -> Void)? = nil,
        backAction: (() -> Void)? = nil,
        onMedia: Bool = false,
        @ViewBuilder icon1: () -> Icon1 = { EmptyView() },
        @ViewBuilder icon2: () -> Icon2 = { EmptyView() },
        @ViewBuilder icon3: () -> Icon3 = { EmptyView() }
    ) {
        self.title = title
        self.logoAction = logoAction
        self.backAction = backAction
        self.onMedia = onMedia
        self.icon1 = icon1()
        self.icon2 = icon2()
        self.icon3 = icon3()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Auto-detect if we should show back button based on presentation context
            if isPresented {
                FDSIconButton(icon: "chevron-left-filled", onMedia: onMedia, action: {
                    if let backAction = backAction {
                        backAction()
                    } else {
                        dismiss()
                    }
                })
            }
            titleView
            Spacer()
            HStack(spacing: 20) {
                icon1
                icon2
                icon3
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
        .background(onMedia ? Color.clear : Color("surfaceBackground"))
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private var titleView: some View {
        if let title = title {
            Text(title)
                .headline0EmphasizedFBSansTypography()
                .foregroundStyle(onMedia ? Color("primaryTextOnMedia") : Color("primaryText"))
                .frame(height: 26, alignment: .leading)
                .if(onMedia) { view in
                    view.textOnMediaShadow()
                }
        } else {
            if let action = logoAction {
                Button(action: action) {
                    logoImage
                }
            } else {
                logoImage
            }
        }
    }
    
    private var logoImage: some View {
        Image("facebookLogo")
            .foregroundColor(onMedia ? Color("primaryIconOnMedia") : Color("logo"))
            .scaledToFit()
            .frame(width: 128, height: 24)
            .padding(.bottom, 2)
            .if(onMedia) { view in
                view.iconOnMediaShadow()
            }
    }
}

// MARK: - Convenience Initializer for Simple Icons
extension FDSNavigationBar where Icon1 == AnyView, Icon2 == AnyView, Icon3 == AnyView {
    init(
        title: String? = nil,
        logoAction: (() -> Void)? = nil,
        backAction: (() -> Void)? = nil,
        onMedia: Bool = false,
        icon1Name: String,
        icon1Action: @escaping () -> Void = {},
        icon2Name: String,
        icon2Action: @escaping () -> Void = {},
        icon3Name: String,
        icon3Action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.logoAction = logoAction
        self.backAction = backAction
        self.onMedia = onMedia
        // Navigation bars always use primaryIcon and size24
        self.icon1 = AnyView(FDSIconButton(icon: icon1Name, onMedia: onMedia, action: icon1Action))
        self.icon2 = AnyView(FDSIconButton(icon: icon2Name, onMedia: onMedia, action: icon2Action))
        self.icon3 = AnyView(FDSIconButton(icon: icon3Name, onMedia: onMedia, action: icon3Action))
    }
}

// MARK: - FDSNavigationBarCentered (Centered Title + Back Button + Icons)
struct FDSNavigationBarCentered<Icon1: View, Icon2: View, Icon3: View>: View {
    let title: String?
    let backAction: () -> Void
    let onMedia: Bool
    let icon1: Icon1
    let icon2: Icon2
    let icon3: Icon3
    
    init(
        title: String? = nil,
        backAction: @escaping () -> Void,
        onMedia: Bool = false,
        @ViewBuilder icon1: () -> Icon1 = { EmptyView() },
        @ViewBuilder icon2: () -> Icon2 = { EmptyView() },
        @ViewBuilder icon3: () -> Icon3 = { EmptyView() }
    ) {
        self.title = title
        self.backAction = backAction
        self.onMedia = onMedia
        self.icon1 = icon1()
        self.icon2 = icon2()
        self.icon3 = icon3()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Left section - back button
            FDSIconButton(icon: "chevron-left-filled", onMedia: onMedia, action: backAction)
            
            Spacer()
            
            // Right section - icons
            HStack(spacing: 20) {
                icon1
                icon2
                icon3
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
        .background(onMedia ? Color.clear : Color("surfaceBackground"))
        .overlay {
            // Title centered in the entire bar with constrained width
            if let title = title {
                HStack {
                    Spacer(minLength: 56) // Reserve space for left button
                    Text(title)
                        .headline3EmphasizedTypography()
                        .foregroundStyle(onMedia ? Color("primaryTextOnMedia") : Color("primaryText"))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity)
                        .if(onMedia) { view in
                            view.textOnMediaShadow()
                        }
                    Spacer(minLength: 56) // Reserve space for right icons
                }
                .padding(.horizontal, 12)
            }
        }
    }
}

// MARK: - FDSNavigationBarSearch (Back Button + Search Field)
struct FDSNavigationBarSearch: View {
    @Binding var searchText: String
    let placeholder: String
    @FocusState.Binding var isFocused: Bool
    let backAction: () -> Void
    let onMedia: Bool
    let onSubmit: () -> Void
    
    init(
        searchText: Binding<String>,
        placeholder: String = "Search",
        isFocused: FocusState<Bool>.Binding,
        backAction: @escaping () -> Void,
        onMedia: Bool = false,
        onSubmit: @escaping () -> Void = {}
    ) {
        self._searchText = searchText
        self.placeholder = placeholder
        self._isFocused = isFocused
        self.backAction = backAction
        self.onMedia = onMedia
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        HStack(spacing: 12) {
            FDSIconButton(icon: "chevron-left-filled", onMedia: onMedia, action: backAction)
            
            HStack(spacing: 6) {
                Image("magnifying-glass-outline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(onMedia ? Color("secondaryIconOnMedia") : Color("secondaryIcon"))
                
                TextField("", text: $searchText, prompt: Text(placeholder).foregroundStyle(onMedia ? Color("secondaryTextOnMedia") : Color("secondaryText")))
                    .body2Typography()
                    .foregroundStyle(onMedia ? Color("primaryTextOnMedia") : Color("primaryText"))
                    .tint(Color("logo"))
                    .keyboardType(.default)
                    .focused($isFocused)
                    .onSubmit {
                        onSubmit()
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(onMedia ? Color("inputBarBackgroundOnMedia") : Color("inputBarBackground"))
            .cornerRadius(25)
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
        .background(onMedia ? Color.clear : Color("surfaceBackground"))
    }
}

// MARK: - Helper Extension
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Navigation Bar Group Card Component
struct NavigationBarGroupCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .meta4LinkTypography()
                .foregroundStyle(Color("primaryText"))
                .padding(.horizontal, 12)
            
            content
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("cardBackground"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Navigation Bar Preview View
struct NavigationBarPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var subNavIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSNavigationBar",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    NavigationBarGroupCard(title: "Logo variant with icons") {
                        FDSNavigationBar(
                            icon1Name: "plus-square-outline",
                            icon2Name: "magnifying-glass-outline",
                            icon3Name: "app-messenger-outline",
                    )}
                    
                    NavigationBarGroupCard(title: "Text title variant") {
                        FDSNavigationBar(
                            title: "Marketplace",
                            icon1Name: "app-messenger-outline",
                            icon2Name: "profile-outline",
                            icon3Name: "magnifying-glass-outline"
                        )
                    }
                    
                    NavigationBarGroupCard(title: "Centered title with back button") {
                        FDSNavigationBarCentered(
                            title: "Profile settings",
                            backAction: {},
                            icon1: {
                                FDSIconButton(icon: "dots-3-horizontal-outline", action: {})
                            }
                        )
                    }
                    
                    NavigationBarGroupCard(title: "Centered title null (blank space)") {
                        FDSNavigationBarCentered(
                            backAction: {},
                            icon1: {
                                FDSIconButton(icon: "share-outline", action: {})
                            },
                            icon2: {
                                FDSIconButton(icon: "bookmark-outline", action: {})
                            },
                            icon3: {
                                FDSIconButton(icon: "dots-3-horizontal-outline", action: {})
                            }
                        )
                    }
                    
                    NavigationBarGroupCard(title: "Search variant") {
                        FDSNavigationBarSearch(
                            searchText: $searchText,
                            placeholder: "Search with Meta AI",
                            isFocused: $isSearchFocused,
                            backAction: {}
                        )
                    }
                    
                    NavigationBarGroupCard(title: "SubNavigation (composable with FDSSubNavigationBar)") {
                        HStack(alignment: .center, spacing: 12) {
                            FDSSubNavigationBar(
                                items: [
                                    SubNavigationItem("For you"),
                                    SubNavigationItem("Explore")
                                ],
                                selectedIndex: $subNavIndex
                            )
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                FDSIconButton(icon: "magnifying-glass-outline", action: {})
                                FDSIconButton(icon: "profile-outline", action: {})
                            }
                        }
                        .frame(height: 52)
                        .background(Color("surfaceBackground"))
                    }
                    
                    VStack(spacing: 0) {
                        Text("OnMedia variants")
                            .meta4LinkTypography()
                            .foregroundStyle(Color("primaryTextOnMedia"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .textOnMediaShadow()
                        
                        VStack(spacing: 12) {
                            FDSNavigationBar(
                                title: "Video",
                                onMedia: true,
                                icon1: {
                                    FDSIconButton(icon: "share-outline", onMedia: true, action: {})
                                }
                            )
                            
                            HStack(alignment: .center, spacing: 12) {
                                FDSSubNavigationBar(
                                    items: [
                                        SubNavigationItem("For you"),
                                        SubNavigationItem("Explore")
                                    ],
                                    selectedIndex: $subNavIndex,
                                    onMedia: true
                                )
                                
                                Spacer()
                                
                                HStack(spacing: 20) {
                                    FDSIconButton(icon: "magnifying-glass-outline", onMedia: true, action: {})
                                    FDSIconButton(icon: "profile-outline", onMedia: true, action: {})
                                }
                            }
                            .padding(.trailing, 12)
                            .frame(height: 52)
                        }
                    }
                    .padding(.bottom, 12)
                    .background(
                        ZStack {
                            Image("image3")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                            LinearGradient(
                                stops: [
                                    .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 0.0),
                                    .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.3),
                                    .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.7),
                                    .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    )
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationBarPreviewView()
}

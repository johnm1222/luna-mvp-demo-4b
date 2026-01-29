import SwiftUI

struct SubNavigationItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
}

enum SubNavigationStyle {
    case tabs
    case links
}

struct FDSSubNavigationBar: View {
    let items: [SubNavigationItem]
    let style: SubNavigationStyle
    @Binding var selectedIndex: Int
    let onSelectionChanged: ((Int) -> Void)?
    let onMedia: Bool
    
    // Tabs initializer (existing behavior)
    init(items: [SubNavigationItem], selectedIndex: Binding<Int>, onSelectionChanged: ((Int) -> Void)? = nil, onMedia: Bool = false) {
        self.items = items
        self.style = .tabs
        self._selectedIndex = selectedIndex
        self.onSelectionChanged = onSelectionChanged
        self.onMedia = onMedia
    }
    
    // Links initializer (new variant)
    init(items: [SubNavigationItem], style: SubNavigationStyle = .links, onItemTapped: ((Int) -> Void)? = nil, onMedia: Bool = false) {
        self.items = items
        self.style = style
        self._selectedIndex = .constant(0) // Not used for links
        self.onSelectionChanged = onItemTapped
        self.onMedia = onMedia
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: style == .links ? 8 : 0) {
                ForEach(items.indices, id: \.self) { index in
                    Button {
                        if style == .tabs {
                            withAnimation(.swapShuffleIn(MotionDuration.extraShortIn)) {
                                selectedIndex = index
                            }
                        }
                        onSelectionChanged?(index)
                    } label: {
                        Group {
                            Text(items[index].title)
                                .body3LinkTypography()
                                .padding(.horizontal, 12)
                                .frame(height: 36)
                                .background {
                                    Group {
                                        switch style {
                                        case .tabs:
                                            if selectedIndex == index {
                                                if onMedia {
                                                    if #available(iOS 26.0, *), GlassEffectSettings.shared.isEnabled {
                                                        Capsule()
                                                            .fill(.clear)
                                                            .glassEffect(.clear, in: .capsule(style: .continuous))
                                                    } else {
                                                        Capsule()
                                                            .fill(.thinMaterial)
                                                            .colorScheme(.dark)
                                                    }
                                                } else {
                                                    Capsule()
                                                        .fill(Color("primaryDeemphasizedButtonBackground"))
                                                }
                                            } else {
                                                Capsule()
                                                    .fill(.clear)
                                            }
                                        case .links:
                                            Capsule()
                                                .fill(onMedia ? Color("secondaryButtonBackgroundOnMedia") : Color("secondaryButtonBackground"))
                                        }
                                    }
                                }
                                .foregroundStyle(
                                    style == .tabs
                                        ? (selectedIndex == index 
                                            ? (onMedia ? Color("secondaryButtonTextOnMedia") : Color("primaryDeemphasizedButtonText"))
                                            : (onMedia ? Color("primaryTextOnMedia") : Color("primaryText")))
                                        : (onMedia ? Color("secondaryButtonTextOnMedia") : Color("secondaryButtonText"))
                                )
                        }
                        .if(style == .tabs && onMedia && selectedIndex != index) { view in
                            view.textOnMediaShadow()
                        }
                        .if(style == .links && onMedia) { view in
                            view.textOnMediaShadow()
                        }
                    }
                    .buttonStyle(FDSPressedState(cornerRadius: 9999, isOnMedia: onMedia, scale: .medium))
                }
            }
            .padding(.horizontal, 12)
        }
    }
}


// MARK: - Navigation Group Card Component
struct NavigationGroupCard<Content: View>: View {
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
                .padding(.top, 12)
            
            content
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("cardBackground"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct SubNavigationBarPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex1 = 0
    @State private var selectedIndex2 = 0
    @State private var selectedIndex3 = 0
    @State private var selectedIndex4 = 0
    @State private var callbackMessage = "Posts selected"
    @State private var linkTappedMessage = "Tap a link"
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSSubNavigationBar",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    NavigationGroupCard(title: "Standard navigation") {
                        let items = [
                            SubNavigationItem("Overview"),
                            SubNavigationItem("Data"),
                            SubNavigationItem("Graphs"),
                            SubNavigationItem("Settings")
                        ]
                        
                        FDSSubNavigationBar(items: items, selectedIndex: $selectedIndex1)
                    }
                    
                    NavigationGroupCard(title: "With callback action") {
                        let items = [
                            SubNavigationItem("Posts"),
                            SubNavigationItem("Photos"),
                            SubNavigationItem("Videos")
                        ]
                        
                        VStack(spacing: 12) {
                            FDSSubNavigationBar(items: items, selectedIndex: $selectedIndex2) { index in
                                withAnimation {
                                    callbackMessage = "\(items[index].title) selected"
                                }
                            }
                            
                            Text(callbackMessage)
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .transition(.asymmetric(
                                    insertion: .opacity.animation(.swapShuffleIn(MotionDuration.extraShortIn)),
                                    removal: .opacity.animation(.swapShuffleOut(MotionDuration.extraShortOut))
                                ))
                        }
                    }
                    
                    NavigationGroupCard(title: "Many items (scrollable)") {
                        let items = [
                            SubNavigationItem("Home"),
                            SubNavigationItem("Explore"),
                            SubNavigationItem("Notifications"),
                            SubNavigationItem("Messages"),
                            SubNavigationItem("Bookmarks"),
                            SubNavigationItem("Lists"),
                            SubNavigationItem("Profile"),
                            SubNavigationItem("Settings")
                        ]
                        
                        FDSSubNavigationBar(items: items, selectedIndex: $selectedIndex3)
                    }
                    
                    VStack(spacing: 0) {
                        Text("On media variant")
                            .meta4LinkTypography()
                            .foregroundStyle(Color("primaryTextOnMedia"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                        let items = [
                            SubNavigationItem("For you"),
                            SubNavigationItem("Explore")
                        ]
                        
                        FDSSubNavigationBar(items: items, selectedIndex: $selectedIndex4, onMedia: true)
                    }
                    .padding(.bottom, 12)
                    .background(
                        ZStack {
                            Image("image2")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                            Color("overlayOnMediaLight")
                        }
                        .allowsHitTesting(false)
                    )
                    .cornerRadius(12)
                    
                    NavigationGroupCard(title: "Links variant") {
                        let items = [
                            SubNavigationItem("Friends"),
                            SubNavigationItem("Groups"),
                            SubNavigationItem("Pages"),
                            SubNavigationItem("Events")
                        ]
                        
                        VStack(spacing: 12) {
                            FDSSubNavigationBar(items: items, style: .links) { index in
                                withAnimation {
                                    linkTappedMessage = "\(items[index].title) link tapped"
                                }
                            }
                            
                            Text(linkTappedMessage)
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .transition(.asymmetric(
                                    insertion: .opacity.animation(.swapShuffleIn(MotionDuration.extraShortIn)),
                                    removal: .opacity.animation(.swapShuffleOut(MotionDuration.extraShortOut))
                                ))
                        }
                    }
                    
                    VStack(spacing: 0) {
                        Text("Links variant on media")
                            .meta4LinkTypography()
                            .foregroundStyle(Color("primaryTextOnMedia"))
                            .textOnMediaShadow()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                        let items = [
                            SubNavigationItem("All"),
                            SubNavigationItem("Photos"),
                            SubNavigationItem("Videos"),
                            SubNavigationItem("Albums")
                        ]
                        
                        FDSSubNavigationBar(items: items, style: .links, onMedia: true)
                    }
                    .padding(.bottom, 12)
                    .background(
                        ZStack {
                            Image("image3")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                            Color("overlayOnMediaLight")
                        }
                        .allowsHitTesting(false)
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
    SubNavigationBarPreviewView()
}

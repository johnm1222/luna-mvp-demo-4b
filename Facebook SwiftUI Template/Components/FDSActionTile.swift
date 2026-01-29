import SwiftUI

// MARK: - Content Enumeration
enum FDSActionTileContent {
    case `default`
    case compact
}

// MARK: - Type Enumeration
enum FDSActionTileType {
    case bordered
    case elevated
    case flat
}

// MARK: - Hierarchy Level Enumeration
enum FDSActionTileHierarchyLevel {
    case level3
    case level4
}

// MARK: - Top Add-On Type Enumeration
enum FDSActionTileTopAddOn {
    case icon(String)
    case profilePhoto(String)
    case expressiveIconAsset(String, size: CGFloat? = nil)
}

// MARK: - Horizontal Alignment Enumeration
enum FDSActionTileHorizontalAlignment {
    case `default`
    case center
}

// MARK: - Height Mode Enumeration
enum FDSActionTileHeightMode {
    case flexible
    case constrained
}

// MARK: - Ticker Type Enumeration
enum FDSActionTileTickerType {
    case positive
    case negative
    case secondary
}

// MARK: - FDSActionTile Component
struct FDSActionTile<Destination: View>: View {
    // MARK: - Properties
    let content: FDSActionTileContent
    let type: FDSActionTileType
    let hierarchyLevel: FDSActionTileHierarchyLevel
    let topAddOn: FDSActionTileTopAddOn?
    let horizontalAlignment: FDSActionTileHorizontalAlignment
    let heightMode: FDSActionTileHeightMode
    let headline: String
    let bodyText: String?
    let meta: String?
    let tickerIcon: String?
    let tickerText: String?
    let tickerType: FDSActionTileTickerType?
    let action: (() -> Void)?
    let destination: (() -> Destination)?
    let navigationValue: (any Hashable)?
    
    // MARK: - Initializer
    init(
        content: FDSActionTileContent = .default,
        type: FDSActionTileType = .bordered,
        hierarchyLevel: FDSActionTileHierarchyLevel = .level4,
        topAddOn: FDSActionTileTopAddOn? = nil,
        horizontalAlignment: FDSActionTileHorizontalAlignment = .default,
        heightMode: FDSActionTileHeightMode = .constrained,
        headline: String,
        bodyText: String? = nil,
        meta: String? = nil,
        tickerIcon: String? = nil,
        tickerText: String? = nil,
        tickerType: FDSActionTileTickerType? = nil,
        action: (() -> Void)? = nil,
        navigationValue: (any Hashable)? = nil,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.content = content
        self.type = type
        self.hierarchyLevel = hierarchyLevel
        self.topAddOn = topAddOn
        self.horizontalAlignment = horizontalAlignment
        self.heightMode = heightMode
        self.headline = headline
        self.bodyText = bodyText
        self.meta = meta
        self.tickerIcon = tickerIcon
        self.tickerText = tickerText
        self.tickerType = tickerType
        self.action = action
        self.navigationValue = navigationValue
        self.destination = destination
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if let navigationValue = navigationValue {
                NavigationLink(value: navigationValue) {
                    tileContent
                }
                .buttonStyle(FDSPressedState(cornerRadius: cornerRadius, isOnMedia: false, scale: .medium))
            } else if let destination = destination {
                NavigationLink {
                    destination()
                } label: {
                    tileContent
                }
                .buttonStyle(FDSPressedState(cornerRadius: cornerRadius, isOnMedia: false, scale: .medium))
            } else if type == .flat || action == nil {
                tileContent
            } else {
                Button(action: {
                    action?()
                }) {
                    tileContent
                }
                .buttonStyle(FDSPressedState(cornerRadius: cornerRadius, isOnMedia: false, scale: .medium))
            }
        }
    }
    
    @ViewBuilder
    private var tileContent: some View {
        Group {
            if content == .default {
                defaultLayout
            } else {
                compactLayout
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment)
        .padding(cardPadding)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: shouldShowBorder ? 1 : 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .if(type == .elevated) { view in
            view.uiEmphasisShadow()
        }
    }
    
    @ViewBuilder
    private var defaultLayout: some View {
        let hAlign = horizontalAlignment == .center ? HorizontalAlignment.center : HorizontalAlignment.leading
        
        VStack(alignment: hAlign, spacing: cardRowGap) {
            if let topAddOn = topAddOn {
                topAddOnView(topAddOn)
            }
            
            VStack(alignment: hAlign, spacing: cardGap) {
                // Headline + Ticker on same line
                HStack(spacing: 4) {
                    headlineTextView(headline)
                        .foregroundStyle(Color("primaryText"))
                        .multilineTextAlignment(horizontalAlignment == .center ? .center : .leading)
                    
                    if let tickerIcon = tickerIcon, let tickerText = tickerText {
                        Image(tickerIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: tickerIconSize, height: tickerIconSize)
                            .foregroundStyle(tickerColor)
                        
                        tickerTextView(tickerText)
                            .foregroundStyle(tickerColor)
                    }
                }
                
                if let bodyText = bodyText {
                    bodyTextView(bodyText)
                        .foregroundStyle(Color("primaryText"))
                        .multilineTextAlignment(horizontalAlignment == .center ? .center : .leading)
                }
                
                if let meta = meta {
                    metaTextView(meta)
                        .foregroundStyle(Color("secondaryText"))
                        .multilineTextAlignment(horizontalAlignment == .center ? .center : .leading)
                }
            }
        }
    }
    
    @ViewBuilder
    private var compactLayout: some View {
        HStack(alignment: .center, spacing: cardPadding) {
            if let topAddOn = topAddOn {
                topAddOnView(topAddOn)
            }
            
            VStack(alignment: .leading, spacing: cardGap) {
                // Headline + Ticker on same line
                HStack(spacing: 4) {
                    headlineTextView(headline)
                        .foregroundStyle(Color("primaryText"))
                    
                    if let tickerIcon = tickerIcon, let tickerText = tickerText {
                        Image(tickerIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: tickerIconSize, height: tickerIconSize)
                            .foregroundStyle(tickerColor)
                        
                        tickerTextView(tickerText)
                            .foregroundStyle(tickerColor)
                    }
                }
                
                if let bodyText = bodyText {
                    compactBodyTextView(bodyText)
                        .foregroundStyle(Color("primaryText"))
                }
                
                if let meta = meta {
                    metaTextView(meta)
                        .foregroundStyle(Color("secondaryText"))
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    private var cardPadding: CGFloat {
        return 12  // J1, J3
    }
    
    private var cardRowGap: CGFloat {
        return 12  // J2
    }
    
    private var cardGap: CGFloat {
        return 10  // J4
    }
    
    private var cornerRadius: CGFloat {
        switch content {
        case .default:
            return 12  // M1
        case .compact:
            return 16  // M2
        }
    }
    
    private var shouldShowBorder: Bool {
        switch type {
        case .bordered, .elevated:
            return true  // L1, L2
        case .flat:
            return false  // L3
        }
    }
    
    private var backgroundColor: Color {
        switch type {
        case .bordered:
            return Color("cardBackground")  // I3
        case .elevated:
            return Color("cardBackground")  // I4
        case .flat:
            return Color("cardBackgroundFlat")  // I5
        }
    }
    
    private var borderColor: Color {
        return Color("borderUiEmphasis")
    }
    
    private var alignment: Alignment {
        switch horizontalAlignment {
        case .default:
            return .leading
        case .center:
            return .center
        }
    }
    
    private var topAddOnIconSize: CGFloat {
        switch hierarchyLevel {
        case .level4:
            return 20  // K4
        case .level3:
            return 24
        }
    }
    
    private var topAddOnProfilePhotoSize: CGFloat {
        switch hierarchyLevel {
        case .level4:
            return 40
        case .level3:
            return 60
        }
    }
    
    private var tickerIconSize: CGFloat {
        switch hierarchyLevel {
        case .level4:
            return 12  // K5
        case .level3:
            return 16  // K6
        }
    }
    
    private var tickerColor: Color {
        guard let tickerType = tickerType else { return Color("secondaryIcon") }
        switch tickerType {
        case .positive:
            return Color("positive")  // I6, I7
        case .negative:
            return Color("negative")  // I8, I9
        case .secondary:
            return Color("secondaryText")  // I10, I11
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func topAddOnView(_ addOn: FDSActionTileTopAddOn) -> some View {
        switch addOn {
        case .icon(let iconName):
            Image(iconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color("primaryIcon"))  // I1
                .frame(width: topAddOnIconSize, height: topAddOnIconSize)
                
        case .profilePhoto(let imageName):
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: topAddOnProfilePhotoSize, height: topAddOnProfilePhotoSize)
                .clipShape(Circle())
                
        case .expressiveIconAsset(let assetName, let customSize):
            let size = customSize ?? topAddOnProfilePhotoSize
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
    
    @ViewBuilder
    private func headlineTextView(_ text: String) -> some View {
        switch hierarchyLevel {
        case .level4:
            Text(text).headline4EmphasizedTypography()  // O1
        case .level3:
            Text(text).headline3EmphasizedTypography()  // O5
        }
    }
    
    @ViewBuilder
    private func bodyTextView(_ text: String) -> some View {
        switch hierarchyLevel {
        case .level4:
            Text(text).body4LinkTypography()  // O2
        case .level3:
            Text(text).body3LinkTypography()  // O6
        }
    }
    
    @ViewBuilder
    private func compactBodyTextView(_ text: String) -> some View {
        switch hierarchyLevel {
        case .level4:
            Text(text).body4LinkTypography()  // O4
        case .level3:
            Text(text).body3LinkTypography()  // O8
        }
    }
    
    @ViewBuilder
    private func metaTextView(_ text: String) -> some View {
        switch hierarchyLevel {
        case .level4:
            Text(text).meta4Typography()
        case .level3:
            Text(text).meta3Typography()
        }
    }
    
    @ViewBuilder
    private func tickerTextView(_ text: String) -> some View {
        switch hierarchyLevel {
        case .level4:
            Text(text).headline4EmphasizedTypography()  // O3
        case .level3:
            Text(text).headline3EmphasizedTypography()  // O7
        }
    }
}

// MARK: - FDSActionTile Extension (No Destination)
extension FDSActionTile where Destination == EmptyView {
    init(
        content: FDSActionTileContent = .default,
        type: FDSActionTileType = .bordered,
        hierarchyLevel: FDSActionTileHierarchyLevel = .level4,
        topAddOn: FDSActionTileTopAddOn? = nil,
        horizontalAlignment: FDSActionTileHorizontalAlignment = .default,
        heightMode: FDSActionTileHeightMode = .constrained,
        headline: String,
        bodyText: String? = nil,
        meta: String? = nil,
        tickerIcon: String? = nil,
        tickerText: String? = nil,
        tickerType: FDSActionTileTickerType? = nil,
        action: (() -> Void)? = nil,
        navigationValue: (any Hashable)? = nil
    ) {
        self.content = content
        self.type = type
        self.hierarchyLevel = hierarchyLevel
        self.topAddOn = topAddOn
        self.horizontalAlignment = horizontalAlignment
        self.heightMode = heightMode
        self.headline = headline
        self.bodyText = bodyText
        self.meta = meta
        self.tickerIcon = tickerIcon
        self.tickerText = tickerText
        self.tickerType = tickerType
        self.action = action
        self.navigationValue = navigationValue
        self.destination = nil
    }
}

// MARK: - Action Tile Card Component for Previews
struct ActionTileCard<Content: View>: View {
    let title: String
    let content: Content
    let backgroundType: ButtonGroupCardBackground
    
    init(title: String, backgroundType: ButtonGroupCardBackground = .normal, @ViewBuilder content: () -> Content) {
        self.title = title
        self.backgroundType = backgroundType
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .meta4LinkTypography()
                .foregroundStyle(backgroundType == .normal ? Color("primaryText") : Color("alwaysWhite"))
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        switch backgroundType {
        case .normal:
            Color("cardBackground")
        case .purple:
            Color("decorativeIconPurple")
        case .media:
            ZStack {
                Image("image2")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                Color("overlayOnMediaLight")
            }
        }
    }
}

// MARK: - Action Tiles Preview View
struct ActionTilesPreviewView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Basic Types
                    ActionTileCard(title: "Bordered type") {
                        FDSActionTile(
                            type: .bordered,
                            headline: "Headline text",
                            bodyText: "Body text",
                            meta: "Meta text",
                            action: {}
                        )
                    }
                    
                    ActionTileCard(title: "Elevated type") {
                        FDSActionTile(
                            type: .elevated,
                            headline: "Headline text",
                            bodyText: "Body text",
                            meta: "Meta text",
                            action: {}
                        )
                    }
                    
                    ActionTileCard(title: "Flat type") {
                        FDSActionTile(
                            type: .flat,
                            headline: "Headline text",
                            bodyText: "Body text",
                            meta: "Meta text"
                        )
                    }
                    
                    // With Top Add-Ons
                    ActionTileCard(title: "With icon add-on") {
                        FDSActionTile(
                            topAddOn: .icon("star-filled"),
                            headline: "Headline text",
                            bodyText: "Body text",
                            action: {}
                        )
                    }
                    
                    ActionTileCard(title: "With profile photo add-on") {
                        FDSActionTile(
                            topAddOn: .profilePhoto("profile1"),
                            headline: "Headline text",
                            bodyText: "Body text",
                            action: {}
                        )
                    }
                    
                    ActionTileCard(title: "With expressive icon add-on") {
                        VStack(spacing: 8) {
                            FDSActionTile(
                                topAddOn: .expressiveIconAsset("fb-meta-ai-assistant"),
                                headline: "Default size",
                                bodyText: "Body text",
                                action: {}
                            )
                            
                            FDSActionTile(
                                topAddOn: .expressiveIconAsset("fb-meta-ai-assistant", size: 24),
                                headline: "Custom size 24",
                                bodyText: "Body text",
                                action: {}
                            )
                        }
                    }
                    
                    // With Ticker
                    ActionTileCard(title: "With positive ticker") {
                        FDSActionTile(
                            headline: "Heading",
                            bodyText: "Body text",
                            meta: "Meta text",
                            tickerIcon: "arrow-up-filled",
                            tickerText: "50%",
                            tickerType: .positive,
                            action: {}
                        )
                    }
                    
                    ActionTileCard(title: "With negative ticker") {
                        FDSActionTile(
                            headline: "Heading",
                            bodyText: "Body text",
                            meta: "Meta text",
                            tickerIcon: "arrow-down-filled",
                            tickerText: "0%",
                            tickerType: .negative,
                            action: {}
                        )
                    }
                    
                    // Center Alignment
                    ActionTileCard(title: "Center aligned") {
                        FDSActionTile(
                            topAddOn: .icon("star-filled"), horizontalAlignment: .center,
                            headline: "Headline text",
                            bodyText: "Body text",
                            meta: "Meta text",
                            action: {}
                        )
                    }
                    
                    // Compact Layout
                    ActionTileCard(title: "Compact layout") {
                        FDSActionTile(
                            content: .compact,
                            topAddOn: .icon("star-filled"),
                            headline: "Headline",
                            bodyText: "Body text",
                            meta: "Meta text",
                            action: {}
                        )
                    }
                    
                    ActionTileCard(title: "Compact with ticker") {
                        FDSActionTile(
                            content: .compact,
                            topAddOn: .icon("star-filled"),
                            headline: "Heading",
                            bodyText: "Body text",
                            meta: "Meta text",
                            tickerIcon: "arrow-up-filled",
                            tickerText: "50%",
                            tickerType: .positive,
                            action: {}
                        )
                    }
                    
                    // Hierarchy Levels
                    ActionTileCard(title: "Hierarchy level 3") {
                        FDSActionTile(
                            hierarchyLevel: .level3,
                            topAddOn: .icon("star-filled"),
                            headline: "Headline text",
                            bodyText: "Body text",
                            meta: "Meta text",
                            action: {}
                        )
                    }
                    
                    ActionTileCard(title: "Hierarchy level 4") {
                        FDSActionTile(
                            hierarchyLevel: .level4,
                            topAddOn: .icon("star-filled"),
                            headline: "Headline text",
                            bodyText: "Body text",
                            meta: "Meta text",
                            action: {}
                        )
                    }
                    
                    // Complex Examples
                    ActionTileCard(title: "Full example") {
                        VStack(spacing: 8) {
                            FDSActionTile(
                                type: .bordered,
                                topAddOn: .icon("star-filled"),
                                headline: "Headline",
                                bodyText: "Body",
                                meta: "Meta Text",
                                action: {}
                            )
                            
                            FDSActionTile(
                                content: .compact,
                                type: .elevated,
                                headline: "Heading",
                                bodyText: "Body text",
                                meta: "Meta text",
                                tickerIcon: "arrow-up-filled",
                                tickerText: "50%",
                                tickerType: .positive,
                                action: {}
                            )
                            
                            FDSActionTile(
                                content: .compact,
                                type: .flat,
                                headline: "Body text",
                                bodyText: nil,
                                meta: nil
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Action tiles")
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Preview
#Preview {
    ActionTilesPreviewView()
}


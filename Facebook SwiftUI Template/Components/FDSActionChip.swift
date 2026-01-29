import SwiftUI

// MARK: - Surface Enumeration
enum FDSActionChipSurface {
    case surface
    case media
    case color
}

// MARK: - Type Enumeration
enum FDSActionChipType {
    case primary
    case primaryDeemphasized
    case secondary
}

// MARK: - Size Enumeration
enum FDSActionChipSize {
    case large
    case medium
    case small
}

// MARK: - Left Add-On Type Enumeration
enum FDSActionChipLeftAddOnType {
    case icon(String)
    case profilePhoto(String)
    case dualProfilePhoto(String, String)
    case expressiveIconAsset(String)
}

// MARK: - FDSActionChip Component
struct FDSActionChip: View {
    // MARK: - Properties
    let surface: FDSActionChipSurface
    let type: FDSActionChipType
    let size: FDSActionChipSize
    let label: String
    let leftAddOn: FDSActionChipLeftAddOnType?
    let isMenu: Bool
    let isEmphasized: Bool
    let action: () -> Void
    
    // MARK: - Initializer
    init(
        surface: FDSActionChipSurface = .surface,
        type: FDSActionChipType = .primary,
        size: FDSActionChipSize,
        label: String,
        leftAddOn: FDSActionChipLeftAddOnType? = nil,
        isMenu: Bool = false,
        isEmphasized: Bool = false,
        action: @escaping () -> Void
    ) {
        self.surface = surface
        self.type = type
        self.size = size
        self.label = label
        self.leftAddOn = leftAddOn
        self.isMenu = isMenu
        self.isEmphasized = isEmphasized
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 6) {
                // Left Add-On
                if let leftAddOn = leftAddOn {
                    leftAddOnView(leftAddOn)
                }
                
                // Label
                textWithTypography(label)
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                
                // Menu Icon
                if isMenu {
                    Image("triangle-down-filled")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(textColor)
                        .frame(width: menuIconSize, height: menuIconSize)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.trailing, extraRightPadding)
            .frame(minHeight: minHeight)
            .frame(minWidth: minWidth)
            .background {
                if surface == .media && type == .secondary {
                    if #available(iOS 26.0, *), GlassEffectSettings.shared.isEnabled {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .glassEffect(.clear.interactive())
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.thinMaterial)
                            .colorScheme(.dark)
                    }
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
                    .opacity(shouldShowBorder ? 1.0 : 0.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(FDSPressedState(cornerRadius: 9999, isOnMedia: surface != .surface, scale: .medium))
    }
    
    // MARK: - Computed Properties
    
    private var horizontalPadding: CGFloat {
        let basePadding: CGFloat
        switch size {
        case .large: basePadding = 6  // ACTION_GAP
        case .medium: basePadding = 4  // XSMALL
        case .small: basePadding = 4   // XSMALL
        }
        
        // Special cases for padding
        if let leftAddOn = leftAddOn {
            if case .icon = leftAddOn {
                return 8  // Icon left add-on chips get 8pt horizontal padding
            }
            return basePadding  // Other add-ons use base padding
        } else {
            return basePadding + 6  // Text-only gets extra 6pts padding
        }
    }
    
    private var extraRightPadding: CGFloat {
        guard let leftAddOn = leftAddOn else { return 0 }
        switch leftAddOn {
        case .expressiveIconAsset, .profilePhoto, .dualProfilePhoto:
            return 6  // Extra 6dp padding on right for visual add-ons
        default:
            return 0
        }
    }
    
    private var minHeight: CGFloat {
        switch size {
        case .large: return 36  // CHIP_LARGE_HEIGHT
        case .medium: return 32  // CHIP_HEIGHT
        case .small: return 24   // CHIP_SMALL_HEIGHT
        }
    }
    
    private var minWidth: CGFloat {
        switch size {
        case .large: return 36  // CHIP_LARGE_HEIGHT
        case .medium: return 32  // CHIP_HEIGHT
        case .small: return 24   // CHIP_SMALL_HEIGHT
        }
    }
    
    private var cornerRadius: CGFloat {
        return 9999  // ROUND
    }
    
    private var borderWidth: CGFloat {
        return 1  // BORDER_WIDTH_MEDIUM
    }
    
    private var shouldShowBorder: Bool {
        // Show border for primary and primaryDeemphasized types
        return type == .primary || type == .primaryDeemphasized
    }
    
    private var iconAddOnSize: CGFloat {
        switch size {
        case .large: return 16
        case .medium: return 16
        case .small: return 12
        }
    }
    
    private var otherAddOnSize: CGFloat {
        switch size {
        case .large: return 24
        case .medium: return 24
        case .small: return 16
        }
    }
    
    private var menuIconSize: CGFloat {
        return 16  // All sizes use 16dp for menu icon
    }
    
    private var backgroundColor: Color {
        switch surface {
        case .surface:
            switch type {
            case .primary:
                return Color("cardBackground")  // H1
            case .primaryDeemphasized:
                return Color("cardBackground")  // H5
            case .secondary:
                return Color("secondaryButtonBackground")  // H9
            }
        case .media:
            switch type {
            case .primary, .primaryDeemphasized:
                return Color("primaryButtonBackgroundOnMedia")  // I1, I5
            case .secondary:
                return Color("secondaryButtonBackgroundOnMedia")  // I9
            }
        case .color:
            switch type {
            case .primary, .primaryDeemphasized:
                return Color("primaryButtonBackgroundOnColor")  // J1, J4
            case .secondary:
                return Color("secondaryButtonBackgroundOnColor")  // J7
            }
        }
    }
    
    private var textColor: Color {
        switch surface {
        case .surface:
            switch type {
            case .primary:
                return Color("secondaryButtonText")  // H3
            case .primaryDeemphasized:
                return Color("secondaryText")  // H7
            case .secondary:
                return Color("secondaryButtonText")  // H11
            }
        case .media:
            switch type {
            case .primary, .primaryDeemphasized:
                return Color("primaryButtonTextOnMedia")  // I3, I7
            case .secondary:
                return Color("secondaryButtonTextOnMedia")  // I11
            }
        case .color:
            switch type {
            case .primary, .primaryDeemphasized:
                return Color("primaryButtonTextOnColor")  // J3, J6
            case .secondary:
                return Color("secondaryButtonTextOnColor")  // J9
            }
        }
    }
    
    private var iconColor: Color {
        switch surface {
        case .surface:
            switch type {
            case .primary:
                return Color("secondaryButtonIcon")  // H2
            case .primaryDeemphasized:
                return Color("secondaryIcon")  // H6
            case .secondary:
                return Color("secondaryButtonIcon")  // H10
            }
        case .media:
            switch type {
            case .primary, .primaryDeemphasized:
                return Color("primaryButtonIconOnMedia")  // I2, I6
            case .secondary:
                return Color("secondaryButtonIconOnMedia")  // I10
            }
        case .color:
            switch type {
            case .primary, .primaryDeemphasized:
                return Color("primaryButtonIconOnColor")  // J2, J5
            case .secondary:
                return Color("secondaryButtonIconOnColor")  // J8
            }
        }
    }
    
    private var borderColor: Color {
        switch surface {
        case .surface:
            return Color("borderUiEmphasis")  // H4, H8
        case .media:
            return Color("borderUiEmphasisOnMedia")  // I4, I8
        case .color:
            return .clear  // No border colors defined for on-color variants
        }
    }
    
    @ViewBuilder
    private func textWithTypography(_ text: String) -> some View {
        switch size {
        case .large:
            if isEmphasized {
                Text(text).body3LinkTypography()  // P6
            } else {
                Text(text).body3Typography()  // P5
            }
        case .medium:
            if isEmphasized {
                Text(text).body4LinkTypography()  // P4
            } else {
                Text(text).body4Typography()  // P3
            }
        case .small:
            if isEmphasized {
                Text(text).meta4LinkTypography()  // P2
            } else {
                Text(text).meta4Typography()  // P1
            }
        }
    }
    
    @ViewBuilder
    private func leftAddOnView(_ addOn: FDSActionChipLeftAddOnType) -> some View {
        switch addOn {
        case .icon(let iconName):
            Image(iconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(iconColor)
                .frame(width: iconAddOnSize, height: iconAddOnSize)
                
        case .profilePhoto(let imageName):
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: otherAddOnSize, height: otherAddOnSize)
                .clipShape(Circle())
                
        case .dualProfilePhoto(let image1, let image2):
            ZStack {
                Image(image1)
                    .resizable()
                    .scaledToFill()
                    .frame(width: otherAddOnSize * 0.7, height: otherAddOnSize * 0.7)
                    .clipShape(Circle())
                    .offset(x: -otherAddOnSize * 0.2, y: -otherAddOnSize * 0.2)
                
                Image(image2)
                    .resizable()
                    .scaledToFill()
                    .frame(width: otherAddOnSize * 0.7, height: otherAddOnSize * 0.7)
                    .clipShape(Circle())
                    .offset(x: otherAddOnSize * 0.2, y: otherAddOnSize * 0.2)
            }
            .frame(width: otherAddOnSize, height: otherAddOnSize)
            
        case .expressiveIconAsset(let assetName):
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: otherAddOnSize, height: otherAddOnSize)
        }
    }
}


// MARK: - Simple Wrapping Layout 
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            content
        }
    }
}

// MARK: - Horizontal Scroll Layout for Action Chips
struct ActionChipHScroll<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                content
            }
            .padding(.horizontal, 12)
        }
    }
}

// MARK: - Chip Group Card Component
struct ChipGroupCard<Content: View>: View {
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

// MARK: - Action Chips Preview View
struct ActionChipsPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSActionChip",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    // Basic Types
                    ChipGroupCard(title: "Primary") {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(type: .primary, size: .large, label: "Primary", action: {})
                                FDSActionChip(type: .primary, size: .medium, label: "Primary", action: {})
                                FDSActionChip(type: .primary, size: .small, label: "Primary", action: {})
                            }
                        }
                    }
                    
                    ChipGroupCard(title: "Primary deemphasized") {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(type: .primaryDeemphasized, size: .large, label: "Deemph", action: {})
                                FDSActionChip(type: .primaryDeemphasized, size: .medium, label: "Deemph", action: {})
                                FDSActionChip(type: .primaryDeemphasized, size: .small, label: "Deemph", action: {})
                            }
                        }
                    }
                    
                    ChipGroupCard(title: "Secondary") {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(type: .secondary, size: .large, label: "Secondary", action: {})
                                FDSActionChip(type: .secondary, size: .medium, label: "Secondary", action: {})
                                FDSActionChip(type: .secondary, size: .small, label: "Secondary", action: {})
                            }
                        }
                    }
                    
                    // With Icons
                    ChipGroupCard(title: "With icons") {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(
                                    size: .large,
                                    label: "Add photo",
                                    leftAddOn: .icon("photo-filled"),
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .medium,
                                    label: "Share",
                                    leftAddOn: .icon("share-filled"),
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .small,
                                    label: "Like",
                                    leftAddOn: .icon("heart-filled"),
                                    action: {}
                                )
                            }
                        }
                    }
                    
                    // With Profile Photos
                    ChipGroupCard(title: "With profile photos") {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(
                                    size: .large,
                                    label: "Profile",
                                    leftAddOn: .profilePhoto("profile1"),
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .medium,
                                    label: "User",
                                    leftAddOn: .profilePhoto("profile2"),
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .small,
                                    label: "Me",
                                    leftAddOn: .profilePhoto("profile3"),
                                    action: {}
                                )
                            }
                        }
                    }
                    
                    // With Dual Profile Photos
                    ChipGroupCard(title: "With dual profile photos") {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(
                                    size: .large,
                                    label: "Duo",
                                    leftAddOn: .dualProfilePhoto("profile1", "profile2"),
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .medium,
                                    label: "Team",
                                    leftAddOn: .dualProfilePhoto("profile3", "profile4"),
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .small,
                                    label: "Us",
                                    leftAddOn: .dualProfilePhoto("profile5", "profile6"),
                                    action: {}
                                )
                            }
                        }
                    }
                    
                    // With Expressive Icons
                    ChipGroupCard(title: "With expressive icons") {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(
                                    size: .large,
                                    label: "Meta AI",
                                    leftAddOn: .expressiveIconAsset("fb-meta-ai-assistant"),
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .medium,
                                    label: "Meta AI",
                                    leftAddOn: .expressiveIconAsset("fb-meta-ai-assistant"),
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .small,
                                    label: "Meta AI",
                                    leftAddOn: .expressiveIconAsset("fb-meta-ai-assistant"),
                                    action: {}
                                )
                            }
                        }
                    }
                    
                    // Menu Chips
                    ChipGroupCard(title: "Menu chips") {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(
                                    size: .large,
                                    label: "Menu",
                                    isMenu: true,
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .medium,
                                    label: "Options",
                                    leftAddOn: .icon("settings-filled"),
                                    isMenu: true,
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .small,
                                    label: "More",
                                    isMenu: true,
                                    action: {}
                                )
                            }
                        }
                    }
                    
                    // Emphasized Chips
                    ChipGroupCard(title: "Emphasized text") {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(
                                    size: .large,
                                    label: "Emphasized",
                                    isEmphasized: true,
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .medium,
                                    label: "Link style",
                                    leftAddOn: .icon("heart-filled"),
                                    isEmphasized: true,
                                    action: {}
                                )
                                FDSActionChip(
                                    size: .small,
                                    label: "Bold",
                                    isEmphasized: true,
                                    action: {}
                                )
                            }
                        }
                    }
                    
                    // On Color
                    ChipGroupCard(title: "On color", backgroundType: .purple) {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(
                                    surface: .color,
                                    type: .primary,
                                    size: .large,
                                    label: "Primary",
                                    action: {}
                                )
                                FDSActionChip(
                                    surface: .color,
                                    type: .secondary,
                                    size: .large,
                                    label: "Secondary",
                                    action: {}
                                )
                            }
                        }
                    }
                    
                    // On Media
                    ChipGroupCard(title: "On media", backgroundType: .media) {
                        VStack(spacing: 12) {
                            FlowLayout(spacing: 8) {
                                FDSActionChip(
                                    surface: .media,
                                    type: .primary,
                                    size: .large,
                                    label: "Primary",
                                    action: {}
                                )
                                FDSActionChip(
                                    surface: .media,
                                    type: .secondary,
                                    size: .large,
                                    label: "Secondary",
                                    action: {}
                                )
                            }
                        }
                    }
                    
                    // Horizontal Scroll Example
                    ChipGroupCard(title: "Horizontal scroll example") {
                        ActionChipHScroll(spacing: 8) {
                            FDSActionChip(
                                size: .medium,
                                label: "Who is this person?",
                                leftAddOn: .expressiveIconAsset("fb-meta-ai-assistant"),
                                action: {}
                            )
                            FDSActionChip(
                                size: .medium,
                                label: "How long did they work there?",
                                action: {}
                            )
                            FDSActionChip(
                                size: .medium,
                                label: "What are all of their names?",
                                action: {}
                            )
                            FDSActionChip(
                                size: .medium,
                                label: "Who else knows this person?",
                                action: {}
                            )
                        }
                        .padding(.horizontal, -12)
                    }
                }
                .padding()
            }
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Preview
#Preview {
    ActionChipsPreviewView()
}

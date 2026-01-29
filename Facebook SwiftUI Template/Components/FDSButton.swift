import SwiftUI

// MARK: - Button Type Enumeration
enum FDSButtonType {
    case primary
    case primaryDeemphasized
    case primaryOnMedia
    case primaryOnColor
    case secondary
    case secondaryOnMedia
    case secondaryOnColor
}

// MARK: - Button Size Enumeration
enum FDSButtonSize {
    case large
    case medium
    case small
}

// MARK: - Width Mode Enumeration
enum FDSButtonWidthMode {
    case flexible
    case constrained
}

// MARK: - FDSButton Component
struct FDSButton: View {
    // MARK: - Properties
    let type: FDSButtonType
    let label: String?
    let icon: String?
    let size: FDSButtonSize
    let isDisabled: Bool
    let widthMode: FDSButtonWidthMode
    let action: (() -> Void)?
    let navigationValue: (any Hashable)?
    
    // MARK: - Initializer
    init(
        type: FDSButtonType = .primary,
        label: String? = nil,
        icon: String? = nil,
        size: FDSButtonSize = .medium,
        isDisabled: Bool = false,
        widthMode: FDSButtonWidthMode = .flexible,
        navigationValue: (any Hashable)? = nil,
        action: (() -> Void)? = nil
    ) {
        self.type = type
        self.label = label
        self.icon = icon
        self.size = size
        self.isDisabled = isDisabled
        self.widthMode = widthMode
        self.navigationValue = navigationValue
        self.action = action
        
        // Validation: Either label or icon must be provided
        assert(label != nil || icon != nil, "FDSButton: Either label or icon must be provided")
        
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if let navigationValue = navigationValue {
                NavigationLink(value: navigationValue) {
                    buttonContent
                }
                .buttonStyle(FDSPressedState(cornerRadius: 8, scale: .medium))
                .disabled(isDisabled)
            } else {
                Button(action: {
                    if !isDisabled {
                        action?()
                    }
                }) {
                    buttonContent
                }
                .buttonStyle(FDSPressedState(cornerRadius: 8, scale: .medium))
                .disabled(isDisabled)
            }
        }
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        HStack(spacing: horizontalSpacing) {
            if let icon = icon {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(iconColor)
                    .frame(width: iconSize, height: iconSize)
            }
            
            if let label = label {
                textWithTypography(label)
                    .foregroundStyle(textColor)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: widthMode == .flexible ? .infinity : nil)
        .frame(height: buttonHeight)
        .background(backgroundColor)
        .cornerRadius(buttonCornerRadius)
    }
    
    // MARK: - Computed Properties
    
    private var horizontalSpacing: CGFloat {
        return 6
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .large: return 12
        case .medium: return 12
        case .small: return 8
        }
    }
    
    
    private var buttonHeight: CGFloat {
        switch size {
        case .large: return 40
        case .medium: return 36
        case .small: return 28
        }
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .large: return 16
        case .medium: return 16
        case .small: return 12
        }
    }
    
    private var buttonCornerRadius: CGFloat {
        switch size {
        case .large: return 8
        case .medium: return 8
        case .small: return 8
        }
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return Color("disabledButtonBackground")
        }
        
        switch type {
        case .primary:
            return Color("primaryButtonBackground")
        case .primaryDeemphasized:
            return Color("primaryDeemphasizedButtonBackground")
        case .primaryOnMedia:
            return Color("primaryButtonBackgroundOnMedia")
        case .primaryOnColor:
            return Color("primaryButtonBackgroundOnColor")
        case .secondary:
            return Color("secondaryButtonBackground")
        case .secondaryOnMedia:
            return Color("secondaryButtonBackgroundOnMedia")
        case .secondaryOnColor:
            return Color("secondaryButtonBackgroundOnColor")
        }
    }
    
    private var textColor: Color {
        if isDisabled {
            return Color("disabledText")
        }
        
        switch type {
        case .primary:
            return Color("primaryButtonText")
        case .primaryDeemphasized:
            return Color("primaryDeemphasizedButtonText")
        case .primaryOnMedia:
            return Color("primaryButtonTextOnMedia")
        case .primaryOnColor:
            return Color("primaryButtonTextOnColor")
        case .secondary:
            return Color("secondaryButtonText")
        case .secondaryOnMedia:
            return Color("secondaryButtonTextOnMedia")
        case .secondaryOnColor:
            return Color("secondaryButtonTextOnColor")
        }
    }
    
    private var iconColor: Color {
        if isDisabled {
            return Color("disabledIcon")
        }
        
        switch type {
        case .primary:
            return Color("primaryButtonIcon")
        case .primaryDeemphasized:
            return Color("primaryDeemphasizedButtonIcon")
        case .primaryOnMedia:
            return Color("primaryButtonIconOnMedia")
        case .primaryOnColor:
            return Color("primaryButtonIconOnColor")
        case .secondary:
            return Color("secondaryButtonIcon")
        case .secondaryOnMedia:
            return Color("secondaryButtonIconOnMedia")
        case .secondaryOnColor:
            return Color("secondaryButtonIconOnColor")
        }
    }
    
    @ViewBuilder
    private func textWithTypography(_ text: String) -> some View {
        switch size {
        case .large:
            Text(text).button1Typography()
        case .medium:
            Text(text).button2Typography()
        case .small:
            Text(text).button3Typography()
        }
    }
}


// MARK: - Button Group Card Component
enum ButtonGroupCardBackground {
    case normal
    case purple
    case media
}

struct ButtonGroupCard<Content: View>: View {
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

// MARK: - Buttons Preview View
struct ButtonsPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSButton",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    ButtonGroupCard(title: "Primary") {
                        VStack(spacing: 12) {
                            FDSButton(type: .primary, label: "Primary action", size: .large, action: {})
                            FDSButton(type: .primary, label: "Primary action", size: .medium, action: {})
                            FDSButton(type: .primary, label: "Primary action", size: .small, action: {})
                        }
                    }
                    
                    ButtonGroupCard(title: "Primary deemphasized") {
                        VStack(spacing: 12) {
                            FDSButton(type: .primaryDeemphasized, label: "Primary deemphasized action", size: .large, action: {})
                            FDSButton(type: .primaryDeemphasized, label: "Primary deemphasized action", size: .medium, action: {})
                            FDSButton(type: .primaryDeemphasized, label: "Primary deemphasized action", size: .small, action: {})
                        }
                    }
                    
                    ButtonGroupCard(title: "Secondary") {
                        VStack(spacing: 12) {
                            FDSButton(type: .secondary, label: "Secondary action", size: .large, action: {})
                            FDSButton(type: .secondary, label: "Secondary action", size: .medium, action: {})
                            FDSButton(type: .secondary, label: "Secondary action", size: .small, action: {})
                        }
                    }
                    
                    ButtonGroupCard(title: "Primary on color", backgroundType: .purple) {
                        VStack(spacing: 12) {
                            FDSButton(type: .primaryOnColor, label: "Primary on color", size: .large, action: {})
                            FDSButton(type: .primaryOnColor, label: "Primary on color", size: .medium, action: {})
                            FDSButton(type: .primaryOnColor, label: "Primary on color", size: .small, action: {})
                        }
                    }
                    
                    ButtonGroupCard(title: "Secondary on color", backgroundType: .purple) {
                        VStack(spacing: 12) {
                            FDSButton(type: .secondaryOnColor, label: "Secondary on color", size: .large, action: {})
                            FDSButton(type: .secondaryOnColor, label: "Secondary on color", size: .medium, action: {})
                            FDSButton(type: .secondaryOnColor, label: "Secondary on color", size: .small, action: {})
                        }
                    }
                    
                    ButtonGroupCard(title: "Primary on media", backgroundType: .media) {
                        VStack(spacing: 12) {
                            FDSButton(type: .primaryOnMedia, label: "Primary on media", size: .large, action: {})
                            FDSButton(type: .primaryOnMedia, label: "Primary on media", size: .medium, action: {})
                            FDSButton(type: .primaryOnMedia, label: "Primary on media", size: .small, action: {})
                        }
                    }
                    
                    ButtonGroupCard(title: "Secondary on media", backgroundType: .media) {
                        VStack(spacing: 12) {
                            FDSButton(type: .secondaryOnMedia, label: "Secondary on media", size: .large, action: {})
                            FDSButton(type: .secondaryOnMedia, label: "Secondary on media", size: .medium, action: {})
                            FDSButton(type: .secondaryOnMedia, label: "Secondary on media", size: .small, action: {})
                        }
                    }
                    
                    ButtonGroupCard(title: "Icon only") {
                        HStack(spacing: 12) {
                            FDSButton(icon: "photo-filled", size: .large, action: {})
                            FDSButton(icon: "photo-filled", size: .medium, action: {})
                            FDSButton(icon: "photo-filled", size: .small, action: {})
                        }
                    }
                    
                    ButtonGroupCard(title: "Icon + label") {
                        VStack(spacing: 12) {
                            FDSButton(label: "Add photo", icon: "photo-filled", action: {})
                            FDSButton(type: .secondary, label: "Share", icon: "share-filled", action: {})
                        }
                    }
                    
                    ButtonGroupCard(title: "Disabled state") {
                        VStack(spacing: 12) {
                            FDSButton(label: "Disabled", isDisabled: true, action: {})
                        }
                    }
                    
                    ButtonGroupCard(title: "Width modes") {
                        VStack(alignment: .center, spacing: 12) {
                            FDSButton(label: "Flexible width", widthMode: .flexible, action: {})
                            FDSButton(label: "Constrained", widthMode: .constrained, action: {})
                        }
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
    ButtonsPreviewView()
}

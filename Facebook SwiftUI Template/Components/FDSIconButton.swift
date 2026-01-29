import SwiftUI

// MARK: - Icon Button Size
enum FDSIconButtonSize {
    case size20
    case size24
    
    var value: CGFloat {
        switch self {
        case .size20: return 20
        case .size24: return 24
        }
    }
}

// MARK: - Icon Button Color
enum FDSIconButtonColor {
    case primary
    case secondary
    case accent
    
    func color(onMedia: Bool) -> Color {
        switch self {
        case .primary:
            return onMedia ? Color("primaryIconOnMedia") : Color("primaryIcon")
        case .secondary:
            return onMedia ? Color("secondaryIconOnMedia") : Color("secondaryIcon")
        case .accent:
            return onMedia ? Color("accentColor") : Color("accentColor")
        }
    }
}

// MARK: - FDSIconButton Component
struct FDSIconButton: View {
    let icon: String
    let size: FDSIconButtonSize
    let color: FDSIconButtonColor
    let onMedia: Bool
    let action: () -> Void
    
    init(
        icon: String,
        size: FDSIconButtonSize = .size24,
        color: FDSIconButtonColor = .primary,
        onMedia: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.onMedia = onMedia
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: size.value, height: size.value)
                .foregroundStyle(color.color(onMedia: onMedia))
                .if(onMedia) { view in
                    view.iconOnMediaShadow()
                }
        }
        .buttonStyle(FDSPressedState(
            circle: true,
            isOnMedia: onMedia,
            padding: EdgeInsets(
                top: size.value == 24 ? 10 : 12,
                leading: size.value == 24 ? 10 : 12,
                bottom: size.value == 24 ? 10 : 12,
                trailing: size.value == 24 ? 10 : 12
            )
        ))
    }
}

// MARK: - Icon Button Group Card Component
struct IconButtonGroupCard<Content: View>: View {
    let title: String
    let content: Content
    let onMedia: Bool
    
    init(title: String, onMedia: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.onMedia = onMedia
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .meta4LinkTypography()
                .foregroundStyle(onMedia ? Color("primaryTextOnMedia") : Color("primaryText"))
                .if(onMedia) { view in
                    view.textOnMediaShadow()
                }
            
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
        if onMedia {
            ZStack {
                Image("image3")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                LinearGradient(
                    stops: [
                        .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 0.0),
                        .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.5),
                        .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        } else {
            Color("cardBackground")
        }
    }
}

// MARK: - Icon Buttons Preview View
struct IconButtonsPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSIconButton",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    IconButtonGroupCard(title: "Size 24 (default)") {
                        HStack(spacing: 20) {
                            FDSIconButton(icon: "heart-outline", action: {})
                            FDSIconButton(icon: "star-outline", action: {})
                            FDSIconButton(icon: "bookmark-outline", action: {})
                            FDSIconButton(icon: "share-outline", action: {})
                        }
                    }
                    
                    IconButtonGroupCard(title: "Size 20") {
                        HStack(spacing: 20) {
                            FDSIconButton(icon: "heart-outline", size: .size20, action: {})
                            FDSIconButton(icon: "star-outline", size: .size20, action: {})
                            FDSIconButton(icon: "bookmark-outline", size: .size20, action: {})
                            FDSIconButton(icon: "share-outline", size: .size20, action: {})
                        }
                    }
                    
                    IconButtonGroupCard(title: "Primary color (default)") {
                        HStack(spacing: 20) {
                            FDSIconButton(icon: "heart-outline", action: {})
                            FDSIconButton(icon: "heart-filled", action: {})
                            FDSIconButton(icon: "like-outline", action: {})
                            FDSIconButton(icon: "like", action: {})
                        }
                    }
                    
                    IconButtonGroupCard(title: "Secondary color") {
                        HStack(spacing: 20) {
                            FDSIconButton(icon: "heart-outline", color: .secondary, action: {})
                            FDSIconButton(icon: "heart-filled", color: .secondary, action: {})
                            FDSIconButton(icon: "like-outline", color: .secondary, action: {})
                            FDSIconButton(icon: "like", color: .secondary, action: {})
                        }
                    }
                    
                    IconButtonGroupCard(title: "On media (primary)", onMedia: true) {
                        HStack(spacing: 20) {
                            FDSIconButton(icon: "heart-outline", onMedia: true, action: {})
                            FDSIconButton(icon: "comment-outline", onMedia: true, action: {})
                            FDSIconButton(icon: "share-outline", onMedia: true, action: {})
                            FDSIconButton(icon: "bookmark-outline", onMedia: true, action: {})
                        }
                    }
                    
                    IconButtonGroupCard(title: "On media (secondary)", onMedia: true) {
                        HStack(spacing: 20) {
                            FDSIconButton(icon: "chevron-left-filled", color: .secondary, onMedia: true, action: {})
                            FDSIconButton(icon: "chevron-right-filled", color: .secondary, onMedia: true, action: {})
                            FDSIconButton(icon: "dots-3-horizontal-outline", color: .secondary, onMedia: true, action: {})
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
    IconButtonsPreviewView()
}


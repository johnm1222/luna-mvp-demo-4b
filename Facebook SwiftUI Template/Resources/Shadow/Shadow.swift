import SwiftUI

// MARK: - Shadow Definitions

struct FDSShadow {
    let offset: CGSize
    let radius: CGFloat
    let color: Color
    let borderWidth: CGFloat?
    let borderColor: Color?
    
    init(offset: CGSize, radius: CGFloat, color: Color, borderWidth: CGFloat? = nil, borderColor: Color? = nil) {
        self.offset = offset
        self.radius = radius
        self.color = color
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }
}

// MARK: - Shadow Constants

extension FDSShadow {
    
    /// Use for tooltip, instant feedback
    static let responsiveUI = FDSShadow(
        offset: CGSize(width: 0, height: 8),
        radius: 16,
        color: Color("shadowResponsiveUi"),
        borderWidth: 1,
        borderColor: Color("borderResponsiveUi")
    )
    
    /// Use for navigation/tab
    static let persistentUI = FDSShadow(
        offset: CGSize(width: 0, height: 4),
        radius: 12,
        color: Color("shadowPersistentUi"),
        borderWidth: 1,
        borderColor: Color("borderPersistentUi")
    )
    
    /// Use for card
    static let uiEmphasis = FDSShadow(
        offset: CGSize(width: 0, height: 2),
        radius: 8,
        color: Color("shadowUiEmphasis"),
        borderWidth: 1,
        borderColor: Color("borderUiEmphasis")
    )
    
    /// Used to separate text and icon on media
    static let onMedia = FDSShadow(
        offset: CGSize(width: 0, height: 0),
        radius: 1,
        color: Color("shadowTextAndIconOnMedia")
    )
}

// MARK: - Shadow View Modifiers

extension View {
    
    // MARK: - General Shadow Modifiers
    
    /// Apply responsive UI shadow - use for tooltip, instant feedback
    func responsiveUIShadow(cornerRadius: CGFloat = 12) -> some View {
        self.modifier(ShadowModifier(shadow: .responsiveUI, cornerRadius: cornerRadius))
    }
    
    /// Apply persistent UI shadow - use for navigation/tab
    func persistentUIShadow(cornerRadius: CGFloat = 12) -> some View {
        self.modifier(ShadowModifier(shadow: .persistentUI, cornerRadius: cornerRadius))
    }
    
    /// Apply UI emphasis shadow - use for card
    func uiEmphasisShadow(cornerRadius: CGFloat = 12) -> some View {
        self.modifier(ShadowModifier(shadow: .uiEmphasis, cornerRadius: cornerRadius))
    }
    
    /// Apply on media shadow - used to separate text and icon on media
    func onMediaShadow(cornerRadius: CGFloat = 12) -> some View {
        self.modifier(ShadowModifier(shadow: .onMedia, cornerRadius: cornerRadius))
    }
    
    // MARK: - Text and Icon Specific Modifiers
    
    /// Apply shadow specifically designed for text on media backgrounds
    func textOnMediaShadow() -> some View {
        self
            .shadow(
                color: FDSShadow.onMedia.color,
                radius: FDSShadow.onMedia.radius,
                x: FDSShadow.onMedia.offset.width,
                y: FDSShadow.onMedia.offset.height
            )
    }
    
    /// Apply shadow specifically designed for icons on media backgrounds
    func iconOnMediaShadow() -> some View {
        self
            .shadow(
                color: FDSShadow.onMedia.color,
                radius: FDSShadow.onMedia.radius,
                x: FDSShadow.onMedia.offset.width,
                y: FDSShadow.onMedia.offset.height
            )
    }
}

// MARK: - Shadow Modifier Implementation

private struct ShadowModifier: ViewModifier {
    let shadow: FDSShadow
    let cornerRadius: CGFloat
    
    init(shadow: FDSShadow, cornerRadius: CGFloat = 12) {
        self.shadow = shadow
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.offset.width,
                y: shadow.offset.height
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        shadow.borderColor ?? Color.clear,
                        lineWidth: shadow.borderWidth ?? 0
                    )
                    .allowsHitTesting(false)
            )
    }
}

// MARK: - Shadow Preview View

struct ShadowPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Shadows",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    shadowExamplesSection
                    textAndIconExamplesSection
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
            }
            .background(Color("surfaceBackground"))
        }
    }
    
    private var shadowExamplesSection: some View {
        ShadowGroupCard(title: "Shadow variants") {
            VStack(spacing: 20) {
                ShadowExampleCard(
                    title: "Responsive UI",
                    description: "Use for tooltip, instant feedback"
                ) {
                    Rectangle()
                        .fill(Color("cardBackground"))
                        .frame(height: 80)
                        .cornerRadius(12)
                        .responsiveUIShadow()
                }
                
                ShadowExampleCard(
                    title: "Persistent UI",
                    description: "Use for navigation/tab"
                ) {
                    Rectangle()
                        .fill(Color("cardBackground"))
                        .frame(height: 80)
                        .cornerRadius(12)
                        .persistentUIShadow()
                }
                
                ShadowExampleCard(
                    title: "UI Emphasis",
                    description: "Use for card"
                ) {
                    Rectangle()
                        .fill(Color("cardBackground"))
                        .frame(height: 80)
                        .cornerRadius(12)
                        .uiEmphasisShadow()
                }
                
                ShadowExampleCard(
                    title: "On Media",
                    description: "Used to separate text and icon on media"
                ) {
                    Rectangle()
                        .fill(Color("cardBackground"))
                        .frame(height: 80)
                        .cornerRadius(12)
                        .onMediaShadow()
                }
            }
        }
    }
    
    private var textAndIconExamplesSection: some View {
        ShadowGroupCard(title: "Text & icon on media") {
            VStack(spacing: 16) {
                // Media background example
                ZStack {
                    Image("image1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                    
                    VStack(spacing: 12) {
                        // Text example
                        Text("Text with shadow")
                            .headline2EmphasizedTypography()
                            .foregroundStyle(Color.white)
                            .textOnMediaShadow()
                        
                        // Icon example
                        HStack(spacing: 8) {
                            Image("heart-filled")
                                .foregroundStyle(Color.white)
                                .iconOnMediaShadow()
                            
                            Image("comment-outline")
                                .foregroundStyle(Color.white)
                                .iconOnMediaShadow()
                            
                            Image("share-outline")
                                .foregroundStyle(Color.white)
                                .iconOnMediaShadow()
                        }
                    }
                }
                
                Text("Text and icons above use textOnMediaShadow() and iconOnMediaShadow() modifiers")
                    .meta3Typography()
                    .foregroundStyle(Color("secondaryText"))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Shadow Group Card Component

struct ShadowGroupCard<Content: View>: View {
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
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("cardBackground"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Shadow Example Card Component

struct ShadowExampleCard<Content: View>: View {
    let title: String
    let description: String
    let backgroundColor: Color
    let content: Content
    
    init(
        title: String,
        description: String,
        backgroundColor: Color = Color("cardBackground"),
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .headline4EmphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                
                Text(description)
                    .meta3Typography()
                    .foregroundStyle(Color("secondaryText"))
            }
            content
        }
    }
}

// MARK: - Preview

#Preview {
    ShadowPreviewView()
}

import SwiftUI

// MARK: - Set navigation bar title font

struct NavigationBarFontSetup {
    static func configure() {
        let customFont = UIFont(name: "Facebook Sans", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.font: customFont
        ]
    }
}

extension Font {
    
    // MARK: - Headline Styles
    
    static var headline0EmphasizedFBSans: Font {
        .custom("Facebook Sans", size: 28).weight(.bold)
    }
    
    static var headline0Emphasized: Font {
        .system(size: 28, weight: .bold, design: .default)
    }
    
    static var headline1Emphasized: Font {
        .system(size: 24, weight: .bold, design: .default)
    }
    
    static var headline2Emphasized: Font {
        .system(size: 20, weight: .bold, design: .default)
    }
    
    static var headline3: Font {
        .system(size: 17, weight: .medium, design: .default)
    }
    
    static var headline3Emphasized: Font {
        .system(size: 17, weight: .bold, design: .default)
    }
    
    static var headline3Deemphasized: Font {
        .system(size: 17, weight: .regular, design: .default)
    }
    
    static var headline4: Font {
        .system(size: 15, weight: .medium, design: .default)
    }
    
    static var headline4Emphasized: Font {
        .system(size: 15, weight: .bold, design: .default)
    }
    
    static var headline4Deemphasized: Font {
        .system(size: 15, weight: .regular, design: .default)
    }
    
    // MARK: - Body Styles
    
    static var body1: Font {
        .system(size: 20, weight: .regular, design: .default)
    }
    
    static var body1Link: Font {
        .system(size: 20, weight: .semibold, design: .default)
    }
    
    static var body2: Font {
        .system(size: 17, weight: .regular, design: .default)
    }
    
    static var body2Link: Font {
        .system(size: 17, weight: .semibold, design: .default)
    }
    
    static var body3: Font {
        .system(size: 15, weight: .regular, design: .default)
    }
    
    static var body3Link: Font {
        .system(size: 15, weight: .semibold, design: .default)
    }
    
    static var body4: Font {
        .system(size: 13, weight: .regular, design: .default)
    }
    
    static var body4Link: Font {
        .system(size: 13, weight: .semibold, design: .default)
    }
    
    // MARK: - Meta Styles
    
    static var meta1: Font {
        .system(size: 13, weight: .semibold, design: .default)
    }
    
    static var meta2: Font {
        .system(size: 13, weight: .semibold, design: .default)
    }
    
    static var meta3: Font {
        .system(size: 13, weight: .regular, design: .default)
    }
    
    static var meta3Link: Font {
        .system(size: 13, weight: .semibold, design: .default)
    }
    
    static var meta4: Font {
        .system(size: 12, weight: .regular, design: .default)
    }
    
    static var meta4Link: Font {
        .system(size: 12, weight: .semibold, design: .default)
    }
    
    // MARK: - Button Styles
    
    static var button1: Font {
        .system(size: 17, weight: .semibold, design: .default)
    }
    
    static var button2: Font {
        .system(size: 15, weight: .semibold, design: .default)
    }
    
    static var button3: Font {
        .system(size: 13, weight: .semibold, design: .default)
    }
}

// MARK: - Cap Height Alignment

struct CapHeightAlignedModifier: ViewModifier {
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    let lineSpacing: CGFloat
    
    func body(content: Content) -> some View {
        let uiFont = UIFont.systemFont(ofSize: fontSize, weight: uiFontWeight(fontWeight))
        let ascent = uiFont.ascender
        let capHeight = uiFont.capHeight
        let descent = abs(uiFont.descender)
        
        // Calculate trim amounts
        let topTrim = ascent - capHeight
        let bottomTrim = descent
        
        content
            .padding(.top, -topTrim)
            .padding(.bottom, -bottomTrim)
            .lineSpacing(lineSpacing)
    }
    
    private func uiFontWeight(_ weight: Font.Weight) -> UIFont.Weight {
        switch weight {
        case .bold: return .bold
        case .semibold: return .semibold
        case .medium: return .medium
        case .regular: return .regular
        default: return .regular
        }
    }
}

struct CapHeightAlignedCustomFontModifier: ViewModifier {
    let fontName: String
    let fontSize: CGFloat
    let lineSpacing: CGFloat
    
    func body(content: Content) -> some View {
        let uiFont = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let ascent = uiFont.ascender
        let capHeight = uiFont.capHeight
        let descent = abs(uiFont.descender)
        
        // Calculate trim amounts
        let topTrim = ascent - capHeight
        let bottomTrim = descent
        
        content
            .padding(.top, -topTrim)
            .padding(.bottom, -bottomTrim)
            .lineSpacing(lineSpacing)
    }
}

extension View {
    func capHeightAligned(fontSize: CGFloat, weight: Font.Weight, lineSpacing: CGFloat) -> some View {
        self.modifier(CapHeightAlignedModifier(fontSize: fontSize, fontWeight: weight, lineSpacing: lineSpacing))
    }
    
    func capHeightAlignedCustomFont(fontName: String, fontSize: CGFloat, lineSpacing: CGFloat) -> some View {
        self.modifier(CapHeightAlignedCustomFontModifier(fontName: fontName, fontSize: fontSize, lineSpacing: lineSpacing))
    }
}

// MARK: - Typography Modifiers

extension View {
    
    // MARK: - Headline Typography Modifiers
    
    func headline0EmphasizedFBSansTypography() -> some View {
        self
            .font(.headline0EmphasizedFBSans)
            .capHeightAlignedCustomFont(fontName: "Facebook Sans", fontSize: 28, lineSpacing: 2)
    }
    
    func headline0EmphasizedTypography() -> some View {
        self
            .font(.headline0Emphasized)
            .capHeightAligned(fontSize: 28, weight: .bold, lineSpacing: 2)
    }
    
    func headline1EmphasizedTypography() -> some View {
        self
            .font(.headline1Emphasized)
            .capHeightAligned(fontSize: 24, weight: .bold, lineSpacing: 2)
    }
    
    func headline2EmphasizedTypography() -> some View {
        self
            .font(.headline2Emphasized)
            .capHeightAligned(fontSize: 20, weight: .bold, lineSpacing: 2)
    }
    
    func headline3Typography() -> some View {
        self
            .font(.headline3)
            .capHeightAligned(fontSize: 17, weight: .medium, lineSpacing: 1)
    }
    
    func headline3EmphasizedTypography() -> some View {
        self
            .font(.headline3Emphasized)
            .capHeightAligned(fontSize: 17, weight: .bold, lineSpacing: 1)
    }
    
    func headline3DeemphasizedTypography() -> some View {
        self
            .font(.headline3Deemphasized)
            .capHeightAligned(fontSize: 17, weight: .regular, lineSpacing: 1)
    }
    
    func headline4Typography() -> some View {
        self
            .font(.headline4)
            .capHeightAligned(fontSize: 15, weight: .medium, lineSpacing: 1)
    }
    
    func headline4EmphasizedTypography() -> some View {
        self
            .font(.headline4Emphasized)
            .capHeightAligned(fontSize: 15, weight: .bold, lineSpacing: 1)
    }
    
    func headline4DeemphasizedTypography() -> some View {
        self
            .font(.headline4Deemphasized)
            .capHeightAligned(fontSize: 15, weight: .regular, lineSpacing: 1)
    }
    
    // MARK: - Body Typography Modifiers
    
    func body1Typography() -> some View {
        self
            .font(.body1)
            .capHeightAligned(fontSize: 20, weight: .regular, lineSpacing: 2)
    }
    
    func body1LinkTypography() -> some View {
        self
            .font(.body1Link)
            .capHeightAligned(fontSize: 20, weight: .semibold, lineSpacing: 2)
    }
    
    func body2Typography() -> some View {
        self
            .font(.body2)
            .capHeightAligned(fontSize: 17, weight: .regular, lineSpacing: 1)
    }
    
    func body2LinkTypography() -> some View {
        self
            .font(.body2Link)
            .capHeightAligned(fontSize: 17, weight: .semibold, lineSpacing: 1)
    }
    
    func body3Typography() -> some View {
        self
            .font(.body3)
            .capHeightAligned(fontSize: 15, weight: .regular, lineSpacing: 3)
    }
    
    func body3LinkTypography() -> some View {
        self
            .font(.body3Link)
            .capHeightAligned(fontSize: 15, weight: .semibold, lineSpacing: 3)
    }
    
    func body4Typography() -> some View {
        self
            .font(.body4)
            .capHeightAligned(fontSize: 13, weight: .regular, lineSpacing: 1)
    }
    
    func body4LinkTypography() -> some View {
        self
            .font(.body4Link)
            .capHeightAligned(fontSize: 13, weight: .semibold, lineSpacing: 1)
    }
    
    // MARK: - Meta Typography Modifiers
    
    func meta1Typography() -> some View {
        self
            .font(.meta1)
            .capHeightAligned(fontSize: 13, weight: .semibold, lineSpacing: 1)
    }
    
    func meta2Typography() -> some View {
        self
            .font(.meta2)
            .capHeightAligned(fontSize: 13, weight: .semibold, lineSpacing: 1)
    }
    
    func meta3Typography() -> some View {
        self
            .font(.meta3)
            .capHeightAligned(fontSize: 13, weight: .regular, lineSpacing: 1)
    }
    
    func meta3LinkTypography() -> some View {
        self
            .font(.meta3Link)
            .capHeightAligned(fontSize: 13, weight: .semibold, lineSpacing: 1)
    }
    
    func meta4Typography() -> some View {
        self
            .font(.meta4)
            .capHeightAligned(fontSize: 12, weight: .regular, lineSpacing: 2)
    }
    
    func meta4LinkTypography() -> some View {
        self
            .font(.meta4Link)
            .capHeightAligned(fontSize: 12, weight: .semibold, lineSpacing: 2)
    }
    
    // MARK: - Button Typography Modifiers
    
    func button1Typography() -> some View {
        self
            .font(.button1)
            .capHeightAligned(fontSize: 17, weight: .semibold, lineSpacing: 1)
    }
    
    func button2Typography() -> some View {
        self
            .font(.button2)
            .capHeightAligned(fontSize: 15, weight: .semibold, lineSpacing: 1)
    }
    
    func button3Typography() -> some View {
        self
            .font(.button3)
            .capHeightAligned(fontSize: 13, weight: .semibold, lineSpacing: 1)
    }
}

// MARK: - Typography Preview View
struct TypographyPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Typography",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    TypographyGroupCard(title: "Headline") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Headline 0 FB Sans")
                                .headline0EmphasizedFBSansTypography()

                            Text("Headline 0 Emphasized")
                                .headline0EmphasizedTypography()
                            
                            Text("Headline 1 Emphasized")
                                .headline1EmphasizedTypography()
                            
                            Text("Headline 2 Emphasized")
                                .headline2EmphasizedTypography()
                            
                            Text("Headline 3")
                                .headline3Typography()
                            
                            Text("Headline 3 Emphasized")
                                .headline3EmphasizedTypography()
                            
                            Text("Headline 3 Deemphasized")
                                .headline3DeemphasizedTypography()
                            
                            Text("Headline 4")
                                .headline4Typography()
                            
                            Text("Headline 4 Emphasized")
                                .headline4EmphasizedTypography()
                            
                            Text("Headline 4 Deemphasized")
                                .headline4DeemphasizedTypography()
                        }
                    }
                    
                    TypographyGroupCard(title: "Body") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Body 1")
                                .body1Typography()
                            
                            Text("Body 1 Link")
                                .body1LinkTypography()
                            
                            Text("Body 2")
                                .body2Typography()
                            
                            Text("Body 2 Link")
                                .body2LinkTypography()
                            
                            Text("Body 3")
                                .body3Typography()
                            
                            Text("Body 3 Link")
                                .body3LinkTypography()
                            
                            Text("Body 4")
                                .body4Typography()
                            
                            Text("Body 4 Link")
                                .body4LinkTypography()
                        }
                    }
                    
                    TypographyGroupCard(title: "Meta") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meta 1")
                                .meta1Typography()
                            
                            Text("Meta 2")
                                .meta2Typography()
                            
                            Text("Meta 3")
                                .meta3Typography()
                            
                            Text("Meta 3 Link")
                                .meta3LinkTypography()
                            
                            Text("Meta 4")
                                .meta4Typography()
                            
                            Text("Meta 4 Link")
                                .meta4LinkTypography()
                        }
                    }
                    
                    TypographyGroupCard(title: "Button") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Button 1")
                                .button1Typography()
                            
                            Text("Button 2")
                                .button2Typography()
                            
                            Text("Button 3")
                                .button3Typography()
                        }
                    }
                }
                .foregroundStyle(Color("primaryText"))
                .padding(.top, 12)
                .padding(.horizontal, 16)
            }
            .background(Color("surfaceBackground"))
        }
    }
}


// MARK: - Typography Group Card Component
struct TypographyGroupCard<Content: View>: View {
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

// MARK: - Preview
#Preview {
    TypographyPreviewView()
}

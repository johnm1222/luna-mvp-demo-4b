import SwiftUI

// MARK: - Hierarchy Level Enumeration
enum FDSUnitHeaderHierarchyLevel {
    case level2
    case level3
}

// MARK: - Inline Icon Type Enumeration
enum FDSUnitHeaderInlineIconType {
    case infoButton
    case seeMore
    case menuClosed
    case menuOpen
    
    var iconName: String {
        switch self {
        case .infoButton:
            return "info-circle-filled"
        case .seeMore:
            return "chevron-right-filled"
        case .menuClosed:
            return "chevron-down-filled"
        case .menuOpen:
            return "chevron-up-filled"
        }
    }
}

// MARK: - Meta Position Enumeration
enum FDSUnitHeaderMetaPosition {
    case top
    case bottom
}

// MARK: - Right Add-On Type
enum FDSUnitHeaderRightAddOn {
    case iconButton(icon: String, action: () -> Void, isDisabled: Bool = false)
    case actionText(label: String, icon: String? = nil, action: () -> Void)
}

// MARK: - FDSUnitHeader Component
struct FDSUnitHeader: View {
    // MARK: - Properties
    let headlineText: String
    let headlineMaxLines: Int?
    let bodyText: String?
    let bodyMaxLines: Int?
    let metaText: String?
    let metaMaxLines: Int?
    let metaPosition: FDSUnitHeaderMetaPosition
    let hierarchyLevel: FDSUnitHeaderHierarchyLevel
    let rightAddOn: FDSUnitHeaderRightAddOn?
    let headlineAddOn: (type: FDSUnitHeaderInlineIconType, action: () -> Void)?
    
    // MARK: - Initializer
    init(
        headlineText: String,
        headlineMaxLines: Int? = nil,
        bodyText: String? = nil,
        bodyMaxLines: Int? = nil,
        metaText: String? = nil,
        metaMaxLines: Int? = nil,
        metaPosition: FDSUnitHeaderMetaPosition = .bottom,
        hierarchyLevel: FDSUnitHeaderHierarchyLevel = .level2,
        rightAddOn: FDSUnitHeaderRightAddOn? = nil,
        headlineAddOn: (type: FDSUnitHeaderInlineIconType, action: () -> Void)? = nil
    ) {
        self.headlineText = headlineText
        self.headlineMaxLines = headlineMaxLines
        self.bodyText = bodyText
        self.bodyMaxLines = bodyMaxLines
        self.metaText = metaText
        self.metaMaxLines = metaMaxLines
        self.metaPosition = metaPosition
        self.hierarchyLevel = hierarchyLevel
        self.rightAddOn = rightAddOn
        self.headlineAddOn = headlineAddOn
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // Left side: Text pairing
                VStack(alignment: .leading, spacing: hierarchyLevel == .level2 ? 12 : 10) {
                    if metaText != nil && metaPosition == .top {
                        metaTextView
                    }
                    
                    // Headline with optional add-on
                    if let headlineAddOn = headlineAddOn {
                        Button(action: headlineAddOn.action) {
                            headlineWithAddOnView(headlineAddOn)
                        }
                        .buttonStyle(FDSPressedState(
                            cornerRadius: 6,
                            padding: EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
                        ))
                    } else {
                        headlineTextView
                    }
                    
                    if let bodyText = bodyText {
                        bodyTextView(bodyText)
                    }
                    
                    if metaText != nil && metaPosition == .bottom {
                        metaTextView
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Right side: Right add-on
                if let rightAddOn = rightAddOn {
                    rightAddOnView(rightAddOn)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 20)
            .padding(.bottom, 8)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headlineTextView: some View {
        if let maxLines = headlineMaxLines {
            Text(headlineText)
                .modifier(HeadlineTypography(hierarchyLevel: hierarchyLevel))
                .lineLimit(maxLines)
        } else {
            Text(headlineText)
                .modifier(HeadlineTypography(hierarchyLevel: hierarchyLevel))
        }
    }
    
    @ViewBuilder
    private func headlineWithAddOnView(_ addOn: (type: FDSUnitHeaderInlineIconType, action: () -> Void)) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let maxLines = headlineMaxLines {
                Text(headlineText)
                    .modifier(HeadlineTypography(hierarchyLevel: hierarchyLevel))
                    .lineLimit(maxLines)
            } else {
                Text(headlineText)
                    .modifier(HeadlineTypography(hierarchyLevel: hierarchyLevel))
            }
            
            Image(addOn.type.iconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color("secondaryIcon"))
                .frame(width: 12, height: 12)
        }
    }
    
    @ViewBuilder
    private func bodyTextView(_ text: String) -> some View {
        if let maxLines = bodyMaxLines {
            Text(text)
                .modifier(BodyTypography(hierarchyLevel: hierarchyLevel))
                .lineLimit(maxLines)
        } else {
            Text(text)
                .modifier(BodyTypography(hierarchyLevel: hierarchyLevel))
        }
    }
    
    @ViewBuilder
    private var metaTextView: some View {
        if let metaText = metaText {
            if let maxLines = metaMaxLines {
                Text(metaText)
                    .modifier(MetaTypography(hierarchyLevel: hierarchyLevel))
                    .lineLimit(maxLines)
            } else {
                Text(metaText)
                    .modifier(MetaTypography(hierarchyLevel: hierarchyLevel))
            }
        }
    }
    
    @ViewBuilder
    private func rightAddOnView(_ addOn: FDSUnitHeaderRightAddOn) -> some View {
        switch addOn {
        case .iconButton(let icon, let action, let isDisabled):
            Button(action: {
                if !isDisabled {
                    action()
                }
            }) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(isDisabled ? Color("disabledIcon") : Color("primaryIcon"))
                    .frame(width: 24, height: 24)
            }
            .disabled(isDisabled)
            .buttonStyle(FDSPressedState(
                circle: true,
                padding: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            ))
            
        case .actionText(let label, let icon, let action):
            Button(action: action) {
                HStack(alignment: .center, spacing: 4) {
                    if let icon = icon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color("accentColor"))
                            .frame(width: 16, height: 16)
                    }
                    Text(label)
                        .modifier(ActionTextTypography(hierarchyLevel: hierarchyLevel))
                        .lineLimit(1)
                }
            }
            .buttonStyle(FDSPressedState(
                cornerRadius: 6,
                padding: EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            ))
        }
    }
}

// MARK: - Typography Modifiers

private struct HeadlineTypography: ViewModifier {
    let hierarchyLevel: FDSUnitHeaderHierarchyLevel
    
    func body(content: Content) -> some View {
        switch hierarchyLevel {
        case .level2:
            content.headline2EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
        case .level3:
            content.headline3EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
        }
    }
}

private struct BodyTypography: ViewModifier {
    let hierarchyLevel: FDSUnitHeaderHierarchyLevel
    
    func body(content: Content) -> some View {
        switch hierarchyLevel {
        case .level2:
            content.body2Typography()
                .foregroundStyle(Color("secondaryText"))
        case .level3:
            content.body3Typography()
                .foregroundStyle(Color("secondaryText"))
        }
    }
}

private struct MetaTypography: ViewModifier {
    let hierarchyLevel: FDSUnitHeaderHierarchyLevel
    
    func body(content: Content) -> some View {
        switch hierarchyLevel {
        case .level2:
            content.meta2Typography()
                .foregroundStyle(Color("secondaryText"))
        case .level3:
            content.meta3Typography()
                .foregroundStyle(Color("secondaryText"))
        }
    }
}

private struct ActionTextTypography: ViewModifier {
    let hierarchyLevel: FDSUnitHeaderHierarchyLevel
    
    func body(content: Content) -> some View {
        switch hierarchyLevel {
        case .level2:
            content.body2Typography()
                .foregroundStyle(Color("accentColor"))
        case .level3:
            content.body3Typography()
                .foregroundStyle(Color("accentColor"))
        }
    }
}

// MARK: - Button Styles


// MARK: - Unit Header Group Card Component
struct UnitHeaderGroupCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .meta4LinkTypography()
                .foregroundStyle(Color("primaryText"))
                .padding(.horizontal, 12)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .background(Color("cardBackground"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Unit Header Preview View
struct UnitHeaderPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSUnitHeader",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    UnitHeaderGroupCard(title: "Default unit header") {
                        FDSUnitHeader(
                            headlineText: "Suggested for you",
                            bodyText: "Based on people you follow",
                            metaText: "Sponsored"
                        )
                    }
                    
                    UnitHeaderGroupCard(title: "Hierarchy level 3") {
                        FDSUnitHeader(
                            headlineText: "Suggested for you",
                            bodyText: "Based on people you follow",
                            metaText: "Sponsored",
                            hierarchyLevel: .level3
                        )
                    }
                    
                    UnitHeaderGroupCard(title: "Top meta text") {
                        FDSUnitHeader(
                            headlineText: "Suggested for you",
                            metaText: "Sponsored",
                            metaPosition: .top
                        )
                    }
                    
                    UnitHeaderGroupCard(title: "Right icon button") {
                        FDSUnitHeader(
                            headlineText: "Suggested for you",
                            bodyText: "Based on people you follow",
                            rightAddOn: .iconButton(
                                icon: "dots-3-horizontal-filled",
                                action: {}
                            )
                        )
                    }
                    
                    UnitHeaderGroupCard(title: "Right action text button") {
                        FDSUnitHeader(
                            headlineText: "Suggested for you",
                            bodyText: "Based on people you follow",
                            rightAddOn: .actionText(
                                label: "See more",
                                action: {}
                            )
                        )
                    }
                    
                    UnitHeaderGroupCard(title: "Right action text with icon") {
                        FDSUnitHeader(
                            headlineText: "Suggested for you",
                            bodyText: "Based on people you follow",
                            rightAddOn: .actionText(
                                label: "Location",
                                icon: "pin-filled",
                                action: {}
                            )
                        )
                    }
                    
                    UnitHeaderGroupCard(title: "Headline text info button") {
                        FDSUnitHeader(
                            headlineText: "News",
                            bodyText: "Based on articles you've liked",
                            headlineAddOn: (
                                type: .infoButton,
                                action: {}
                            )
                        )
                    }
                    
                    UnitHeaderGroupCard(title: "Headline text see more") {
                        FDSUnitHeader(
                            headlineText: "News",
                            headlineAddOn: (
                                type: .seeMore,
                                action: {}
                            )
                        )
                    }
                    
                    UnitHeaderGroupCard(title: "Headline text expand") {
                        FDSUnitHeader(
                            headlineText: "News",
                            headlineAddOn: (
                                type: .menuClosed,
                                action: {}
                            )
                        )
                    }
                    
                    UnitHeaderGroupCard(title: "Headline text collapse") {
                        FDSUnitHeader(
                            headlineText: "News",
                            headlineAddOn: (
                                type: .menuOpen,
                                action: {}
                            )
                        )
                    }
                    
                    UnitHeaderGroupCard(title: "Long truncated headline") {
                        FDSUnitHeader(
                            headlineText: "Explore popular new products near your location and more goodies, as well as other interesting things",
                            headlineMaxLines: 2,
                            bodyText: "Based on articles you've liked",
                        )
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
    UnitHeaderPreviewView()
}


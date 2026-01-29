import SwiftUI

// MARK: - Hierarchy Level Enumeration
enum FDSListCellHierarchyLevel {
    case level3
    case level4
}

// MARK: - Left Add-On Size Enumeration
enum FDSListCellLeftAddOnSize {
    case size24
    case size32
    case size40
    case size60
    
    var value: CGFloat {
        switch self {
        case .size24: return 24
        case .size32: return 32
        case .size40: return 40
        case .size60: return 60
        }
    }
}

// MARK: - Profile Photo Type Enumeration
enum FDSListCellProfilePhotoType {
    case actor
    case nonActor
}

// MARK: - Left Add-On Type Enumeration
enum FDSListCellLeftAddOn {
    case icon(String, iconSize: CGFloat? = nil, containerSize: FDSListCellLeftAddOnSize? = nil, color: Color? = nil)
    case containedIcon(String, size: FDSListCellLeftAddOnSize? = nil, backgroundColor: Color? = nil)
    case profilePhoto(String, type: FDSListCellProfilePhotoType? = nil, size: FDSListCellLeftAddOnSize? = nil)
}

// MARK: - Right Add-On Type Enumeration
enum FDSListCellRightAddOn {
    case icon(String)
    case chevron
    case toggle(isOn: Binding<Bool>)
}

// MARK: - Headline Emphasis Enumeration
enum FDSListCellHeadlineEmphasis {
    case emphasized
    case `default`
    case deemphasized
}

// MARK: - Body Text Color Enumeration
enum FDSListCellBodyTextColor {
    case primary
    case secondary
}

// MARK: - Add-On Alignment Enumeration
enum FDSListCellAddOnAlignment {
    case center
    case top
}

// MARK: - Bottom Add-On Type Enumeration
enum FDSListCellBottomAddOn {
    case facepile(profileImages: [String], text: String)
    case button(type: FDSButtonType, label: String, action: () -> Void)
}

// MARK: - FDSListCell Component
struct FDSListCell<Destination: View>: View {
    // MARK: - Properties
    let hierarchyLevel: FDSListCellHierarchyLevel
    let headlineText: String?
    let headlineIcon: String?
    let headlineEmphasis: FDSListCellHeadlineEmphasis
    let headlineLineLimit: Int
    let bodyText: String?
    let bodyTextColor: FDSListCellBodyTextColor
    let metaText: String?
    let leftAddOn: FDSListCellLeftAddOn?
    let rightAddOn: FDSListCellRightAddOn?
    let bottomAddOn: FDSListCellBottomAddOn?
    let addOnAlignment: FDSListCellAddOnAlignment
    let showHairline: Bool
    let isDisabled: Bool
    let action: (() -> Void)?
    let destination: (() -> Destination)?
    
    // MARK: - Initializer
    init(
        hierarchyLevel: FDSListCellHierarchyLevel = .level3,
        headlineText: String? = nil,
        headlineIcon: String? = nil,
        headlineEmphasis: FDSListCellHeadlineEmphasis = .default,
        headlineLineLimit: Int = 2,
        bodyText: String? = nil,
        bodyTextColor: FDSListCellBodyTextColor = .secondary,
        metaText: String? = nil,
        leftAddOn: FDSListCellLeftAddOn? = nil,
        rightAddOn: FDSListCellRightAddOn? = nil,
        bottomAddOn: FDSListCellBottomAddOn? = nil,
        addOnAlignment: FDSListCellAddOnAlignment = .center,
        showHairline: Bool = false,
        isDisabled: Bool = false,
        action: (() -> Void)? = nil,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.hierarchyLevel = hierarchyLevel
        self.headlineText = headlineText
        self.headlineIcon = headlineIcon
        self.headlineEmphasis = headlineEmphasis
        self.headlineLineLimit = headlineLineLimit
        self.bodyText = bodyText
        self.bodyTextColor = bodyTextColor
        self.metaText = metaText
        self.leftAddOn = leftAddOn
        self.rightAddOn = rightAddOn
        self.bottomAddOn = bottomAddOn
        self.addOnAlignment = addOnAlignment
        self.showHairline = showHairline
        self.isDisabled = isDisabled
        self.action = action
        self.destination = destination
        
        assert(headlineText != nil || bodyText != nil, "FDSListCell: Either headlineText or bodyText must be provided")
    }
    
    // MARK: - Body
    var body: some View {
        if let destination = destination {
            NavigationLink {
                destination()
            } label: {
                cellContent
            }
            .buttonStyle(FDSPressedState(cornerRadius: 0))
        } else if let action = action {
            Button(action: {
                if !isDisabled {
                    action()
                }
            }) {
                cellContent
            }
            .buttonStyle(FDSPressedState(cornerRadius: 0))
            .disabled(isDisabled)
        } else {
            cellContent
        }
    }
    
    // MARK: - Cell Content
    @ViewBuilder
    private var cellContent: some View {
        HStack(alignment: hStackAlignment, spacing: cellGap) {
            if let leftAddOn = leftAddOn {
                leftAddOnView(leftAddOn)
                    .alignmentGuide(addOnAlignment == .top ? .top : .center) { d in
                        addOnAlignment == .top ? d[.top] : d[VerticalAlignment.center]
                    }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: textSpacing) {
                    if let headlineText = headlineText {
                        headlineTextView(headlineText)
                    }
                    
                    if let bodyText = bodyText {
                        bodyTextView(bodyText)
                    }
                    
                    if let metaText = metaText {
                        metaTextView(metaText)
                    }
                }
                
                if let bottomAddOn = bottomAddOn {
                    bottomAddOnView(bottomAddOn)
                        .padding(.top, 12)
                }
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let rightAddOn = rightAddOn {
                rightAddOnView(rightAddOn)
                    .alignmentGuide(addOnAlignment == .top ? .top : .center) { d in
                        addOnAlignment == .top ? d[.top] : d[VerticalAlignment.center]
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(minHeight: minHeight)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if showHairline {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        if let leftAddOn = leftAddOn {
                            Color.clear
                                .frame(width: getLeftAddOnSize(leftAddOn) + cellGap + horizontalPadding)
                        } else {
                            Color.clear
                                .frame(width: horizontalPadding)
                        }
                        
                        Rectangle()
                            .fill(Color("divider"))
                            .frame(height: 1)
                        
                        Color.clear
                            .frame(width: horizontalPadding)
                    }
                    .frame(width: geometry.size.width)
                }
                .frame(height: 1)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var hStackAlignment: VerticalAlignment {
        return addOnAlignment == .top ? .top : .center
    }
    
    private var horizontalPadding: CGFloat {
        return 12
    }
    
    private var verticalPadding: CGFloat {
        return 8
    }
    
    private var cellGap: CGFloat {
        return 12
    }
    
    private var textSpacing: CGFloat {
        switch hierarchyLevel {
        case .level3: return 10
        case .level4: return 10
        }
    }
    
    private var minHeight: CGFloat {
        return 44
    }
    
    private var defaultLeftAddOnSize: FDSListCellLeftAddOnSize {
        switch hierarchyLevel {
        case .level3: return .size40
        case .level4: return .size32
        }
    }
    
    private func containedIconSize(for containerSize: FDSListCellLeftAddOnSize) -> CGFloat {
        switch containerSize {
        case .size24: return 12
        case .size32: return 16
        case .size40: return 20
        case .size60: return 24
        }
    }
    
    private var rightIconSize: CGFloat {
        return 24
    }
    
    
    private var headlineColor: Color {
        if isDisabled {
            return Color("disabledText")
        }
        return Color("primaryText")
    }
    
    private var bodyColor: Color {
        if isDisabled {
            return Color("disabledText")
        }
        switch bodyTextColor {
        case .primary:
            return Color("primaryText")
        case .secondary:
            return Color("secondaryText")
        }
    }
    
    private var metaColor: Color {
        if isDisabled {
            return Color("disabledText")
        }
        return Color("secondaryText")
    }
    
    private var iconColor: Color {
        if isDisabled {
            return Color("disabledIcon")
        }
        return Color("primaryIcon")
    }
    
    // MARK: - Helper Methods
    
    private func getLeftAddOnSize(_ addOn: FDSListCellLeftAddOn) -> CGFloat {
        switch addOn {
        case .icon(_, let iconSize, let containerSize, _):
            let finalIconSize = iconSize ?? 20
            return containerSize?.value ?? finalIconSize
        case .containedIcon(_, let size, _):
            return (size ?? defaultLeftAddOnSize).value
        case .profilePhoto(_, _, let size):
            return (size ?? defaultLeftAddOnSize).value
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func headlineTextView(_ text: String) -> some View {
        HStack(spacing: 4) {
            switch (hierarchyLevel, headlineEmphasis) {
            case (.level3, .emphasized):
                Text(text)
                    .headline3EmphasizedTypography()
                    .foregroundStyle(headlineColor)
                    .lineLimit(headlineLineLimit)
            case (.level3, .default):
                Text(text)
                    .headline3Typography()
                    .foregroundStyle(headlineColor)
                    .lineLimit(headlineLineLimit)
            case (.level3, .deemphasized):
                Text(text)
                    .headline3DeemphasizedTypography()
                    .foregroundStyle(headlineColor)
                    .lineLimit(headlineLineLimit)
            case (.level4, .emphasized):
                Text(text)
                    .headline4EmphasizedTypography()
                    .foregroundStyle(headlineColor)
                    .lineLimit(headlineLineLimit)
            case (.level4, .default):
                Text(text)
                    .headline4Typography()
                    .foregroundStyle(headlineColor)
                    .lineLimit(headlineLineLimit)
            case (.level4, .deemphasized):
                Text(text)
                    .headline4DeemphasizedTypography()
                    .foregroundStyle(headlineColor)
                    .lineLimit(headlineLineLimit)
            }
            
            if let headlineIcon = headlineIcon {
                Image(headlineIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color("accentColor"))
                    .frame(width: 12, height: 12)
            }
        }
    }
    
    
    @ViewBuilder
    private func bodyTextView(_ text: String) -> some View {
        switch hierarchyLevel {
        case .level3:
            Text(text)
                .body3Typography()
                .foregroundStyle(bodyColor)
                .lineLimit(5)
        case .level4:
            Text(text)
                .body4Typography()
                .foregroundStyle(bodyColor)
                .lineLimit(5)
        }
    }
    
    @ViewBuilder
    private func metaTextView(_ text: String) -> some View {
        switch hierarchyLevel {
        case .level3:
            Text(text)
                .meta3Typography()
                .foregroundStyle(metaColor)
                .lineLimit(1)
        case .level4:
            Text(text)
                .meta4Typography()
                .foregroundStyle(metaColor)
                .lineLimit(1)
        }
    }
    
    @ViewBuilder
    private func leftAddOnView(_ addOn: FDSListCellLeftAddOn) -> some View {
        switch addOn {
        case .icon(let iconName, let iconSize, let containerSize, let color):
            iconAddOnView(iconName: iconName, iconSize: iconSize, containerSize: containerSize, color: color)
                
        case .containedIcon(let iconName, let size, let bgColor):
            containedIconAddOnView(iconName: iconName, size: size, bgColor: bgColor)
            
        case .profilePhoto(let imageName, let type, let size):
            profilePhotoAddOnView(imageName: imageName, type: type, size: size)
        }
    }
    
    private func iconAddOnView(iconName: String, iconSize: CGFloat?, containerSize: FDSListCellLeftAddOnSize?, color: Color?) -> some View {
        let finalIconSize = iconSize ?? 20
        let finalContainerSize = containerSize?.value ?? finalIconSize
        
        return Image(iconName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(color ?? iconColor)
            .frame(width: finalIconSize, height: finalIconSize)
            .frame(width: finalContainerSize, height: finalContainerSize, alignment: .center)
    }
    
    private func containedIconAddOnView(iconName: String, size: FDSListCellLeftAddOnSize?, bgColor: Color?) -> some View {
        let finalSize = size ?? defaultLeftAddOnSize
        let iconSize = containedIconSize(for: finalSize)
        
        return ZStack {
            Circle()
                .fill(bgColor ?? Color("secondaryButtonBackground"))
                .frame(width: finalSize.value, height: finalSize.value)
            
            Image(iconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(iconColor)
                .frame(width: iconSize, height: iconSize)
        }
    }
    
    @ViewBuilder
    private func profilePhotoAddOnView(imageName: String, type: FDSListCellProfilePhotoType?, size: FDSListCellLeftAddOnSize?) -> some View {
        let finalSize = size ?? defaultLeftAddOnSize
        let finalType = type ?? .actor
        
        if finalType == .actor {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: finalSize.value, height: finalSize.value)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(Color("mediaInnerBorder"), lineWidth: 0.5)
                )
        } else {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: finalSize.value, height: finalSize.value)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color("mediaInnerBorder"), lineWidth: 0.5)
                )
        }
    }
    
    @ViewBuilder
    private func rightAddOnView(_ addOn: FDSListCellRightAddOn) -> some View {
        switch addOn {
        case .icon(let iconName):
            Image(iconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color("secondaryIcon"))
                .frame(width: rightIconSize, height: rightIconSize)
                
        case .chevron:
            Image("chevron-right-filled")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color("secondaryIcon"))
                .frame(width: rightIconSize, height: rightIconSize)
                
        case .toggle(let isOn):
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
    }
    
    @ViewBuilder
    private func bottomAddOnView(_ addOn: FDSListCellBottomAddOn) -> some View {
        switch addOn {
        case .facepile(let profileImages, let text):
            facepileView(profileImages: profileImages, text: text)
                
        case .button(let type, let label, let action):
            FDSButton(type: type, label: label, action: action)
        }
    }
    
    private func facepileView(profileImages: [String], text: String) -> some View {
        HStack(spacing: 4) {
            // Overlapping Profile Pictures
            HStack(spacing: 0) {
                ForEach(Array(profileImages.prefix(3).enumerated()), id: \.offset) { index, imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(Color("surfaceBackground"), lineWidth: 1.5)
                        )
                        .offset(x: CGFloat(-index * 5))
                        .zIndex(Double(profileImages.prefix(3).count - index))
                }
            }
            .padding(.trailing, CGFloat(-5 * max(0, profileImages.prefix(3).count - 1)))
            
            Group {
                switch hierarchyLevel {
                case .level3:
                    Text(text)
                        .meta3Typography()
                        .foregroundStyle(Color("secondaryText"))
                case .level4:
                    Text(text)
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryText"))
                }
            }
        }
    }
}

// MARK: - FDSListCell Extension (No Destination)
extension FDSListCell where Destination == EmptyView {
    init(
        hierarchyLevel: FDSListCellHierarchyLevel = .level3,
        headlineText: String? = nil,
        headlineIcon: String? = nil,
        headlineEmphasis: FDSListCellHeadlineEmphasis = .default,
        headlineLineLimit: Int = 2,
        bodyText: String? = nil,
        bodyTextColor: FDSListCellBodyTextColor = .secondary,
        metaText: String? = nil,
        leftAddOn: FDSListCellLeftAddOn? = nil,
        rightAddOn: FDSListCellRightAddOn? = nil,
        bottomAddOn: FDSListCellBottomAddOn? = nil,
        addOnAlignment: FDSListCellAddOnAlignment = .center,
        showHairline: Bool = false,
        isDisabled: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.hierarchyLevel = hierarchyLevel
        self.headlineText = headlineText
        self.headlineIcon = headlineIcon
        self.headlineEmphasis = headlineEmphasis
        self.headlineLineLimit = headlineLineLimit
        self.bodyText = bodyText
        self.bodyTextColor = bodyTextColor
        self.metaText = metaText
        self.leftAddOn = leftAddOn
        self.rightAddOn = rightAddOn
        self.bottomAddOn = bottomAddOn
        self.addOnAlignment = addOnAlignment
        self.showHairline = showHairline
        self.isDisabled = isDisabled
        self.action = action
        self.destination = nil
        
        assert(headlineText != nil || bodyText != nil, "FDSListCell: Either headlineText or bodyText must be provided")
    }
}


// MARK: - List Cell Card Component
struct ListCellCard<Content: View>: View {
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
                .padding(12)
            
            content
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

// MARK: - List Cells Preview View
struct ListCellsPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSListCell",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    ListCellCard(title: "Basic text combinations") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "Headline only",
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Headline with body",
                                bodyText: "This is the body text that provides more details",
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Headline with body and meta",
                                bodyText: "This is the body text",
                                metaText: "2 hours ago"
                            )
                        }
                    }
                    
                    ListCellCard(title: "With left add-ons") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "Contained icon (default 40pt)",
                                bodyText: "Secondary button background",
                                leftAddOn: .containedIcon("heart-filled"),
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Contained icon (32pt)",
                                bodyText: "Medium size",
                                leftAddOn: .containedIcon("heart-filled", size: .size32),
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Icon (20pt default)",
                                bodyText: "Primary icon color",
                                leftAddOn: .icon("star-outline"),
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Icon (24pt, 32pt container)",
                                bodyText: "32pt container",
                                leftAddOn: .icon("star-outline", iconSize: 24, containerSize: .size32),
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Profile photo (default 32pt)",
                                bodyText: "Default size",
                                leftAddOn: .profilePhoto("profile1", size: .size32),
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Profile photo (default 40pt)",
                                bodyText: "Default size",
                                leftAddOn: .profilePhoto("profile1"),
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Profile photo actor (60pt)",
                                bodyText: "Circular, extra large size",
                                leftAddOn: .profilePhoto("profile1", type: .actor, size: .size60),
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Profile photo non-actor (default)",
                                bodyText: "Rounded rectangle with 12pt corner radius",
                                leftAddOn: .profilePhoto("profile1", type: .nonActor),
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Profile photo non-actor (60pt)",
                                bodyText: "Rounded rectangle, extra large",
                                leftAddOn: .profilePhoto("profile1", type: .nonActor, size: .size60)
                            )
                        }
                    }
                    
                    ListCellCard(title: "With right add-ons") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "With chevron",
                                rightAddOn: .chevron,
                                showHairline: true,
                                action: {}
                            )
                            FDSListCell(
                                headlineText: "With custom icon",
                                rightAddOn: .icon("heart-outline")
                            )
                        }
                    }
                    
                    ListCellCard(title: "Combined add-ons") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "Full featured cell",
                                bodyText: "With left and right add-ons",
                                metaText: "Just now",
                                leftAddOn: .profilePhoto("profile2"),
                                rightAddOn: .chevron,
                                showHairline: true,
                                action: {}
                            )
                            FDSListCell(
                                headlineText: "Settings item",
                                bodyText: "Tap to open settings",
                                leftAddOn: .containedIcon("settings-filled"),
                                rightAddOn: .chevron,
                                action: {}
                            )
                        }
                    }
                    
                    ListCellCard(title: "Add-on alignment") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "Center aligned (default) when the text wraps to multiple lines",
                                bodyText: "Both add-ons centered vertically",
                                leftAddOn: .containedIcon("heart-filled"),
                                rightAddOn: .chevron,
                                addOnAlignment: .center,
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Top aligned when the text wraps to multiple lines",
                                bodyText: "Both add-ons aligned to top",
                                leftAddOn: .containedIcon("heart-filled"),
                                rightAddOn: .chevron,
                                addOnAlignment: .top
                            )
                        }
                    }
                    
                    ListCellCard(title: "Hierarchy levels") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                hierarchyLevel: .level3,
                                headlineText: "Level 3 (default)",
                                bodyText: "Larger text for primary content",
                                showHairline: true
                            )
                            FDSListCell(
                                hierarchyLevel: .level4,
                                headlineText: "Level 4",
                                bodyText: "Smaller text for secondary content"
                            )
                        }
                    }
                    
                    ListCellCard(title: "Headline emphasis") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "Emphasized headline",
                                headlineEmphasis: .emphasized,
                                bodyText: "Bold and prominent",
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Default headline",
                                headlineEmphasis: .default,
                                bodyText: "Medium weight (default)",
                                showHairline: true
                            )
                            FDSListCell(
                                headlineText: "Deemphasized headline",
                                headlineEmphasis: .deemphasized,
                                bodyText: "Regular weight, more subtle"
                            )
                        }
                    }
                    
                    ListCellCard(title: "Headline with icon") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "Verified account",
                                headlineIcon: "checkmark-circle-filled",
                                bodyText: "This account has been verified",
                                leftAddOn: .profilePhoto("profile1"),
                            )
                        }
                    }
                    
                    ListCellCard(title: "Body text color") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "With headline",
                                bodyText: "Secondary body text (default)",
                                bodyTextColor: .secondary,
                                showHairline: true
                            )
                            FDSListCell(
                                bodyText: "Primary body text, no headline",
                                bodyTextColor: .primary,
                                showHairline: true
                            )
                            FDSListCell(
                                bodyText: "Secondary body text, no headline",
                                bodyTextColor: .secondary
                            )
                        }
                    }
                    
                    ListCellCard(title: "Interactive cells") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "Tappable cell",
                                bodyText: "Tap me!",
                                leftAddOn: .containedIcon("arrow-right-filled"),
                                rightAddOn: .chevron,
                                showHairline: true,
                                action: {
                                    print("Cell tapped!")
                                }
                            )
                            FDSListCell(
                                headlineText: "Another tappable cell",
                                bodyText: "I'm interactive too",
                                leftAddOn: .icon("heart-filled"),
                                rightAddOn: .chevron,
                                action: {
                                    print("Cell tapped!")
                                }
                            )
                        }
                    }
                    
                    ListCellCard(title: "Disabled state") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "Disabled cell",
                                bodyText: "All text uses disabled color",
                                metaText: "Cannot interact",
                                leftAddOn: .containedIcon("cross-filled"),
                                showHairline: true,
                                isDisabled: true,
                                action: {}
                            )
                            FDSListCell(
                                headlineText: "Normal cell for comparison",
                                bodyText: "This cell is enabled",
                                metaText: "Can interact",
                                leftAddOn: .containedIcon("checkmark-filled")
                            )
                        }
                    }
                    
                    ListCellCard(title: "Bottom add-ons") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "Waimea Bay Beach Park",
                                bodyText: "A beautiful location with stunning views",
                                leftAddOn: .containedIcon("pin-filled", size: .size60),
                                bottomAddOn: .facepile(profileImages: ["profile1", "profile2", "profile3"], text: "5 friends were here"),
                                addOnAlignment: .top,
                                showHairline: true,
                                action: {}
                            )
                            FDSListCell(
                                headlineText: "Special Event",
                                bodyText: "Join us for an amazing experience",
                                leftAddOn: .containedIcon("star-filled"),
                                bottomAddOn: .button(type: .primary, label: "RSVP", action: {
                                    print("RSVP tapped")
                                }),
                                addOnAlignment: .top,
                                action: {}
                            )
                        }
                    }
                    
                    ListCellCard(title: "Realistic examples") {
                        VStack(spacing: 0) {
                            FDSListCell(
                                headlineText: "John Smith",
                                bodyText: "Hey! How are you doing?",
                                metaText: "5m ago",
                                leftAddOn: .profilePhoto("profile3"),
                                showHairline: true,
                                action: {}
                            )
                            FDSListCell(
                                headlineText: "Notifications",
                                bodyText: "Manage your notification preferences",
                                leftAddOn: .containedIcon("notifications-filled"),
                                rightAddOn: .chevron,
                                showHairline: true,
                                action: {}
                            )
                            FDSListCell(
                                headlineText: "Privacy & Security",
                                bodyText: "Control who can see your content",
                                leftAddOn: .containedIcon("privacy-filled"),
                                rightAddOn: .chevron,
                                action: {}
                            )
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
    ListCellsPreviewView()
}


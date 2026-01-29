import SwiftUI

// MARK: - Color Assets Extension
extension Color {
    static let allColorNames: [String] = [
        "accentColor", "accentDeemphasized", "accentOnBackground", "activeDot", "activeDotOnColor",
        "activeDotOnMedia", "activeIcon", "alwaysBlack", "alwaysBlackOverlay", "alwaysTransparent",
        "alwaysWhite", "attachmentFooterBackground", "backgroundDeemphasized", "blackSolidarityPrimaryButtonBackground",
        "blackSolidarityPrimaryButtonText", "blueLink", "borderPersistentUi", "borderResponsiveUi",
        "borderUiEmphasis", "borderUiEmphasisOnMedia", "bottomSheetBackgroundDeemphasized", "bottomSheetHandle",
        "cardBackground", "cardBackgroundDark", "cardBackgroundFlat", "cardBackgroundLegacyWeb",
        "cardBackgroundOnColor", "cardBackgroundOnMedia", "cardBorder", "cardShadowLight", "cardShadowMedium",
        "cardShadowStrong", "clientBottomSheetPressed", "codeSyntaxComment", "codeSyntaxKeyword",
        "codeSyntaxMethod", "codeSyntaxNumber", "codeSyntaxOperator", "codeSyntaxString", "codeSyntaxText",
        "commentBackground", "commentBackgroundDeemphasized", "commentBackgroundOnColor", "commentBackgroundOnMedia",
        "commentThreadingLines", "commentThreadingLinesOnColor", "commentThreadingLinesOnMedia",
        "contentLiquidityIg", "datavizBluePrimary", "datavizBlueSecondary", "datavizBlueTertiary",
        "datavizChartreusePrimary", "datavizChartreuseSecondary", "datavizChartreuseTertiary",
        "datavizCyanPrimary", "datavizCyanSecondary", "datavizCyanTertiary", "datavizFuchsiaPrimary",
        "datavizFuchsiaSecondary", "datavizFuchsiaTertiary", "datavizGreenPrimary", "datavizGreenSecondary",
        "datavizGreenTertiary", "datavizOrangePrimary", "datavizOrangeSecondary", "datavizOrangeTertiary",
        "datavizPurplePrimary", "datavizPurpleSecondary", "datavizPurpleTertiary", "datavizRedPrimary",
        "datavizRedSecondary", "datavizRedTertiary", "datavizTealPrimary", "datavizTealSecondary",
        "datavizTealTertiary", "datavizYellowPrimary", "datavizYellowSecondary", "datavizYellowTertiary",
        "decorativeChatBlue", "decorativeIconBlue", "decorativeIconGreen", "decorativeIconPink",
        "decorativeIconPurple", "decorativeIconRed", "decorativeIconReels", "decorativeIconTeal",
        "decorativeIconWhatsapp", "decorativeIconYellow", "deemphasizedButtonIcon", "deviceBackground",
        "deviceIcon", "deviceIconOnColor", "deviceIconOnMedia", "deviceText", "deviceTextOnColor",
        "deviceTextOnMedia", "disabledButtonBackground", "disabledButtonBackgroundGrowth", "disabledIcon",
        "disabledIconOnColor", "disabledIconOnMedia", "disabledText", "disabledTextOnColor",
        "disabledTextOnMedia", "dismissBackground", "divider", "dividerOnColor", "dividerOnMedia",
        "dotBadgeBlue", "eventDate", "fbLitehighlight", "fbLitewash", "fbLogo", "fbWordmark",
        "fbliteRtcAnswerBackground", "fbliteRtcDismissBackground", "footerBackground", "glimmerBaseOpaque",
        "glimmerHighContrastBaseOpaque", "glimmerHighContrastButtonPressed", "glimmerIndex0",
        "glimmerIndex1", "glimmerIndex2", "glimmerIndex3", "glimmerIndex4", "hiddenCommentOverlay",
        "highContrastButtonPressed", "hostedViewSelectedState", "hovered", "icon", "iconOnMedia",
        "inactiveDot", "inactiveDotOnColor", "inactiveDotOnMedia", "inputBarBackground",
        "inputInactiveInnerBorder", "instantFeedbackBorder", "instantFeedbackShadow",
        "lastActiveStateBackground", "lastActiveStateText", "legacyTooltipBackground", "like",
        "linkOnColor", "linkOnMedia", "live", "logo", "love", "mapHighlightBackground",
        "mapHighlightBorder", "mediaHovered", "mediaInnerBorder", "mediaPressed", "metaIcon",
        "metaIconOnColor", "metaIconOnMedia", "metaText", "metaTextOnColor", "metaTextOnMedia",
        "navBarBackground", "negative", "negativeDeemphasized", "newNotificationBackground",
        "nonMediaHovered", "nonMediaPressed", "nonMediaPressedOnDark", "notificationBackground",
        "notificationBadge", "notificationCircleBlue", "notificationCircleFbPay", "notificationCircleGray",
        "notificationCircleGreen", "notificationCircleOrange", "notificationCirclePink",
        "notificationCirclePurple", "notificationCircleRed", "notificationCircleTeal",
        "notificationCircleYellow", "optimisticPostTint", "overlayOnMedia", "overlayOnMediaExtraLight",
        "overlayOnMediaLight", "overlayOnSurface", "persistentCtaShadow", "persistentUi",
        "placeholderIcon", "placeholderIconOnColor", "placeholderIconOnMedia", "placeholderImage",
        "placeholderTextDefault", "placeholderTextOnColor", "placeholderTextOnMedia", "popoverBackground",
        "positive", "positiveDeemphasized", "postTint", "pressed", "primaryButtonBackground",
        "primaryButtonBackgroundOnColor", "primaryButtonBackgroundOnMedia", "primaryButtonIcon",
        "primaryButtonIconOnColor", "primaryButtonIconOnMedia", "primaryButtonText",
        "primaryButtonTextOnColor", "primaryButtonTextOnMedia", "primaryDeemphasizedButtonBackground",
        "primaryDeemphasizedButtonIcon", "primaryDeemphasizedButtonText", "primaryIcon",
        "primaryIconOnColor", "primaryIconOnMedia", "primaryText", "primaryTextOnColor",
        "primaryTextOnMedia", "progressRingBlueBackground", "progressRingBlueForeground",
        "progressRingDisabledBackground", "progressRingDisabledForeground", "progressRingNeutralBackground",
        "progressRingNeutralForeground", "progressRingOnColorBackground", "progressRingOnColorForeground",
        "progressRingOnMediaBackground", "progressRingOnMediaForeground", "progressRingWarningBackground",
        "progressRingWarningForeground", "ratingStarActive", "ratingStarActiveOnColor",
        "ratingStarActiveOnMedia", "reactionAnger", "reactionHaha", "reactionLike", "reactionLove",
        "reactionSorry", "reactionSupport", "reactionWow", "responsiveUi", "secondaryButtonBackground",
        "secondaryButtonBackgroundFloating", "secondaryButtonBackgroundOnColor", "secondaryButtonBackgroundOnColorDeprecated",
        "secondaryButtonBackgroundOnMedia", "secondaryButtonIcon", "secondaryButtonIconOnColor",
        "secondaryButtonIconOnMedia", "secondaryButtonPressed", "secondaryButtonText",
        "secondaryButtonTextOnColor", "secondaryButtonTextOnMedia", "secondaryIcon", "secondaryIconOnColor",
        "secondaryIconOnMedia", "secondaryText", "secondaryTextOnColor", "secondaryTextOnMedia",
        "seeLessSelectedSubtopic", "seeMoreSelectedSubtopic", "seen", "shadowPersistentUi",
        "shadowResponsiveUi", "shadowTextAndIconOnMedia", "shadowTextAndIconOnOverlayExtraLight",
        "shadowUiEmphasis", "sheetBackgroundDeemphasized", "stepperActive", "stepperInactive",
        "storySeen", "storyUnseen", "strongSecondary", "surfaceBackground", "switchCheckedBackgroundColorAndroid",
        "switchCheckedBackgroundColorIos", "switchCheckedHandleFillColorAndroid", "switchCheckedHandleFillColorIos",
        "switchDisabledBackgroundColor", "switchDisabledHandleFillColor", "switchUncheckedBackgroundColor",
        "switchUncheckedHandleFillColor", "temporarydisabledButtonBackgroundGrowth", "text",
        "textHighlight", "textInputActiveInnerBorder", "textInputActiveOuterBorder", "textInputActiveText",
        "textInputBarBackground", "textInputBarBackgroundOnColor", "textInputBarBackgroundOnDeemphasized",
        "textInputBarBackgroundOnMedia", "textInputInactiveInnerBorder", "textInputInactiveOuterBorder",
        "threadingLines", "threadingLinesOnColor", "toggleActiveBackground", "toggleActiveIcon",
        "toggleActiveText", "tooltipBackground", "tooltipShadow", "tooltipText", "ufiTrayIconButtonBackground",
        "uiEmphasis", "uncheckedBackgroundColor", "verifiedBadge", "verifiedBadgeOnColor",
        "verifiedBadgeOnMedia", "viewSelectedState", "warning", "wash", "webLegacyTooltipBackground",
        "webWash", "wow"
    ]
}

// MARK: - Colors Preview View
struct ColorsPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.adaptive(minimum: 140), spacing: 8, alignment: .top)
    ]
    
    private var filteredColors: [String] {
        if searchText.isEmpty {
            return Color.allColorNames
        } else {
            return Color.allColorNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Colors",
                backAction: { dismiss() }
            )
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredColors, id: \.self) { colorName in
                        ColorCard(colorName: colorName)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Color Card Component
struct ColorCard: View {
    let colorName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Color swatch
            Rectangle()
                .fill(Color(colorName))
                .frame(height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("borderUiEmphasis"), lineWidth: 1)
                )
                .cornerRadius(12)
            
            // Color name
            VStack(alignment: .center, spacing: 4) {
                Text(colorName)
                    .meta4LinkTypography()
                    .foregroundStyle(Color("primaryText"))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ColorsPreviewView()
}

import SwiftUI

// MARK: - FDSTab Protocol

protocol FDSTab {
    var iconFilled: String { get }
    var iconOutline: String { get }
    var usesDarkTabBar: Bool { get }
}

// MARK: - FDSTabBar Helper

class FDSTabBarHelper: ObservableObject {
    @Published var hideTabBar: Bool = false
    @Published var scrollToTopTrigger: UUID = UUID()
    @Published var activeHideSources: Int = 0
    // Temporarily suppress scroll-driven hide when performing programmatic scrolls
    @Published var suppressScrollHideUntil: Date? = nil
    
    // Context provided by Home tab
    @Published var isHomeTabActive: Bool = false
    
    // Context for Reels tab
    @Published var isReelsTabActive: Bool = false
    @Published var currentReelIndex: Int? = nil
    
    // MARK: - Suppressors
    func suppressScrollHide(for duration: TimeInterval = 0.8) {
        suppressScrollHideUntil = Date().addingTimeInterval(duration)
    }
    
    var isScrollHideSuppressed: Bool {
        if let until = suppressScrollHideUntil { return Date() < until }
        return false
    }
    
    func incrementHideSources() {
        activeHideSources = max(0, activeHideSources + 1)
    }
    
    func decrementHideSources() {
        activeHideSources = max(0, activeHideSources - 1)
    }
}

// MARK: - Hide Tab Bar Modifier

fileprivate struct HideFDSTabBarModifier: ViewModifier {
    var status: Bool
    @EnvironmentObject private var helper: FDSTabBarHelper
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if status { helper.incrementHideSources() }
            }
            .onChange(of: status, initial: false) { oldValue, newValue in
                if oldValue == newValue { return }
                if newValue { helper.incrementHideSources() } else { helper.decrementHideSources() }
            }
            .onDisappear {
                if status { helper.decrementHideSources() }
            }
    }
}

extension View {
    func hideFDSTabBar(_ status: Bool) -> some View {
        self
            .modifier(HideFDSTabBarModifier(status: status))
    }
    
    /// Automatically hides tab bar on scroll down, shows on scroll up
    /// Apply this modifier to your ScrollView
    func hideTabBarOnScroll(threshold: CGFloat = 50) -> some View {
        self
            .modifier(HideTabBarOnScrollModifier(threshold: threshold))
    }
    
    /// Automatically hides tab bar on scroll down, shows on scroll up, with auto-show on dwell
    /// Apply this modifier to your ScrollView
    func hideTabBarOnScrollWithDwell(threshold: CGFloat = 50, dwellTime: TimeInterval = 1.5) -> some View {
        self
            .modifier(HideTabBarOnScrollWithDwellModifier(threshold: threshold, dwellTime: dwellTime))
    }
}

// MARK: - Hide Tab Bar On Scroll Modifier

fileprivate struct HideTabBarOnScrollModifier: ViewModifier {
    let threshold: CGFloat
    @EnvironmentObject private var helper: FDSTabBarHelper
    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var isScrollHidden: Bool = false
    @State private var isInitialized: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scrollPosition($scrollPosition)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { oldValue, newValue in
                // Ignore programmatic scrolls while suppressed
                if helper.isScrollHideSuppressed {
                    lastScrollOffset = newValue
                    return
                }
                // Initialize baseline to avoid large first delta
                if !isInitialized {
                    lastScrollOffset = newValue
                    isInitialized = true
                }
                
                // Always show tab bar when at the top (scroll position <= 0)
                if newValue <= 0 {
                    if isScrollHidden {
                        isScrollHidden = false
                        helper.decrementHideSources()
                    }
                    lastScrollOffset = newValue
                    return
                }
                
                let delta = newValue - lastScrollOffset
                
                // Scrolling down (positive delta) - hide tab bar (toggle once)
                if delta > threshold && !isScrollHidden {
                    isScrollHidden = true
                    helper.incrementHideSources()
                }
                // Scrolling up (negative delta) - show tab bar (toggle once)
                else if delta < -threshold && isScrollHidden {
                    isScrollHidden = false
                    helper.decrementHideSources()
                }
                
                lastScrollOffset = newValue
            }
            .onChange(of: helper.scrollToTopTrigger) { _, _ in
                withAnimation(.swapShuffleIn(MotionDuration.shortIn)) {
                    scrollPosition.scrollTo(edge: .top)
                }
                if isScrollHidden {
                    isScrollHidden = false
                    helper.decrementHideSources()
                }
            }
            .onDisappear {
                if isScrollHidden {
                    isScrollHidden = false
                    helper.decrementHideSources()
                }
            }
    }
}

// MARK: - Hide Tab Bar On Scroll With Dwell Modifier

fileprivate struct HideTabBarOnScrollWithDwellModifier: ViewModifier {
    let threshold: CGFloat
    let dwellTime: TimeInterval
    @EnvironmentObject private var helper: FDSTabBarHelper
    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var isScrollHidden: Bool = false
    @State private var isInitialized: Bool = false
    @State private var scrollStopTimer: Timer?
    @State private var autoShowTimer: Timer?
    
    func body(content: Content) -> some View {
        content
            .scrollPosition($scrollPosition)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { oldValue, newValue in
                // Ignore programmatic scrolls while suppressed
                if helper.isScrollHideSuppressed {
                    lastScrollOffset = newValue
                    autoShowTimer?.invalidate()
                    return
                }
                // Initialize baseline to avoid large first delta
                if !isInitialized {
                    lastScrollOffset = newValue
                    isInitialized = true
                }
                
                // Detect scrolling activity
                if oldValue != newValue {
                    // Cancel existing timers
                    scrollStopTimer?.invalidate()
                    autoShowTimer?.invalidate()
                    
                    // Start new timer to detect when scrolling stops
                    scrollStopTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                        // If tab bar is hidden, start auto-show timer
                        if isScrollHidden {
                            autoShowTimer = Timer.scheduledTimer(withTimeInterval: dwellTime, repeats: false) { _ in
                                withAnimation(.swapShuffleIn(MotionDuration.shortIn)) {
                                    isScrollHidden = false
                                    helper.decrementHideSources()
                                }
                            }
                        }
                    }
                }
                
                // Always show tab bar when at the top (scroll position <= 0)
                if newValue <= 0 {
                    if isScrollHidden {
                        isScrollHidden = false
                        helper.decrementHideSources()
                    }
                    autoShowTimer?.invalidate()
                    lastScrollOffset = newValue
                    return
                }
                
                let delta = newValue - lastScrollOffset
                
                // Scrolling down (positive delta) - hide tab bar
                if delta > threshold && !isScrollHidden {
                    isScrollHidden = true
                    helper.incrementHideSources()
                }
                // Scrolling up (negative delta) - show tab bar
                else if delta < -threshold && isScrollHidden {
                    isScrollHidden = false
                    helper.decrementHideSources()
                    autoShowTimer?.invalidate()
                }
                
                lastScrollOffset = newValue
            }
            .onChange(of: helper.scrollToTopTrigger) { _, _ in
                withAnimation(.swapShuffleIn(MotionDuration.shortIn)) {
                    scrollPosition.scrollTo(edge: .top)
                }
                if isScrollHidden {
                    isScrollHidden = false
                    helper.decrementHideSources()
                }
                autoShowTimer?.invalidate()
            }
            .onDisappear {
                if isScrollHidden {
                    isScrollHidden = false
                    helper.decrementHideSources()
                }
                scrollStopTimer?.invalidate()
                scrollStopTimer = nil
                autoShowTimer?.invalidate()
                autoShowTimer = nil
            }
    }
}

// MARK: - FDSTabBar Configuration

struct FDSTabBarConfig {
    var activeIconColor: Color = Color("primaryButtonBackground")
    var inactiveIconColor: Color = Color("secondaryIcon")
    var selectionColor: Color = Color("primaryButtonBackground")
    var selectionColorBackground: Color = Color("accentDeemphasized")
    var backgroundColor: Color = Color("navBarBackground")
    var tabAnimation: Animation = .swapShuffleIn(MotionDuration.extraExtraShortIn)
    var insetAmount: CGFloat = 4
    var hPadding: CGFloat = 12
    var bPadding: CGFloat = -12
    var height: CGFloat = 52
}

// MARK: - FDSTabView

struct FDSTabView<Content: View, Value: CaseIterable & Hashable & FDSTab>: View where Value.AllCases: RandomAccessCollection {
    private var config: FDSTabBarConfig
    @Binding private var selection: Value
    private var content: (Value, CGFloat) -> Content
    
    init(
        config: FDSTabBarConfig = .init(),
        selection: Binding<Value>,
        @ViewBuilder content: @escaping (Value, CGFloat) -> Content
    ) {
        self.config = config
        self._selection = selection
        self.content = content
    }
    
    @State private var tabBarSize: CGSize = .zero
    @StateObject private var helper: FDSTabBarHelper = .init()
    @Namespace private var glassNamespace
    
    var body: some View {
        let isFloating = FloatingTabBarSettings.shared.isEnabled
        
        ZStack(alignment: .bottom) {
            // Keep all tabs mounted to preserve state/scroll; only hide/show
            ForEach(Value.allCases, id: \.hashValue) { tab in
                content(tab, tabBarSize.height)
                    .opacity(selection == tab ? 1 : 0)
                    .allowsHitTesting(selection == tab)
                    .accessibilityHidden(selection != tab)
            }
            
            Group {
                if selection.usesDarkTabBar {
                    FDSTabBar(config: config, activeTab: $selection, glassNamespace: glassNamespace)
                        .environment(\.colorScheme, .dark)
                } else {
                    FDSTabBar(config: config, activeTab: $selection, glassNamespace: glassNamespace)
                }
            }
            .padding(.horizontal, isFloating ? config.hPadding : 0)
                .padding(.bottom, isFloating ? config.bPadding : 0)
                .onGeometryChange(for: CGSize.self, of: { $0.size }) { newValue in
                    tabBarSize = newValue
                }
                .onChange(of: helper.activeHideSources, initial: true) { _, newCount in
                    let shouldHide = newCount > 0
                    withAnimation(shouldHide ? .swapShuffleOut(MotionDuration.shortOut) : .swapShuffleIn(MotionDuration.shortIn)) {
                        helper.hideTabBar = shouldHide
                    }
                }
                .onChange(of: selection, initial: true) { _, newValue in
                    // Best-effort detection of home and reels tabs
                    let tabName = String(describing: newValue).lowercased()
                    helper.isHomeTabActive = tabName.contains("home")
                    helper.isReelsTabActive = tabName.contains("reels")
                }
                .offset(y: helper.hideTabBar ? (tabBarSize.height + 100) : (isFloating ? 0 : 8))
        }
        .environmentObject(helper)
    }
}

// MARK: - Glass Effect Helper

extension View {
    @ViewBuilder
    fileprivate func applyGlassEffectIfAvailable(id: String, namespace: Namespace.ID) -> some View {
        if #available(iOS 26.0, *), GlassEffectSettings.shared.isEnabled {
            self
                .glassEffect()
                .glassEffectID(id, in: namespace)
        } else {
            self
        }
    }
    
    @ViewBuilder
    fileprivate func conditionalShadow(isFloating: Bool) -> some View {
        if #available(iOS 26.0, *), GlassEffectSettings.shared.isEnabled {
            self
        } else {
            if isFloating {
                self.persistentUIShadow(cornerRadius: 100)
            } else {
                self
            }
        }
    }
}

// MARK: - FDSTabBar

fileprivate struct FDSTabBar<Value: CaseIterable & Hashable & FDSTab>: View where Value.AllCases: RandomAccessCollection {
    var config: FDSTabBarConfig
    @Binding var activeTab: Value
    var glassNamespace: Namespace.ID
    @EnvironmentObject private var helper: FDSTabBarHelper
    @Environment(\.colorScheme) private var colorScheme
    
    private var activeIconColor: Color {
        colorScheme == .dark ? Color("secondaryButtonIcon") : config.activeIconColor
    }
    private var selectionColorBackground: Color {
        colorScheme == .dark ? Color("secondaryButtonBackground") : config.selectionColorBackground
    }
    
    private var allTabs: [Value] {
        Array(Value.allCases)
    }
    
    private var lastTabIndex: Int {
        allTabs.count - 1
    }
    
    var body: some View {
        let _ = activeTab // Force immediate evaluation
        
        tabBarContent
    }
    
    @ViewBuilder
    private var tabBarContent: some View {
        let isFloating = FloatingTabBarSettings.shared.isEnabled
        let content = HStack(spacing: 0) {
            ForEach(Array(allTabs.enumerated()), id: \.element.hashValue) { index, tab in
                tabButton(for: tab, at: index)
            }
        }
        .padding(.horizontal, isFloating ? config.insetAmount : 0)
        .frame(height: config.height)
        .background {
            if #available(iOS 26.0, *), GlassEffectSettings.shared.isEnabled {
                Color.clear
            } else {
                if isFloating {
                    Capsule()
                        .fill(Color("navBarBackground"))
                } else {
                    Rectangle()
                        .fill(Color("navBarBackground"))
                }
            }
        }
        
        if isFloating {
            content
                .clipShape(Capsule())
                .applyGlassEffectIfAvailable(id: "maintabbar", namespace: glassNamespace)
                .conditionalShadow(isFloating: true)
        } else {
            // Non-floating mode: rectangle shape with optional glass effect
            if #available(iOS 26.0, *), GlassEffectSettings.shared.isEnabled {
                // When glass is enabled, apply it to the whole container including extension
                content
                    .clipShape(Rectangle())
                    .background(alignment: .top) {
                        // Background that extends down to cover safe area with glass
                        Rectangle()
                            .fill(.clear)
                            .frame(height: config.height + 100)
                            .glassEffect(.regular, in: .rect)
                    }
                    .overlay(alignment: .top) {
                        // Subtle top border
                        Rectangle()
                            .fill(Color("borderPersistentUi"))
                            .frame(height: 0.5)
                    }
            } else {
                content
                    .clipShape(Rectangle())
                    .conditionalShadow(isFloating: false)
                    .background(alignment: .top) {
                        // Background that extends down to cover safe area
                        Color("navBarBackground")
                            .frame(height: config.height + 100)
                    }
                    .overlay(alignment: .top) {
                        // Subtle top border
                        Rectangle()
                            .fill(Color("borderPersistentUi"))
                            .frame(height: 0.5)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func tabButton(for tab: Value, at index: Int) -> some View {
        let isActive = activeTab == tab
        let isFloating = FloatingTabBarSettings.shared.isEnabled
        
        Button(action: {
            guard activeTab != tab else {
                // Tapping the selected tab triggers scroll to top
                helper.scrollToTopTrigger = UUID()
                return
            }
            withAnimation(.swapShuffleIn(MotionDuration.extraShortIn)) {
                activeTab = tab
            }
        }) {
            VStack(spacing: 0) {
                if !isFloating && isActive {
                    // Top underline for non-floating selected state
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: 2,
                        bottomTrailingRadius: 2,
                        style: .continuous
                    )
                    .fill(config.activeIconColor)
                    .frame(height: 3)
                    .transition(.opacity)
                } else if !isFloating {
                    // Spacer to maintain consistent height
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 3)
                }
                
                Image(isActive ? tab.iconFilled : tab.iconOutline)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(isActive ? activeIconColor : config.inactiveIconColor)
                    .contentTransition(.identity)
                    .contentShape(Rectangle())
                    .background {
                        if isActive && isFloating {
                            if #available(iOS 26.0, *), GlassEffectSettings.shared.isEnabled {
                                // No background pill when glass effect is enabled
                                EmptyView()
                            } else {
                                Capsule()
                                    .fill(selectionColorBackground)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .id("\(tab.hashValue)-\(isActive)")
            }
        }
        .buttonStyle(FDSPressedState(cornerRadius: isFloating ? config.height / 2 : 0, scale: isFloating ? .small : .none))
        .padding(.vertical, isFloating ? config.insetAmount : 0)
    }
}

// MARK: - Preview Example

enum PreviewAppTab: String, CaseIterable, FDSTab {
    case home = "Home"
    case reels = "Reels"
    case marketplace = "Marketplace"
    case notifications = "Notifications"
    case more = "More"
    
    var iconFilled: String {
        switch self {
        case .home: "news-feed-home-filled"
        case .reels: "app-facebook-reels-filled"
        case .marketplace: "marketplace-filled"
        case .notifications: "notifications-filled"
        case .more: "more-filled"
        }
    }
    
    var iconOutline: String {
        switch self {
        case .home: "news-feed-home-outline"
        case .reels: "app-facebook-reels-outline"
        case .marketplace: "marketplace-outline"
        case .notifications: "notifications-outline"
        case .more: "more-outline"
        }
    }
    
    var usesDarkTabBar: Bool {
        self == .reels
    }
}

struct FDSTabBarPreview: View {
    @State private var activeTab: PreviewAppTab = .home
    
    var body: some View {
        FDSTabView(selection: $activeTab) { tab, tabHeight in
            NavigationStack {
                VStack {
                    Spacer()
                    
                    Text(tab.rawValue)
                        .headline1EmphasizedTypography()
                        .foregroundStyle(Color("primaryText"))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("surfaceBackground"))
                .safeAreaPadding(.bottom, tabHeight)
            }
        }
    }
}

struct FDSTabBarPreviewWithHiding: View {
    @State private var activeTab: PreviewAppTab = .home
    @State private var hideTabBar: Bool = false
    
    var body: some View {
        FDSTabView(selection: $activeTab) { tab, tabHeight in
            NavigationStack {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text(tab.rawValue)
                        .headline1EmphasizedTypography()
                        .foregroundStyle(Color("primaryText"))
                    
                    FDSButton(
                        type: .secondary,
                        label: hideTabBar ? "Show tab bar" : "Hide tab bar",
                        size: .medium,
                        widthMode: .constrained
                    ) {
                        hideTabBar.toggle()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("surfaceBackground"))
                .safeAreaPadding(.bottom, tabHeight)
            }
            .hideFDSTabBar(hideTabBar)
        }
    }
}

struct FDSTabBarPreviewWithScroll: View {
    @State private var activeTab: PreviewAppTab = .home
    
    var body: some View {
        FDSTabView(selection: $activeTab) { tab, tabHeight in
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Scroll down to hide tab bar")
                                .headline3EmphasizedTypography()
                                .foregroundStyle(Color("primaryText"))
                            Text("Tap the selected tab to scroll to top")
                                .body3Typography()
                                .foregroundStyle(Color("secondaryText"))
                        }
                        .padding(.top, 20)
                        
                        ForEach(0..<30) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Item \(index + 1)")
                                    .headline4EmphasizedTypography()
                                    .foregroundStyle(Color("primaryText"))
                                Text("Scroll to see the tab bar hide and show")
                                    .body3Typography()
                                    .foregroundStyle(Color("secondaryText"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color("cardBackground"))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 16)
                    .safeAreaPadding(.bottom, tabHeight)
                }
                .hideTabBarOnScroll()
                .background(Color("surfaceBackground"))
            }
        }
    }
}

// MARK: - Preview

#Preview("Basic") {
    FDSTabBarPreview()
}

#Preview("With manual hiding") {
    FDSTabBarPreviewWithHiding()
}

#Preview("With scrollaway") {
    FDSTabBarPreviewWithScroll()
}


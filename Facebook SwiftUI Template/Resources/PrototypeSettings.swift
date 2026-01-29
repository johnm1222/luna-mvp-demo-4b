import SwiftUI

// MARK: - Glass Effect Settings
@Observable
class GlassEffectSettings {
    static let shared = GlassEffectSettings()
    var isEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "glassEffectEnabled")
        }
    }
    
    private init() {
        // Load from UserDefaults if it has been explicitly set before
        if UserDefaults.standard.object(forKey: "glassEffectEnabled") != nil {
            self.isEnabled = UserDefaults.standard.bool(forKey: "glassEffectEnabled")
        }
    }
}

// MARK: - Floating Tab Bar Settings
@Observable
class FloatingTabBarSettings {
    static let shared = FloatingTabBarSettings()
    var isEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "floatingTabBarEnabled")
        }
    }
    
    private init() {
        // Load from UserDefaults if it has been explicitly set before
        if UserDefaults.standard.object(forKey: "floatingTabBarEnabled") != nil {
            self.isEnabled = UserDefaults.standard.bool(forKey: "floatingTabBarEnabled")
        } else {
            // Default to true
            self.isEnabled = true
        }
    }
}

struct PrototypeSettings: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showTouchVisualizer = TouchSettings.shared.isEnabled
    @State private var glassEffectEnabled = GlassEffectSettings.shared.isEnabled
    @State private var floatingTabBarEnabled = FloatingTabBarSettings.shared.isEnabled
    
    private func resetPrototypeSettings() {
        glassEffectEnabled = false
        GlassEffectSettings.shared.isEnabled = false
        showTouchVisualizer = false
        TouchSettings.shared.isEnabled = false
        floatingTabBarEnabled = true
        FloatingTabBarSettings.shared.isEnabled = true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Prototype settings",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                // Settings Section

                VStack(spacing: 0) {
                    FDSUnitHeader(
                        headlineText: "Settings",
                        rightAddOn: .actionText(
                            label: "Reset",
                            action: {
                                resetPrototypeSettings()
                            }
                        )
                    )
                    VStack(spacing: 0) {
                        FDSListCell(
                            headlineText: "Liquid glass effect",
                            bodyText: glassEffectEnabled ? "On" : "Off",
                            leftAddOn: .icon("water-outline", iconSize: 24),
                            rightAddOn: .toggle(isOn: $glassEffectEnabled),
                            action: {}
                        )
                        .onChange(of: glassEffectEnabled) { _, newValue in
                            GlassEffectSettings.shared.isEnabled = newValue
                        }
                        FDSListCell(
                            headlineText: "Enable floating tab bar",
                            bodyText: floatingTabBarEnabled ? "On" : "Off",
                            leftAddOn: .icon("sidebar-down-blank-outline", iconSize: 24),
                            rightAddOn: .toggle(isOn: $floatingTabBarEnabled),
                            action: {}
                        )
                        .onChange(of: floatingTabBarEnabled) { _, newValue in
                            FloatingTabBarSettings.shared.isEnabled = newValue
                        }
                        FDSListCell(
                            headlineText: "Show touches",
                            bodyText: showTouchVisualizer ? "On" : "Off",
                            leftAddOn: .icon("poke-outline", iconSize: 24),
                            rightAddOn: .toggle(isOn: $showTouchVisualizer),
                            action: {}
                        )
                        .onChange(of: showTouchVisualizer) { _, newValue in
                            TouchSettings.shared.isEnabled = newValue
                        }
                    }

                // Foundations Section

                    FDSUnitHeader(
                        headlineText: "Foundations"
                    )
                    VStack(spacing: 0) {
                        FDSListCell(
                            headlineText: "Colors",
                            leftAddOn: .icon("palette-outline", iconSize: 24),
                            rightAddOn: .chevron
                        ) {
                            ColorsPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "Icons",
                            leftAddOn: .icon("photo-square-outline", iconSize: 24),
                            rightAddOn: .chevron
                        ) {
                            IconsPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "Typography",
                            leftAddOn: .icon("text-outline", iconSize: 24),
                            rightAddOn: .chevron
                        ) {
                            TypographyPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "Motion",
                            leftAddOn: .icon("text-animation-outline", iconSize: 24),
                            rightAddOn: .chevron
                        ) {
                            MotionPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "Shadows",
                            leftAddOn: .icon("paper-stack-outline", iconSize: 24),
                            rightAddOn: .chevron
                        ) {
                            ShadowPreviewView()
                                .hideFDSTabBar(true)
                        }
                    }
                }
                
                // Components Section

                VStack(spacing: 0) {
                    FDSUnitHeader(
                        headlineText: "Components"
                    )
                    
                    VStack(spacing: 0) {
                        FDSListCell(
                            headlineText: "FDSButton",
                            rightAddOn: .chevron
                        ) {
                            ButtonsPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "FDSSubNavigationBar",
                            rightAddOn: .chevron
                        ) {
                            SubNavigationBarPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "FDSActionChip",
                            rightAddOn: .chevron
                        ) {
                            ActionChipsPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "FDSListCell",
                            rightAddOn: .chevron
                        ) {
                            ListCellsPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "FDSUnitHeader",
                            rightAddOn: .chevron
                        ) {
                            UnitHeaderPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "FDSIconButton",
                            rightAddOn: .chevron
                        ) {
                            IconButtonsPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "FDSNavigationBar",
                            rightAddOn: .chevron
                        ) {
                            NavigationBarPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "FDSInstantFeedback",
                            rightAddOn: .chevron
                        ) {
                            InstantFeedbackPreviewView()
                                .hideFDSTabBar(true)
                        }
                        
                        FDSListCell(
                            headlineText: "FDSComment",
                            rightAddOn: .chevron
                        ) {
                            CommentsPreviewView()
                                .hideFDSTabBar(true)
                        }
                    }
                }
            }
            .padding(.horizontal, 0)
            .padding(.top, 12)
            }
            .background(Color("surfaceBackground"))
        }
        .hideFDSTabBar(true)
    }
}

// MARK: - Preview
#Preview {
    PrototypeSettings()
        .environmentObject(FDSTabBarHelper())
}

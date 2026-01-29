//
//  FDSInstantFeedback.swift
//  Facebook SwiftUI Template
//
//  Created by Dan Lebowitz on 10/6/25.
//


import SwiftUI

// MARK: - Profile Image Type
enum FDSInstantFeedbackProfileType {
    case actor
    case nonActor
}

// MARK: - Left AddOn Type
enum FDSInstantFeedbackLeftAddOn {
    case none
    case profileImage(String, type: FDSInstantFeedbackProfileType = .actor)
    case icon(String)
}

// MARK: - FDSInstantFeedback Component
struct FDSInstantFeedback: View {
    // MARK: - Properties
    let content: String
    let actionText: String?
    let leftAddOn: FDSInstantFeedbackLeftAddOn
    let onAction: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    // MARK: - Initializer
    init(
        content: String,
        actionText: String? = nil,
        leftAddOn: FDSInstantFeedbackLeftAddOn = .profileImage("profile1", type: .actor),
        onAction: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.content = content
        self.actionText = actionText
        self.leftAddOn = leftAddOn
        self.onAction = onAction
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            // Left AddOn
            switch leftAddOn {
            case .none:
                EmptyView()
            case .profileImage(let imageName, let type):
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: type == .actor ? 16 : 8))
            case .icon(let iconName):
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color("alwaysWhite"))
            }
            
            // Content Text
            Text(content)
                .body3Typography()
                .foregroundStyle(Color("alwaysWhite"))
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action Text (Optional)
            if let actionText = actionText {
                Button(action: {
                    onAction?()
                }) {
                    Text(actionText)
                        .body3LinkTypography()
                        .foregroundStyle(Color("blueLink"))
                }
                .buttonStyle(FDSPressedState(
                    cornerRadius: 6,
                    padding: EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
                ))
            }
        }
        .colorScheme(.dark)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color("cardBackgroundDark"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("borderUiEmphasis").opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Instant Feedback Container with Animation
struct InstantFeedbackContainer: View {
    @Binding var isVisible: Bool
    let content: String
    let actionText: String?
    let leftAddOn: FDSInstantFeedbackLeftAddOn
    let onAction: (() -> Void)?
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            if isVisible {
                FDSInstantFeedback(
                    content: content,
                    actionText: actionText,
                    leftAddOn: leftAddOn,
                    onAction: {
                        // Manual dismissal via action button
                        dismissWithAnimation()
                        onAction?()
                    },
                    onDismiss: {
                        dismissWithAnimation()
                    }
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 12) // G1 Margin (12dp) above tab bar
                .offset(y: offset + dragOffset)
                .opacity(opacity)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Only allow dragging down
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                                // Linear opacity fade as user drags
                                let dragRatio = Double(value.translation.height) / 200.0
                                opacity = max(0.0, 1.0 - dragRatio)
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 50 {
                                // Drag threshold met - dismiss
                                dismissWithDrag()
                            } else {
                                // Snap back to original position
                                withAnimation(.enterIn(MotionDuration.shortIn)) {
                                    dragOffset = 0
                                    opacity = 1.0
                                }
                            }
                        }
                )
                .onTapGesture {
                    // Manual dismissal via tap
                    dismissWithAnimation()
                }
                .onAppear {
                    // Initial state: off-screen below
                    offset = 300
                    opacity = 1.0
                    
                    // Motion: Present Component In
                    // Delay: 0.5 seconds, then animate in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // ENTER_EXIT_IN with SHORT_IN duration (280ms)
                        withAnimation(.enterIn(MotionDuration.shortIn)) {
                            offset = 0
                        }
                    }
                    
                    // Auto-dismiss after 5 seconds (from initial appearance)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                        if isVisible {
                            dismissWithAutoAnimation()
                        }
                    }
                }
            }
        }
    }
    
    // Manual dismissal animation
    private func dismissWithAnimation() {
        // ENTER_EXIT_OUT with SHORT_OUT duration (200ms)
        withAnimation(.enterOut(MotionDuration.shortOut)) {
            opacity = 0
            offset = 300
        }
        
        // Update state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isVisible = false
            // Reset for next appearance
            dragOffset = 0
            opacity = 1.0
        }
    }
    
    // Auto dismissal animation (5 second delay)
    private func dismissWithAutoAnimation() {
        // ENTER_EXIT_OUT with SHORT_OUT duration (200ms)
        withAnimation(.enterOut(MotionDuration.shortOut)) {
            opacity = 0
        }
        
        // Update state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isVisible = false
            offset = 300
            dragOffset = 0
            opacity = 1.0
        }
    }
    
    // Drag dismissal animation
    private func dismissWithDrag() {
        // ENTER_EXIT_OUT with SHORT_OUT duration (200ms)
        withAnimation(.enterOut(MotionDuration.shortOut)) {
            dragOffset = 300
            opacity = 0
        }
        
        // Update state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isVisible = false
            offset = 300
            dragOffset = 0
            opacity = 1.0
        }
    }
}

// MARK: - Instant Feedback Preview View
struct InstantFeedbackPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                FDSNavigationBarCentered(
                    title: "FDSInstantFeedback",
                    backAction: { dismiss() }
                )
                
                ScrollView {
                VStack(spacing: 16) {
                    // Demo section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interactive Demo")
                            .meta4LinkTypography()
                            .foregroundStyle(Color("primaryText"))
                        
                        VStack(spacing: 12) {
                            FDSButton(
                                type: .primary,
                                label: "Show instant feedback",
                                size: .medium,
                                action: {
                                    isVisible = true
                                }
                            )
                            
                            Text("Tap the button to see the instant feedback slide up from the bottom. It will auto-dismiss after 5 seconds, or you can dismiss it by tapping 'Engage', tapping anywhere on the notification, or dragging it down.")
                                .body4Typography()
                                .foregroundStyle(Color("secondaryText"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color("cardBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("borderUiEmphasis"), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    
                    // Static examples
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Examples")
                            .meta4LinkTypography()
                            .foregroundStyle(Color("primaryText"))
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("With profile image (actor)")
                                    .body4Typography()
                                    .foregroundStyle(Color("secondaryText"))
                                
                                FDSInstantFeedback(
                                    content: "Logged in as Daniela Giménez",
                                    leftAddOn: .profileImage("profile1", type: .actor),
                                    onAction: {}
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("With profile image (nonActor)")
                                    .body4Typography()
                                    .foregroundStyle(Color("secondaryText"))
                                
                                FDSInstantFeedback(
                                    content: "Your marketplace listing has a new review",
                                    actionText: "View",
                                    leftAddOn: .profileImage("product4", type: .nonActor),
                                    onAction: {}
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("With icon")
                                    .body4Typography()
                                    .foregroundStyle(Color("secondaryText"))
                                
                                FDSInstantFeedback(
                                    content: "Your post was shared successfully",
                                    actionText: "View",
                                    leftAddOn: .icon("checkmark-circle-filled"),
                                    onAction: {}
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Without left addOn")
                                    .body4Typography()
                                    .foregroundStyle(Color("secondaryText"))
                                
                                FDSInstantFeedback(
                                    content: "Message sent",
                                    actionText: "Undo",
                                    leftAddOn: .none,
                                    onAction: {}
                                )
                            }
                        }
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
                .padding(.top, 0)
                .padding(.horizontal, 16)
            }
            .background(Color("surfaceBackground"))
            }
            
            // Animated instant feedback overlay
            InstantFeedbackContainer(
                isVisible: $isVisible,
                content: "Now is the time for all good coffee to come to the aid of me",
                actionText: "Engage",
                leftAddOn: .profileImage("profile1", type: .actor),
                onAction: {
                    print("Engage tapped")
                    isVisible = false
                }
            )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        InstantFeedbackPreviewView()
    }
}


import SwiftUI

// MARK: - Reaction Model

public struct Reaction: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let color: Color
    
    public init(id: String, title: String? = nil, color: Color) {
        self.id = id
        self.title = title ?? id.capitalized
        self.color = color
    }
    
    var imageName: String {
        return id
    }
}

// MARK: - Default Reactions

public extension Reaction {
    static let like = Reaction(id: "like-large", title: "Like", color: Color("reactionLike"))
    static let love = Reaction(id: "love-large", title: "Love", color: Color("reactionLove"))
    static let haha = Reaction(id: "haha-large", title: "Haha", color: Color("reactionHaha"))
    static let care = Reaction(id: "support-large", title: "Care", color: Color("reactionSupport"))
    static let wow = Reaction(id: "wow-large", title: "Wow", color: Color("reactionWow"))
    static let sad = Reaction(id: "sad-large", title: "Sad", color: Color("reactionSorry"))
    static let angry = Reaction(id: "angry-large", title: "Angry", color: Color("reactionAnger"))
    
    static let all: [Reaction] = [.like, .love, .care, .haha, .wow, .sad, .angry]
}

// MARK: - Reaction Picker Component

public struct ReactionPicker: View {
    let reactions: [Reaction]
    let onSelect: (Reaction) -> Void
    let onDeselect: (() -> Void)?
    @State private var selectedReaction: Reaction?
    @State private var highlightedReaction: Reaction?
    @State private var showPicker = false
    @State private var dragLocation: CGPoint = .zero
    @State private var isPressed = false
    @State private var openPickerTask: Task<Void, Never>?
    @State private var touchStartLocation: CGPoint?
    
    public init(
        reactions: [Reaction] = Reaction.all,
        onSelect: @escaping (Reaction) -> Void,
        onDeselect: (() -> Void)? = nil
    ) {
        self.reactions = reactions
        self.onSelect = onSelect
        self.onDeselect = onDeselect
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            if let selected = selectedReaction {
                let imageName = selected.id == "like-large" ? "like-filled-20" : selected.imageName
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            } else {
                Image("like-outline-20")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            
            Text(selectedReaction?.title ?? "Like")
                .body4LinkTypography()
                .contentTransition(.numericText())
        }
        .foregroundStyle(selectedReaction?.color ?? Color("secondaryText"))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("nonMediaPressed"))
                .opacity(isPressed ? 1.0 : 0.0)
        )
        .animation(.swapShuffleIn(MotionDuration.extraShortIn), value: isPressed)
        .animation(.swapShuffleIn(MotionDuration.shortIn), value: selectedReaction)
        .sensoryFeedback(.selection, trigger: selectedReaction)
        .sensoryFeedback(.selection, trigger: highlightedReaction?.id)
        .overlay(alignment: .topLeading) {
            if showPicker {
                reactionPickerOverlay
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .offset(y: highlightedReaction != nil ? -54 : -60)
            }
        }
        .onTapGesture {
            if !showPicker {
                if selectedReaction != nil {
                    selectedReaction = nil
                    onDeselect?()
                } else if let first = reactions.first {
                    selectedReaction = first
                    onSelect(first)
                }
            }
        }
        .onLongPressGesture(
            minimumDuration: 0.35,
            maximumDistance: 24,
            pressing: { pressing in
                if pressing {
                    if openPickerTask == nil {
                        // Start a cancellable timer to open the picker
                        openPickerTask = Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 350_000_000)
                            if !Task.isCancelled {
                                withAnimation(.enterIn(MotionDuration.extraShortIn)) {
                                    showPicker = true
                                }
                            }
                        }
                    }
                    if !isPressed { isPressed = true }
                } else {
                    // Cancel if touch lifted before open
                    openPickerTask?.cancel()
                    openPickerTask = nil
                    touchStartLocation = nil
                    if !showPicker { isPressed = false }
                }
            },
            perform: {}
        )
        // Removed pre-open drag tracking to avoid capturing scroll on touch-down
        // Lock scroll only after picker opens
        .highPriorityGesture(
            DragGesture(minimumDistance: showPicker ? 0 : 10000)
                .onChanged { drag in
                    guard showPicker else { return }
                    dragLocation = drag.location
                    updateHighlightedReaction(at: drag.location)
                }
                .onEnded { _ in
                    guard showPicker else { return }
                    if let highlighted = highlightedReaction {
                        selectedReaction = highlighted
                        onSelect(highlighted)
                    }
                    withAnimation(.enterOut(MotionDuration.extraShortOut)) {
                        showPicker = false
                    }
                    highlightedReaction = nil
                    isPressed = false
                },
            including: .gesture
        )
    }
    
    
    private var reactionPickerOverlay: some View {
        let containerHeight: CGFloat = highlightedReaction != nil ? 34 : 40
        
        return HStack(spacing: 6) {
            ForEach(reactions) { reaction in
                reactionView(for: reaction)
            }
        }
        .frame(height: containerHeight)
        .padding(6)
        .background {
            Capsule()
                .fill(Color("cardBackground"))
                .overlay(
                    Capsule()
                        .stroke(Color("borderUiEmphasis"), lineWidth: 1)
                )
                .shadow(
                    color: Color("shadowUiEmphasis"),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        }
        .highPriorityGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { drag in
                    dragLocation = drag.location
                    updateHighlightedReaction(at: drag.location)
                }
                .onEnded { _ in
                    if let highlighted = highlightedReaction {
                        selectedReaction = highlighted
                        onSelect(highlighted)
                    }
                    withAnimation(.enterOut(MotionDuration.extraShortOut)) {
                        showPicker = false
                    }
                    highlightedReaction = nil
                    isPressed = false
                }
        )
        .animation(.swapShuffleIn(MotionDuration.shortIn), value: highlightedReaction)
    }
    
    private func reactionView(for reaction: Reaction) -> some View {
        let isHighlighted = highlightedReaction == reaction
        let size: CGFloat = isHighlighted ? 80 : (highlightedReaction != nil ? 34 : 40)
        let frameWidth: CGFloat = isHighlighted ? 80 : (highlightedReaction != nil ? 34 : 40)
        
        return ZStack(alignment: .bottom) {
            VStack(spacing: 6) {
                if isHighlighted {
                    Text(reaction.title)
                        .body4LinkTypography()
                        .foregroundStyle(Color("primaryTextOnMedia"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color("overlayOnMedia"), in: Capsule())
                        .transition(.scale.combined(with: .opacity))
                }
                Image(reaction.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
            .offset(y: isHighlighted ? -40 : 0)
        }
        .frame(width: frameWidth, height: 40)
        .animation(.swapShuffleIn(MotionDuration.shortIn), value: isHighlighted)
        .animation(.swapShuffleIn(MotionDuration.shortIn), value: highlightedReaction)
    }
    
    private func updateHighlightedReaction(at location: CGPoint) {
        let normalSize: CGFloat = 40
        let spacing: CGFloat = 6
        let containerPadding: CGFloat = 6
        
        var reactionRanges: [(start: CGFloat, end: CGFloat, reaction: Reaction)] = []
        var currentX: CGFloat = containerPadding
        
        for (index, reaction) in reactions.enumerated() {
            let start = currentX
            let end = currentX + normalSize
            reactionRanges.append((start: start, end: end, reaction: reaction))
            
            currentX += normalSize
            if index < reactions.count - 1 {
                currentX += spacing
            }
        }
        
        let containerWidth = currentX + containerPadding
        let containerHeight: CGFloat = 52
        let overlayTop: CGFloat = -60
        let overlayBottom: CGFloat = overlayTop + containerHeight
        let extendedBottom: CGFloat = overlayBottom + 32
        
        guard location.y >= overlayTop && location.y <= extendedBottom else {
            highlightedReaction = nil
            return
        }
        
        let overlayLeft: CGFloat = 0
        let overlayRight = containerWidth
        
        guard location.x >= overlayLeft && location.x <= overlayRight else {
            highlightedReaction = nil
            return
        }
        
        let adjustedX = location.x
        
        for range in reactionRanges {
            if adjustedX >= range.start && adjustedX <= range.end {
                if highlightedReaction != range.reaction {
                    highlightedReaction = range.reaction
                }
                return
            }
        }

        var closestReaction: Reaction?
        var closestDistance = CGFloat.greatestFiniteMagnitude
        
        for range in reactionRanges {
            let center = (range.start + range.end) / 2
            let distance = abs(adjustedX - center)
            if distance < closestDistance {
                closestDistance = distance
                closestReaction = range.reaction
            }
        }
        
        if let closest = closestReaction, highlightedReaction != closest {
            highlightedReaction = closest
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ReactionPicker { reaction in
            print("Selected: \(reaction.id)")
        }
        
        Divider()
        
        // Example with custom reactions
        ReactionPicker(
            reactions: [.like, .love, .haha]
        ) { reaction in
            print("Selected: \(reaction.id)")
        }
    }
    .padding()
}


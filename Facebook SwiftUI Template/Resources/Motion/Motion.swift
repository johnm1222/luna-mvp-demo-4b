import SwiftUI
import Foundation

// MARK: - Motion Duration Constants

struct MotionDuration {
    static let extraExtraShortIn: Double = 0.1
    static let extraExtraShortOut: Double = 0.1
    
    static let extraShortIn: Double = 0.2
    static let extraShortOut: Double = 0.15
    
    static let shortIn: Double = 0.28
    static let shortOut: Double = 0.2
    
    static let mediumIn: Double = 0.4
    static let mediumOut: Double = 0.35
    
    static let longIn: Double = 0.5
    static let longOut: Double = 0.35
    
    static let extraLong: Double = 1.0
    
    static let none: Double = 0.0
}

// MARK: - Motion Types

enum MotionType: CaseIterable {
    case enterExitIn
    case enterExitOut
    case swapShuffleIn  
    case swapShuffleOut
    case moveIn
    case moveOut
    case expandCollapseIn
    case expandCollapseOut
    case passiveMoveIn
    case passiveMoveOut
    case fadeIn
    case fadeOut
    case quickMoveIn
    case quickMoveOut
    
    var controlPoints: (point1: CGPoint, point2: CGPoint) {
        switch self {
        case .enterExitIn, .swapShuffleIn:
            return (CGPoint(x: 0.14, y: 1.0), CGPoint(x: 0.34, y: 1.0))
        case .enterExitOut, .swapShuffleOut:
            return (CGPoint(x: 0.45, y: 0.1), CGPoint(x: 0.2, y: 1.0))
        case .moveIn, .moveOut, .expandCollapseIn, .expandCollapseOut:
            return (CGPoint(x: 0.17, y: 0.17), CGPoint(x: 0.0, y: 1.0))
        case .passiveMoveIn, .passiveMoveOut:
            return (CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.1, y: 1.0))
        case .fadeIn, .fadeOut:
            return (CGPoint.zero, CGPoint(x: 1.0, y: 1.0))
        case .quickMoveIn, .quickMoveOut:
            return (CGPoint(x: 0.1, y: 0.9), CGPoint(x: 0.2, y: 1.0))
        }
    }
    
    var displayName: String {
        switch self {
        case .enterExitIn: return "Enter/Exit In"
        case .enterExitOut: return "Enter/Exit Out"
        case .swapShuffleIn: return "Swap/Shuffle In"
        case .swapShuffleOut: return "Swap/Shuffle Out"
        case .moveIn: return "Move In"
        case .moveOut: return "Move Out"
        case .expandCollapseIn: return "Expand/Collapse In"
        case .expandCollapseOut: return "Expand/Collapse Out"
        case .passiveMoveIn: return "Passive Move In"
        case .passiveMoveOut: return "Passive Move Out"
        case .fadeIn: return "Fade In"
        case .fadeOut: return "Fade Out"
        case .quickMoveIn: return "Quick Move In"
        case .quickMoveOut: return "Quick Move Out"
        }
    }
}

// MARK: - SwiftUI Animation Extensions

extension Animation {
    // MARK: - Duration-based Animations
    
    static var extraExtraShort: Animation {
        .easeInOut(duration: MotionDuration.extraExtraShortIn)
    }
    
    static var extraShort: Animation {
        .easeInOut(duration: MotionDuration.extraShortIn)
    }
    
    static var short: Animation {
        .easeInOut(duration: MotionDuration.shortIn)
    }
    
    static var medium: Animation {
        .easeInOut(duration: MotionDuration.mediumIn)
    }
    
    static var long: Animation {
        .easeInOut(duration: MotionDuration.longIn)
    }
    
    static var extraLong: Animation {
        .easeInOut(duration: MotionDuration.extraLong)
    }
    
    // MARK: - Motion Type-based Animations
    
    static var enterIn: Animation {
        .easeInOut(duration: MotionDuration.shortIn)
    }
    
    static var exitOut: Animation {
        .easeInOut(duration: MotionDuration.shortOut)
    }
    
    static var move: Animation {
        .easeInOut(duration: MotionDuration.mediumIn)
    }
    
    static var passiveMove: Animation {
        .easeInOut(duration: MotionDuration.mediumOut)
    }
    
    static var fade: Animation {
        .easeInOut(duration: MotionDuration.shortIn)
    }
    
    static var quickMove: Animation {
        .easeInOut(duration: MotionDuration.extraShortIn)
    }
    
    static var expandCollapse: Animation {
        .easeInOut(duration: MotionDuration.mediumIn)
    }
    
    static var swapShuffle: Animation {
        .easeInOut(duration: MotionDuration.shortIn)
    }
    
    static func motion(_ type: MotionType, duration: Double) -> Animation {
        let points = type.controlPoints
        return .timingCurve(
            points.point1.x, points.point1.y,
            points.point2.x, points.point2.y,
            duration: duration
        )
    }
    
    // MARK: - Convenience Methods with Proper Curves
    
    static func enterIn(_ duration: Double) -> Animation {
        .motion(.enterExitIn, duration: duration)
    }
    
    static func enterOut(_ duration: Double) -> Animation {
        .motion(.enterExitOut, duration: duration)
    }
    
    static func swapShuffleIn(_ duration: Double) -> Animation {
        .motion(.swapShuffleIn, duration: duration)
    }
    
    static func swapShuffleOut(_ duration: Double) -> Animation {
        .motion(.swapShuffleOut, duration: duration)
    }
    
    static func moveIn(_ duration: Double) -> Animation {
        .motion(.moveIn, duration: duration)
    }
    
    static func moveOut(_ duration: Double) -> Animation {
        .motion(.moveOut, duration: duration)
    }
    
    static func expandIn(_ duration: Double) -> Animation {
        .motion(.expandCollapseIn, duration: duration)
    }
    
    static func expandOut(_ duration: Double) -> Animation {
        .motion(.expandCollapseOut, duration: duration)
    }
    
    static func passiveMoveIn(_ duration: Double) -> Animation {
        .motion(.passiveMoveIn, duration: duration)
    }
    
    static func passiveMoveOut(_ duration: Double) -> Animation {
        .motion(.passiveMoveOut, duration: duration)
    }
    
    static func fadeIn(_ duration: Double) -> Animation {
        .motion(.fadeIn, duration: duration)
    }
    
    static func fadeOut(_ duration: Double) -> Animation {
        .motion(.fadeOut, duration: duration)
    }
    
    static func quickMoveIn(_ duration: Double) -> Animation {
        .motion(.quickMoveIn, duration: duration)
    }
    
    static func quickMoveOut(_ duration: Double) -> Animation {
        .motion(.quickMoveOut, duration: duration)
    }
}

// MARK: - View Extensions for Motion

extension View {
    func motionEnter(delay: Double = 0) -> some View {
        self.transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
    
    func motionMove<V: Equatable>(_ value: V) -> some View {
        self.animation(.move, value: value)
    }
    
    func motionFade<V: Equatable>(_ value: V) -> some View {
        self.animation(.fade, value: value)
    }
    
    func motionExpandCollapse<V: Equatable>(_ value: V) -> some View {
        self.animation(.expandCollapse, value: value)
    }
}

// MARK: - Motion Preview View
struct MotionPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = true
    @StateObject private var durationCoordinator = DurationAnimationCoordinator()
    
    private let durationOptions: [(String, Double, Double)] = [
        ("Extra Extra Short", MotionDuration.extraExtraShortIn, MotionDuration.extraExtraShortIn),
        ("Extra Short", MotionDuration.extraShortIn, MotionDuration.extraShortOut),
        ("Short", MotionDuration.shortIn, MotionDuration.shortOut),
        ("Medium", MotionDuration.mediumIn, MotionDuration.mediumOut),
        ("Long", MotionDuration.longIn, MotionDuration.longOut),
        ("Extra Long", MotionDuration.extraLong, MotionDuration.extraLong)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Motion",
                backAction: { dismiss() },
                icon1: {
                    FDSIconButton(
                        icon: isPlaying ? "pause-filled" : "play-filled",
                        action: { isPlaying.toggle() }
                    )
                }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    motionTypesSection
                    durationExamplesSection
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
            }
            .background(Color("surfaceBackground"))
        }
        .environment(\.motionIsPlaying, isPlaying)
        .environmentObject(durationCoordinator)
        .onAppear {
            durationCoordinator.maxDurationIn = maxDurationIn
            if isPlaying {
                durationCoordinator.startAnimation()
            }
        }
        .onChange(of: isPlaying) { oldValue, newValue in
            if newValue {
                durationCoordinator.startAnimation()
            } else {
                durationCoordinator.stopAnimation()
            }
        }
    }
    
    private var durationExamplesSection: some View {
        MotionGroupCard(title: "Duration examples") {
            VStack(spacing: 16) {
                ForEach(Array(durationOptions.enumerated()), id: \.offset) { index, item in
                    DurationExampleRow(
                        name: item.0, 
                        durationIn: item.1, 
                        durationOut: item.2
                    )
                }
            }
        }
    }
    
    private var maxDurationIn: Double {
        durationOptions.map { $0.1 }.max() ?? 1.0
    }
    
    private var motionTypesSection: some View {
        MotionGroupCard(title: "Motion types") {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(motionTypeExamples, id: \.0) { name, motionType in
                    MotionTypeExample(name: name, motionType: motionType)
                }
            }
        }
    }
    
    private var motionTypeExamples: [(String, MotionType)] {
        [
            ("Enter/Exit", MotionType.enterExitIn),
            ("Expand/Collapse", MotionType.expandCollapseIn),
            ("Swap/Shuffle", MotionType.swapShuffleIn),
            ("Move", MotionType.moveIn),
            ("Quick Move", MotionType.quickMoveIn),
            ("Passive Move", MotionType.passiveMoveIn),
            ("Fade", MotionType.fadeIn)
        ]
    }
}

// MARK: - Motion Group Card Component
struct MotionGroupCard<Content: View>: View {
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

// MARK: - Duration Animation Coordinator
@MainActor
class DurationAnimationCoordinator: ObservableObject {
    @Published var animationPhase: DurationPhase = .initial
    var maxDurationIn: Double = 1.0
    private var animationTask: Task<Void, Never>?
    
    enum DurationPhase {
        case initial
        case animatingIn
        case waitingAtEnd
        case animatingOut
        case pausingBetweenCycles
    }
    
    func startAnimation() {
        animationTask?.cancel()
        
        animationTask = Task {
            while !Task.isCancelled {
                animationPhase = .animatingIn
                try? await Task.sleep(nanoseconds: UInt64(maxDurationIn * 1_000_000_000))
                
                animationPhase = .waitingAtEnd
                try? await Task.sleep(nanoseconds: UInt64(0.4 * 1_000_000_000))
                
                guard !Task.isCancelled else { return }
                
                animationPhase = .animatingOut
                try? await Task.sleep(nanoseconds: UInt64(1.0 * 1_000_000_000))
                
                animationPhase = .pausingBetweenCycles
                try? await Task.sleep(nanoseconds: UInt64(0.8 * 1_000_000_000))
                
                animationPhase = .initial
                try? await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
            }
        }
    }
    
    func stopAnimation() {
        animationTask?.cancel()
        animationPhase = .initial
    }
}

// MARK: - Duration Example Row Component
struct DurationExampleRow: View {
    let name: String
    let durationIn: Double
    let durationOut: Double
    @State private var progress: Double = 0.0
    @EnvironmentObject private var coordinator: DurationAnimationCoordinator
    @Environment(\.motionIsPlaying) private var isPlaying
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .headline4Typography()
                        .foregroundStyle(Color("primaryText"))
                    
                    Text("in: \(durationIn, specifier: "%.2f")s • out: \(durationOut, specifier: "%.2f")s")
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryText"))
                }
                
                Spacer()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color("webWash"))
                        .frame(height: 2)
                        .cornerRadius(1)
                    
                    Circle()
                        .fill(Color("primaryButtonBackground"))
                        .frame(width: 16, height: 16)
                        .offset(x: progress * (geometry.size.width - 16))
                }
            }
            .frame(height: 16)
        }
        .onChange(of: coordinator.animationPhase) { oldPhase, newPhase in
            handlePhaseChange(newPhase)
        }
        .onChange(of: isPlaying) { oldValue, newValue in
            if !newValue {
                withAnimation(.easeOut(duration: 0.2)) {
                    progress = 0.0
                }
            }
        }
    }
    
    private func handlePhaseChange(_ phase: DurationAnimationCoordinator.DurationPhase) {
        switch phase {
        case .initial:
            progress = 0.0
        case .animatingIn:
            withAnimation(.moveIn(durationIn)) {
                progress = 1.0
            }
        case .waitingAtEnd:
            break
        case .animatingOut:
            withAnimation(.moveOut(durationOut)) {
                progress = 0.0
            }
        case .pausingBetweenCycles:
            break
        }
    }
}

// MARK: - Motion Type Example Component
struct MotionTypeExample: View {
    let name: String
    let motionType: MotionType
    @State private var animationPhase: AnimationPhase = .initial
    @State private var animationTask: Task<Void, Never>?
    @Environment(\.motionIsPlaying) private var isPlaying
    
    enum AnimationPhase: CaseIterable {
        case initial, middle, final, pause
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(Color("webWash"))
                .frame(height: 80)
                .overlay(animationContent)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("borderUiEmphasis"), lineWidth: 1)
                )
                .cornerRadius(8)
                .onAppear {
                    if isPlaying {
                        startContinuousAnimation()
                    }
                }
                .onChange(of: isPlaying) { oldValue, newValue in
                    animationTask?.cancel()
                    if newValue {
                        startContinuousAnimation()
                    } else {
                        withAnimation(.easeOut(duration: 0.3)) {
                            animationPhase = .initial
                        }
                    }
                }
                .onDisappear {
                    animationTask?.cancel()
                }
            Text(name)
                .meta4LinkTypography()
                .foregroundStyle(Color("primaryText"))
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private var animationContent: some View {
        switch motionType {
        case .enterExitIn:
            RoundedRectangle(cornerRadius: 4)
                .fill(Color("primaryButtonBackground"))
                .frame(width: 20, height: 20)
                .offset(x: offsetForEnterExit)
                .opacity(opacityForEnterExit)
                
        case .expandCollapseIn:
            RoundedRectangle(cornerRadius: 4)
                .fill(Color("primaryButtonBackground"))
                .frame(
                    width: sizeForExpandCollapse.width,
                    height: sizeForExpandCollapse.height
                )
                
        case .swapShuffleIn:
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("primaryButtonBackground"))
                    .frame(width: 20, height: 20)
                    .offset(x: offsetForSwapShuffleBlue)
                    .opacity(opacityForSwapShuffleBlue)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("secondaryIcon"))
                    .frame(width: 20, height: 20)
                    .offset(x: offsetForSwapShuffleGray)
                    .opacity(opacityForSwapShuffleGray)
            }
                
        case .moveIn:
            RoundedRectangle(cornerRadius: 4)
                .fill(Color("primaryButtonBackground"))
                .frame(width: 20, height: 20)
                .offset(x: offsetForMove)
                
        case .quickMoveIn:
            RoundedRectangle(cornerRadius: 4)
                .fill(Color("primaryButtonBackground"))
                .frame(width: widthForQuickMove, height: 20)
                
        case .passiveMoveIn:
            RoundedRectangle(cornerRadius: 4)
                .fill(Color("primaryButtonBackground"))
                .frame(width: 20, height: 20)
                .offset(y: offsetForPassiveMove)
                
        case .fadeIn:
            RoundedRectangle(cornerRadius: 4)
                .fill(Color("primaryButtonBackground"))
                .frame(width: 20, height: 20)
                .opacity(opacityForFade)
                
        default:
            RoundedRectangle(cornerRadius: 4)
                .fill(Color("primaryButtonBackground"))
                .frame(width: 20, height: 20)
        }
    }
    
    
    private var offsetForEnterExit: CGFloat {
        switch animationPhase {
        case .initial: return -30
        case .middle: return 0
        case .final: return 0
        case .pause: return -30
        }
    }
    
    private var opacityForEnterExit: Double {
        switch animationPhase {
        case .initial: return 0.0
        case .middle: return 1.0
        case .final: return 1.0
        case .pause: return 0.0
        }
    }
    
    private var sizeForExpandCollapse: CGSize {
        switch animationPhase {
        case .initial: return CGSize(width: 20, height: 20)
        case .middle: return CGSize(width: 60, height: 60)
        case .final: return CGSize(width: 60, height: 60)
        case .pause: return CGSize(width: 20, height: 20)
        }
    }
    
    private var offsetForSwapShuffleBlue: CGFloat {
        switch animationPhase {
        case .initial: return 0
        case .middle: return -20
        case .final: return -20
        case .pause: return 0
        }
    }
    
    private var opacityForSwapShuffleBlue: Double {
        switch animationPhase {
        case .initial: return 1.0
        case .middle: return 0.0
        case .final: return 0.0
        case .pause: return 1.0
        }
    }
    
    private var offsetForSwapShuffleGray: CGFloat {
        switch animationPhase {
        case .initial: return 20
        case .middle: return 0
        case .final: return 0
        case .pause: return 20
        }
    }
    
    private var opacityForSwapShuffleGray: Double {
        switch animationPhase {
        case .initial: return 0.0
        case .middle: return 1.0
        case .final: return 1.0
        case .pause: return 0.0
        }
    }
    
    private var offsetForMove: CGFloat {
        switch animationPhase {
        case .initial: return -25
        case .middle: return 25
        case .final: return 25
        case .pause: return -25
        }
    }
    
    private var widthForQuickMove: CGFloat {
        switch animationPhase {
        case .initial: return 20
        case .middle: return 50
        case .final: return 50
        case .pause: return 20
        }
    }
    
    private var offsetForPassiveMove: CGFloat {
        switch animationPhase {
        case .initial: return -15
        case .middle: return 15
        case .final: return 15
        case .pause: return -15
        }
    }
    
    private var opacityForFade: Double {
        switch animationPhase {
        case .initial: return 1.0
        case .middle: return 0.0
        case .final: return 0.0
        case .pause: return 1.0
        }
    }
    
    
    private func startContinuousAnimation() {
        animationTask?.cancel()
        
        animationTask = Task {
            while isPlaying && !Task.isCancelled {
                let inDuration = getDuration() * 2.5
                let outDuration = getOutDuration() * 2.5
                let pauseDuration = 1.25
                
                // Phase 1: Animate to middle state
                await MainActor.run {
                    withAnimation(.motion(motionType, duration: inDuration)) {
                        animationPhase = .middle
                    }
                }
                
                try? await Task.sleep(nanoseconds: UInt64(inDuration * 1_000_000_000))
                
                // Phase 2: Hold middle state
                try? await Task.sleep(nanoseconds: UInt64(pauseDuration * 1_000_000_000))
                
                guard isPlaying && !Task.isCancelled else { return }
                
                // Phase 3: Animate to final/exit state
                await MainActor.run {
                    withAnimation(.motion(getOutMotionType(), duration: outDuration)) {
                        animationPhase = .pause
                    }
                }
                
                try? await Task.sleep(nanoseconds: UInt64(outDuration * 1_000_000_000))
                
                // Phase 4: Hold final state
                try? await Task.sleep(nanoseconds: UInt64(pauseDuration * 1_000_000_000))
                
                guard isPlaying && !Task.isCancelled else { return }
                
                // Phase 5: Reset to initial
                await MainActor.run {
                    animationPhase = .initial
                }
                
                // Brief pause before next cycle
                try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
            }
        }
    }
    
    private func getDuration() -> Double {
        switch motionType {
        case .quickMoveIn: return MotionDuration.shortIn
        case .enterExitIn, .swapShuffleIn: return MotionDuration.shortIn
        case .moveIn, .expandCollapseIn, .fadeIn: return MotionDuration.shortIn
        case .passiveMoveIn: return MotionDuration.shortIn
        default: return MotionDuration.shortIn
        }
    }
    
    private func getOutMotionType() -> MotionType {
        switch motionType {
        case .enterExitIn: return .enterExitOut
        case .expandCollapseIn: return .expandCollapseOut
        case .swapShuffleIn: return .swapShuffleOut
        case .moveIn: return .moveOut
        case .quickMoveIn: return .quickMoveOut
        case .passiveMoveIn: return .passiveMoveOut
        case .fadeIn: return .fadeOut
        default: return motionType
        }
    }
    
    private func getOutDuration() -> Double {
        switch motionType {
        case .quickMoveIn: return MotionDuration.shortOut
        case .enterExitIn, .swapShuffleIn: return MotionDuration.shortOut
        case .moveIn, .expandCollapseIn, .fadeIn: return MotionDuration.shortOut
        case .passiveMoveIn: return MotionDuration.shortOut
        default: return MotionDuration.shortOut
        }
    }
}

// MARK: - Environment Key for Motion Playing State
private struct MotionIsPlayingKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var motionIsPlaying: Bool {
        get { self[MotionIsPlayingKey.self] }
        set { self[MotionIsPlayingKey.self] = newValue }
    }
}

// MARK: - Preview
#Preview {
    MotionPreviewView()
}

import SwiftUI
import UIKit

// MARK: - Touch Settings
@Observable
class TouchSettings {
    static let shared = TouchSettings()
    var isEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "touchVisualizerEnabled")
        }
    }
    
    private init() {
        // Only load from UserDefaults if it has been explicitly set before
        if UserDefaults.standard.object(forKey: "touchVisualizerEnabled") != nil {
            self.isEnabled = UserDefaults.standard.bool(forKey: "touchVisualizerEnabled")
        }
    }
}

// MARK: - Touch Point
struct TouchPoint: Identifiable {
    let id: Int
    var location: CGPoint
    var isActive: Bool = true
}

// MARK: - Touch Coordinator
@Observable
class TouchCoordinator {
    static let shared = TouchCoordinator()
    var touches: [Int: TouchPoint] = [:]
    
    private init() {}
    
    func addTouch(id: Int, location: CGPoint) {
        touches[id] = TouchPoint(id: id, location: location)
    }
    
    func updateTouch(id: Int, location: CGPoint) {
        touches[id]?.location = location
    }
    
    func removeTouch(id: Int) {
        touches[id]?.isActive = false
        // Remove after fade animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.touches.removeValue(forKey: id)
        }
    }
}

// MARK: - Touch Indicator
struct TouchIndicator: View {
    let isActive: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.3 * opacity))
            .frame(width: 44, height: 44)
            .overlay {
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .opacity(opacity)
            }
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.swapShuffleIn(MotionDuration.extraShortIn)) {
                    scale = 1.0
                }
            }
            .onChange(of: isActive) { _, active in
                if !active {
                    withAnimation(.swapShuffleOut(MotionDuration.extraShortOut)) {
                        scale = 0.5
                        opacity = 0
                    }
                }
            }
    }
}

// MARK: - Touch Window Setup
class TouchWindowSetup {
    static let shared = TouchWindowSetup()
    private var hasSetup = false
    
    private init() {}
    
    func setup() {
        guard !hasSetup else { return }
        hasSetup = true
        
        // Delay to allow window to be created
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.swizzleWindowSendEvent()
        }
    }
    
    private func swizzleWindowSendEvent() {
        let windowClass: AnyClass = UIWindow.self
        
        let originalSelector = #selector(UIWindow.sendEvent(_:))
        let swizzledSelector = #selector(UIWindow.touchVisualizer_sendEvent(_:))
        
        guard let originalMethod = class_getInstanceMethod(windowClass, originalSelector),
              let swizzledMethod = class_getInstanceMethod(windowClass, swizzledSelector) else {
            return
        }
        
        // Only swizzle once
        let didAddMethod = class_addMethod(
            windowClass,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        )
        
        if didAddMethod {
            class_replaceMethod(
                windowClass,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod)
            )
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

extension UIWindow {
    @objc dynamic func touchVisualizer_sendEvent(_ event: UIEvent) {
        // Call original implementation
        self.touchVisualizer_sendEvent(event)
        
        // Only intercept if enabled
        guard TouchSettings.shared.isEnabled,
              let touches = event.allTouches,
              let rootView = self.rootViewController?.view else {
            return
        }
        
        for touch in touches {
            let location = touch.location(in: rootView)
            let touchId = touch.hash
            
            switch touch.phase {
            case .began:
                TouchCoordinator.shared.addTouch(id: touchId, location: location)
            case .moved:
                TouchCoordinator.shared.updateTouch(id: touchId, location: location)
            case .ended, .cancelled:
                TouchCoordinator.shared.removeTouch(id: touchId)
            default:
                break
            }
        }
    }
}

// MARK: - Touch Visualizer Modifier
struct TouchVisualizerModifier: ViewModifier {
    @State private var coordinator = TouchCoordinator.shared
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if TouchSettings.shared.isEnabled {
                    GeometryReader { geometry in
                        ForEach(Array(coordinator.touches.values)) { touch in
                            TouchIndicator(isActive: touch.isActive)
                                .position(touch.location)
                        }
                    }
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                }
            }
    }
}

// MARK: - View Extension
extension View {
    func touchVisualizer() -> some View {
        self.modifier(TouchVisualizerModifier())
    }
}

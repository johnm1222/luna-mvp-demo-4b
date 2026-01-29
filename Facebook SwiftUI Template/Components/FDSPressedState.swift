import SwiftUI

// MARK: - Pressed State Scale
enum FDSPressedStateScale {
    case none
    case small
    case medium
    case large
    
    var value: CGFloat? {
        switch self {
        case .none: return nil
        case .small: return 0.95
        case .medium: return 0.97
        case .large: return 0.99
        }
    }
}

// MARK: - FDSPressedState Button Style
struct FDSPressedState: ButtonStyle {
    let cornerRadius: CGFloat
    let isCircle: Bool
    let isOnMedia: Bool
    let scale: FDSPressedStateScale
    let padding: EdgeInsets
    
    init(
        cornerRadius: CGFloat = 0,
        isOnMedia: Bool = false,
        scale: FDSPressedStateScale = .none,
        padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    ) {
        self.cornerRadius = cornerRadius
        self.isCircle = false
        self.isOnMedia = isOnMedia
        self.scale = scale
        self.padding = padding
    }
    
    init(
        circle: Bool,
        isOnMedia: Bool = false,
        scale: FDSPressedStateScale = .none,
        padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    ) {
        self.cornerRadius = 0
        self.isCircle = circle
        self.isOnMedia = isOnMedia
        self.scale = scale
        self.padding = padding
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                Group {
                    if isCircle {
                        Circle()
                            .fill(overlayColor)
                            .opacity(configuration.isPressed ? 1.0 : 0.0)
                            .padding(EdgeInsets(
                                top: -padding.top,
                                leading: -padding.leading,
                                bottom: -padding.bottom,
                                trailing: -padding.trailing
                            ))
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(overlayColor)
                            .opacity(configuration.isPressed ? 1.0 : 0.0)
                            .padding(EdgeInsets(
                                top: -padding.top,
                                leading: -padding.leading,
                                bottom: -padding.bottom,
                                trailing: -padding.trailing
                            ))
                    }
                }
            )
            .scaleEffect(configuration.isPressed && scale.value != nil ? scale.value! : 1.0)
            .animation(.swapShuffleIn(MotionDuration.extraExtraShortIn), value: configuration.isPressed)
    }
    
    private var overlayColor: Color {
        isOnMedia ? Color("mediaPressed") : Color("nonMediaPressed")
    }
}


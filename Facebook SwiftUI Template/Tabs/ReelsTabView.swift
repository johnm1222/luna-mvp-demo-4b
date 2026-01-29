import SwiftUI
import AVKit
import AVFoundation

struct ReelsTabView: View {
    @State private var currentReelIndex: Int? = 0
    @State private var selectedNavIndex = 0
    @State private var showSearch = false
    @State private var is2xSpeed = false
    @EnvironmentObject private var tabBarHelper: FDSTabBarHelper
    
    var body: some View {
        NavigationStack {
        GeometryReader { geometry in
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<sampleReels.count, id: \.self) { index in
                            ReelVideoPlayer(
                                reel: sampleReels[index],
                                reelIndex: index,
                                isCurrentReel: currentReelIndex == index,
                                bottomInset: 80,
                                is2xSpeed: $is2xSpeed
                            )
                            .containerRelativeFrame([.horizontal, .vertical])
                            .clipped()
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $currentReelIndex)
                .background(Color("alwaysBlack"))
                .statusBarHidden(false)
                .ignoresSafeArea(.all, edges: .vertical)
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: geometry.safeAreaInsets.top)
                        
                        HStack(alignment: .center, spacing: 12) {
                            FDSSubNavigationBar(
                                items: [
                                    SubNavigationItem("For you"),
                                    SubNavigationItem("Explore")
                                ],
                                selectedIndex: $selectedNavIndex,
                                onMedia: true
                            )
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                FDSIconButton(icon: "magnifying-glass-outline", onMedia: true, action: {
                                    showSearch = true
                                })
                                FDSIconButton(icon: "profile-outline", onMedia: true, action: {})
                            }
                        }
                        .padding(.trailing, 12)
                        .frame(height: 52)
                        .opacity(is2xSpeed ? 0 : 1)
                        .animation(.swapShuffleIn(MotionDuration.shortIn), value: is2xSpeed)
                    }
                    .background(
                        LinearGradient(
                            stops: [
                                .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 0.0),
                                .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.3),
                                .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.7),
                                .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 180)
                        .opacity(is2xSpeed ? 0 : 1)
                        .animation(.swapShuffleIn(MotionDuration.shortIn), value: is2xSpeed)
                    )
                    Spacer()
                }
                .ignoresSafeArea(.all, edges: .top)
            }
        }
        .navigationDestination(isPresented: $showSearch) {
            SearchView()
        }
        .navigationDestination(for: String.self) { profileImageId in
            if let profileData = profileDataMap[profileImageId] {
                ProfileView(profile: profileData)
            }
        }
        .onChange(of: currentReelIndex) { _, newIndex in
            // Only update if reels tab is active to avoid unnecessary updates
            guard tabBarHelper.isReelsTabActive else { return }
            tabBarHelper.currentReelIndex = newIndex
        }
        .onAppear {
            // Set initial index when tab becomes visible
            if tabBarHelper.isReelsTabActive {
                tabBarHelper.currentReelIndex = currentReelIndex
            }
        }
        .onChange(of: tabBarHelper.isReelsTabActive) { _, isActive in
            // Update current index when tab becomes active
            if isActive {
                tabBarHelper.currentReelIndex = currentReelIndex
            }
        }
        }
    }
}

// MARK: - Reel Video Player
struct ReelVideoPlayer: View {
    let reel: FacebookReel
    let reelIndex: Int
    let isCurrentReel: Bool
    let bottomInset: CGFloat
    @Binding var is2xSpeed: Bool
    @State private var isPlaying = false
    @State private var isPausedByTabSwitch = false // Track if pause is due to tab switching
    @State private var isLiked = false
    @State private var likeCount: Int
    @State private var isCaptionExpanded = false
    @EnvironmentObject private var tabBarHelper: FDSTabBarHelper
    
    init(reel: FacebookReel, reelIndex: Int, isCurrentReel: Bool, bottomInset: CGFloat = 0, is2xSpeed: Binding<Bool>) {
        self.reel = reel
        self.reelIndex = reelIndex
        self.isCurrentReel = isCurrentReel
        self.bottomInset = bottomInset
        self._is2xSpeed = is2xSpeed
        self._likeCount = State<Int>(initialValue: reel.likes)
    }
    
    var body: some View {
        ZStack {
            ZStack {
                VideoPlayerView(
                    videoName: reel.videoFileName, 
                    isPlaying: $isPlaying,
                    is2xSpeed: $is2xSpeed
                )
                .overlay {
                    // Dim overlay when paused (but not when paused by tab switch)
                    if !isPausedByTabSwitch {
                        Color.black.opacity(isPlaying ? 0 : 0.3)
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                            .animation(.swapShuffleIn(MotionDuration.shortIn), value: isPlaying)
                    }
                }
                
                ContentProtectionGradient()
            }
            .ignoresSafeArea(.all)
            .overlay(alignment: .leading) {
                Color.clear
                    .frame(width: 30)
                    .contentShape(Rectangle())
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                        if pressing {
                            if !is2xSpeed && isPlaying {
                                is2xSpeed = true
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }
                        } else {
                            is2xSpeed = false
                        }
                    }, perform: {})
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !is2xSpeed && isPlaying {
                                    is2xSpeed = true
                                    
                                    // Trigger haptic feedback
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                            }
                            .onEnded { _ in
                                is2xSpeed = false
                            }
                    )
                    .zIndex(100)
            }
            .overlay(alignment: .trailing) {
                Color.clear
                    .frame(width: 30)
                    .contentShape(Rectangle())
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                        if pressing {
                            if !is2xSpeed && isPlaying {
                                is2xSpeed = true
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }
                        } else {
                            is2xSpeed = false
                        }
                    }, perform: {})
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !is2xSpeed && isPlaying {
                                    is2xSpeed = true
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                            }
                            .onEnded { _ in
                                is2xSpeed = false
                            }
                    )
                    .zIndex(100)
            }
            
            GeometryReader { geometry in
                Color.clear
                    .frame(width: geometry.size.width - 60, height: geometry.size.height)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isPausedByTabSwitch = false
                        withAnimation(.swapShuffleIn(MotionDuration.extraShortIn)) {
                            isPlaying.toggle()
                        }
                    }
                    .offset(x: 30)
                    .allowsHitTesting(true)
            }
            
            VStack {
                Spacer()
                
                HStack(alignment: .bottom, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .center, spacing: 8) {
                            NavigationLink(value: reel.profileImage) {
                                Image(reel.profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .center, spacing: 4) {
                                    Text(reel.username)
                                        .headline4Typography()
                                        .textOnMediaShadow()
                                        .foregroundStyle(Color("primaryTextOnMedia"))
                                    
                                    if reel.verified {
                                        Image("badge-checkmark-filled")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundStyle(Color("primaryTextOnMedia"))
                                            .iconOnMediaShadow()
                                    }
                                    
                                    Text("·")
                                        .headline4Typography()
                                        .textOnMediaShadow()
                                        .foregroundStyle(Color("primaryTextOnMedia"))
                                    Button {
                                    } label: {
                                        Text("Follow")
                                            .headline4Typography()
                                            .textOnMediaShadow()
                                            .foregroundStyle(Color("primaryTextOnMedia"))
                                    }
                                    .buttonStyle(FDSPressedState(
                                        cornerRadius: 6,
                                        isOnMedia: true,
                                        padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
                                    ))
                                }
                                
                                HStack(spacing: 4) {
                                    Image("music-filled")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundStyle(Color("secondaryIconOnMedia"))
                                        .iconOnMediaShadow()
                                    
                                    Text(getMusicInfo(for: reel.username))
                                        .meta4Typography()
                                        .textOnMediaShadow()
                                        .foregroundStyle(Color("secondaryTextOnMedia"))
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                        }
                        
                        // Caption
                        Text(reel.caption)
                            .body3Typography()
                            .textOnMediaShadow()
                            .foregroundStyle(Color("primaryTextOnMedia"))
                            .lineLimit(isCaptionExpanded ? nil : 1)
                            .truncationMode(.tail)
                            .animation(.moveIn(MotionDuration.shortIn), value: isCaptionExpanded)
                            .highPriorityGesture(
                                TapGesture()
                                    .onEnded { _ in
                                        isCaptionExpanded.toggle()
                                    }
                            )
                    }
                    .opacity(is2xSpeed ? 0 : 1)
                    .animation(.swapShuffleIn(MotionDuration.shortIn), value: is2xSpeed)
                    
                    // Vertical UFI
                    VStack(spacing: 0) {
                        VerticalUFIButton(
                            icon: "like-outline",
                            likedIcon: "like",
                            isLiked: $isLiked,
                            likeCount: $likeCount
                        )
                        VerticalUFIButton(icon: "comment-outline", count: reel.comments.formattedString, action: {})
                        VerticalUFIButton(icon: "share-outline", count: reel.shares.formattedString, action: {})
                        VerticalUFIButton(icon: "bookmark-outline", count: "Save", action: {})
                        VerticalUFIButton(icon: "dots-3-horizontal-outline", count: nil, action: {
                        })
                    }
                    .opacity(is2xSpeed ? 0 : 1)
                    .animation(.swapShuffleIn(MotionDuration.shortIn), value: is2xSpeed)
                }
                .padding(.leading, 12)
                .padding(.bottom, 12 + bottomInset)
            }
            
            if is2xSpeed {
                VStack {
                    Spacer()
                    FDSActionChip(
                        surface: .media,
                        type: .secondary,
                        size: .small,
                        label: "2× speed"
                    ) {
                        // Non-interactive indicator
                    }
                    .padding(.bottom, 12 + bottomInset)
                }
                .transition(.opacity)
                .animation(.swapShuffleIn(MotionDuration.extraShortIn), value: is2xSpeed)
            }
            
            if !isPlaying && !isPausedByTabSwitch {
                VStack {
                    Spacer()
                    VideoControls(isPlaying: $isPlaying)
                    Spacer()
                }
            }
        }
        .onChange(of: isCurrentReel) { _, isCurrent in
            withAnimation(.swapShuffleIn(MotionDuration.extraShortIn)) {
                isPlaying = isCurrent
            }
            if !isCurrent {
                is2xSpeed = false
            }
        }
        .onChange(of: isPlaying) { _, playing in
            if !playing {
                is2xSpeed = false
            }
            if playing {
                isPausedByTabSwitch = false
            }
        }
        .onAppear {
            if isCurrentReel {
                isPlaying = true
            }
        }
        .onChange(of: tabBarHelper.isReelsTabActive) { _, isActive in
            if isCurrentReel {
                if isActive {
                    isPausedByTabSwitch = false
                    isPlaying = true
                } else {
                    isPausedByTabSwitch = true
                    isPlaying = false
                }
            }
        }
    }
}

// MARK: - Facebook Reel Model
struct FacebookReel {
    let id: String
    let username: String
    let profileImage: String
    let caption: String
    let timeAgo: String
    let likes: Int
    let comments: Int
    let shares: Int
    let videoFileName: String
    let verified: Bool
}

// MARK: - Sample Reels Data
let sampleReels: [FacebookReel] = [
    FacebookReel(
        id: "1",
        username: "Jade Wijaya",
        profileImage: "jadesurfs",
        caption: "🏄‍♂️🌺Aloha from Hawaii 🌊✨ Join me for some surfing!",
        timeAgo: "3h",
        likes: 847540,
        comments: 3200,
        shares: 1890,
        videoFileName: "surf",
        verified: true
    ),
    FacebookReel(
        id: "2", 
        username: "Emma Rodriguez",
        profileImage: "profile11",
        caption: "just spinning and existing ✨💫 nobody can tell me nothing rn",
        timeAgo: "6h",
        likes: 120540,
        comments: 8400,
        shares: 4200,
        videoFileName: "dancing",
        verified: false
    ),
    FacebookReel(
        id: "3",
        username: "Sarah Kim",
        profileImage: "profile7",
        caption: "POV: you're home alone and your favorite song comes on 💃😂",
        timeAgo: "12h",
        likes: 623350,
        comments: 2100,
        shares: 980,
        videoFileName: "dance",
        verified: false
    ),
    FacebookReel(
        id: "4", 
        username: "Jessica Martinez",
        profileImage: "profile8",
        caption: "manifested too hard and now this is what our mother son dates look like 😭💙",
        timeAgo: "6h",
        likes: 210943,
        comments: 12000,
        shares: 8700,
        videoFileName: "ocean",
        verified: true
    ),
    FacebookReel(
        id: "5",
        username: "Diana Ross",
        profileImage: "profile4",
        caption: "we've been perfecting this for 3 years straight 🤝✨ #friendshipgoals",
        timeAgo: "12h",
        likes: 956439,
        comments: 4800,
        shares: 2300,
        videoFileName: "handsin",
        verified: false
    ),
    FacebookReel(
        id: "6",
        username: "Jake Sullivan",
        profileImage: "profile9",
        caption: "this wave is absolutely INSANE 😳🌊 respect to anyone who surfs these",
        timeAgo: "12h",
        likes: 152294,
        comments: 6700,
        shares: 5400,
        videoFileName: "surfing",
        verified: false
    )
]

// MARK: - Video Player View
struct VideoPlayerView: UIViewControllerRepresentable {
    let videoName: String
    @Binding var isPlaying: Bool
    @Binding var is2xSpeed: Bool
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        controller.allowsVideoFrameAnalysis = false
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        if let bundleURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            let player = AVPlayer(url: bundleURL)
            player.isMuted = true
            controller.player = player
            controller.showsPlaybackControls = false
            controller.videoGravity = .resizeAspectFill
            controller.view.isUserInteractionEnabled = false
            
            context.coordinator.addStatusObserver(for: player)
            context.coordinator.setupLooping(for: player)
            context.coordinator.player = player
            
            if isPlaying {
                player.play()
            }
        } else {
            print("Video not found in bundle: \(videoName)")
            let player = AVPlayer()
            controller.player = player
            context.coordinator.player = player
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        guard let player = context.coordinator.player else { return }
        
        if isPlaying {
            player.play()
        } else {
            player.pause()
        }
        
        player.rate = isPlaying ? (is2xSpeed ? 2.0 : 1.0) : 0.0
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var player: AVPlayer?
        private var isObservingStatus = false
        
        func setupLooping(for player: AVPlayer) {
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
        }
        
        func addStatusObserver(for player: AVPlayer) {
            guard !isObservingStatus else { return }
            player.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
            isObservingStatus = true
        }
        
        func removeStatusObserver() {
            guard let player = player, isObservingStatus else { return }
            player.removeObserver(self, forKeyPath: "status")
            isObservingStatus = false
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "status", let player = object as? AVPlayer {
                switch player.status {
                case .readyToPlay:
                    break // Player is ready
                case .failed:
                    print("⚠️ Video player failed: \(player.error?.localizedDescription ?? "Unknown error")")
                case .unknown:
                    break // Player status unknown
                @unknown default:
                    break
                }
            }
        }
        
        deinit {
            removeStatusObserver()
            NotificationCenter.default.removeObserver(self)
        }
    }
}

// MARK: - Helper Functions
func getMusicInfo(for username: String) -> String {
    switch username {
    case "Jade Wijaya":
        return "Lime Cordiale · Pedestal"
    case "Emma Rodriguez":
        return "Gracie Abrams · That's So True"
    case "Sarah Kim":
        return "Sabrina Carpenter · Espresso"
    case "Jessica Martinez":
        return "Original audio"
    case "Marcus Thompson":
        return "Kendrick Lamar · Not Like Us"
    case "Jake Sullivan":
        return "Original audio"
    default:
        return "Original audio"
    }
}

// MARK: - Reusable Components

struct ContentProtectionGradient: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            LinearGradient(
                stops: [
                    .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 0.0),
                    .init(color: Color("overlayOnMediaLight").opacity(0.1), location: 0.2),
                    .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.5),
                    .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.8),
                    .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 260)
            .allowsHitTesting(false)
        }
        .ignoresSafeArea(.all)
    }
}

struct VerticalUFIButton: View {
    private enum ButtonType {
        case action(icon: String, count: String?, action: () -> Void)
        case like(icon: String, likedIcon: String, isLiked: Binding<Bool>, likeCount: Binding<Int>)
    }
    
    private let buttonType: ButtonType
    @State private var isPressed = false
    
    init(icon: String, count: String? = nil, action: @escaping () -> Void) {
        self.buttonType = .action(icon: icon, count: count, action: action)
    }
    
    init(icon: String, likedIcon: String, isLiked: Binding<Bool>, likeCount: Binding<Int>) {
        self.buttonType = .like(icon: icon, likedIcon: likedIcon, isLiked: isLiked, likeCount: likeCount)
    }
    
    var body: some View {
        Button {
            switch buttonType {
            case .action(_, _, let action):
                action()
            case .like(_, _, let isLiked, let likeCount):
                withAnimation(.swapShuffleIn(MotionDuration.extraShortIn)) {
                    isLiked.wrappedValue.toggle()
                    likeCount.wrappedValue += isLiked.wrappedValue ? 1 : -1
                }
            }
        } label: {
            VStack(spacing: 8) {
                switch buttonType {
                case .action(let icon, let count, _):
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color("primaryIconOnMedia"))
                        .iconOnMediaShadow()
                    
                    if let count = count {
                        Text(count)
                            .meta4LinkTypography()
                            .foregroundStyle(Color("primaryTextOnMedia"))
                            .textOnMediaShadow()
                    }
                    
                case .like(let icon, let likedIcon, let isLiked, let likeCount):
                    let currentIcon = isLiked.wrappedValue ? likedIcon : icon
                    
                    Image(currentIcon)
                        .renderingMode(isLiked.wrappedValue ? .original : .template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(isLiked.wrappedValue ? Color.clear : Color("primaryIconOnMedia"))
                        .scaleEffect(isLiked.wrappedValue ? 1.2 : 1.0)
                        .iconOnMediaShadow()
                    
                    Text(likeCount.wrappedValue.formattedString)
                        .meta4LinkTypography()
                        .foregroundStyle(Color("primaryTextOnMedia"))
                        .textOnMediaShadow()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("mediaPressed"))
                    .frame(maxWidth: 48)
                    .opacity(isPressed ? 1.0 : 0.0)
            )
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.fadeIn(MotionDuration.extraShortIn)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}


struct VideoControls: View {
    @Binding var isPlaying: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                isPlaying = true
            } label: {
                Image("skip-backward-10-filled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color("secondaryButtonIconOnMedia"))
                    .frame(width: 40, height: 40)
                    .background {
                        if #available(iOS 26.0, *), GlassEffectSettings.shared.isEnabled {
                            Circle()
                                .fill(.clear)
                                .glassEffect(.clear, in: .circle)
                        } else {
                            Circle()
                                .fill(.thinMaterial)
                                .colorScheme(.dark)
                        }
                    }
            }
            .buttonStyle(FDSPressedState(circle: true, isOnMedia: true, scale: .small))
            
            Button {
                isPlaying = true
            } label: {
                Image("play-filled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color("secondaryButtonIconOnMedia"))
                    .frame(width: 60, height: 60)
                    .background {
                        if #available(iOS 26.0, *), GlassEffectSettings.shared.isEnabled {
                            Circle()
                                .fill(.clear)
                                .glassEffect(.clear, in: .circle)
                        } else {
                            Circle()
                                .fill(.thinMaterial)
                                .colorScheme(.dark)
                        }
                    }
            }
            .buttonStyle(FDSPressedState(circle: true, isOnMedia: true, scale: .small))

            Button {
                isPlaying = true
            } label: {
                Image("skip-forward-10-filled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color("secondaryButtonIconOnMedia"))
                    .frame(width: 40, height: 40)
                    .background {
                        if #available(iOS 26.0, *), GlassEffectSettings.shared.isEnabled {
                            Circle()
                                .fill(.clear)
                                .glassEffect(.clear, in: .circle)
                        } else {
                            Circle()
                                .fill(.thinMaterial)
                                .colorScheme(.dark)
                        }
                    }
            }
            .buttonStyle(FDSPressedState(circle: true, isOnMedia: true, scale: .small))
        }
    }
}

// MARK: - Number Formatting Extension
extension Int {
    var formattedString: String {
        if self >= 1000 {
            let thousands = Double(self) / 1000.0
            if thousands.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(thousands))K"
            } else {
                return String(format: "%.1fK", thousands)
            }
        }
        return "\(self)"
    }
}

#Preview {
    ReelsTabView()
        .environmentObject(FDSTabBarHelper())
}


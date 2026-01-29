import SwiftUI

// MARK: - Stories View
struct StoriesView: View {
    @Binding var isPresented: Bool
    let stories: [StoryData]
    let startingIndex: Int
    
    @State private var currentStoryIndex: Int
    @State private var currentSegment: Int = 0
    @State private var progress: Double = 0
    @State private var dragOffset: CGFloat = 0
    
    init(isPresented: Binding<Bool>, stories: [StoryData], startingIndex: Int = 0) {
        self._isPresented = isPresented
        self.stories = stories
        self.startingIndex = startingIndex
        self._currentStoryIndex = State(initialValue: startingIndex)
    }
    
    var currentStory: StoryData {
        guard currentStoryIndex >= 0 && currentStoryIndex < stories.count else {
            return stories[0] // Fallback to first story
        }
        return stories[currentStoryIndex]
    }
    
    var body: some View {
        ZStack {
            // Black background that fades during dismissal but stays solid during rotation
            Color.black
                .ignoresSafeArea()
                .opacity(1 - (abs(dragOffset) / 150.0))
            
            TabView(selection: $currentStoryIndex) {
                ForEach(0..<stories.count, id: \.self) { index in
                    GeometryReader { proxy in
                        StoryPageView(
                            story: stories[index],
                            isActive: index == currentStoryIndex,
                            currentSegment: $currentSegment,
                            progress: $progress,
                            isPresented: $isPresented,
                            dragOffset: $dragOffset,
                            onNextSegment: goToNextSegment,
                            onPreviousSegment: goToPreviousSegment,
                            geometry: proxy,
                            userName: stories[index].userName
                        )
                        .rotation3DEffect(
                            rotationAngle(proxy),
                            axis: (x: 0, y: 1, z: 0),
                            anchor: proxy.frame(in: .global).minX > 0 ? .leading : .trailing,
                            perspective: 2.5
                        )
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
        .presentationBackground(.clear)
        .onChange(of: currentStoryIndex) { _, _ in
            currentSegment = 0
            progress = 0
        }
    }
    
    func rotationAngle(_ proxy: GeometryProxy) -> Angle {
        let progressValue = proxy.frame(in: .global).minX / proxy.size.width
        let degrees = 45 * progressValue
        return Angle(degrees: Double(degrees))
    }
    
    func goToNextSegment() {
        // Bounds check
        guard currentStoryIndex >= 0 && currentStoryIndex < stories.count else {
            withAnimation(.exitOut) {
                isPresented = false
            }
            return
        }
        
        let story = stories[currentStoryIndex]
        
        if currentSegment < story.segments.count - 1 {
            currentSegment += 1
            progress = 0
        } else if currentStoryIndex < stories.count - 1 {
            withAnimation(.moveIn(MotionDuration.shortIn)) {
                currentStoryIndex += 1
            }
        } else {
            // Reached the end of all stories, close viewer
            withAnimation(.exitOut) {
                isPresented = false
            }
        }
    }
    
    func goToPreviousSegment() {
        // Bounds check
        guard currentStoryIndex >= 0 && currentStoryIndex < stories.count else {
            withAnimation(.exitOut) {
                isPresented = false
            }
            return
        }
        
        if currentSegment > 0 {
            currentSegment -= 1
            progress = 0
        } else if currentStoryIndex > 0 {
            withAnimation(.moveOut(MotionDuration.shortOut)) {
                currentStoryIndex -= 1
            }
        } else {
            // At the beginning, close viewer
            withAnimation(.exitOut) {
                isPresented = false
            }
        }
    }
}

// MARK: - Story Page View
struct StoryPageView: View {
    let story: StoryData
    let isActive: Bool
    @Binding var currentSegment: Int
    @Binding var progress: Double
    @Binding var isPresented: Bool
    @Binding var dragOffset: CGFloat
    let onNextSegment: () -> Void
    let onPreviousSegment: () -> Void
    let geometry: GeometryProxy
    let userName: String
    
    @State private var replyText: String = ""
    @FocusState private var isReplyFocused: Bool
    @State private var isPaused: Bool = false
    @State private var isDragging: Bool = false
    @State private var hasCrossedThreshold: Bool = false
    @State private var isCurrentlyPressing: Bool = false
    
    var safeCurrentSegment: Int {
        guard !story.segments.isEmpty else { return 0 }
        return min(currentSegment, story.segments.count - 1)
    }
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                // Image section with overlays
                ZStack {
                    Image(story.segments[safeCurrentSegment])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height - 44, alignment: .leading) // Fixed height: viewport minus composer height
                        .clipped()
                        .id(story.segments[safeCurrentSegment]) // Prevent morphing between images
                        
                    
                    VStack(spacing: 0) {
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.black.opacity(0.6), location: 0.0),
                                .init(color: Color.black.opacity(0.4), location: 0.5),
                                .init(color: Color.black.opacity(0.0), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        
                        Spacer()
                    }
                    .opacity(isPaused && !isDragging ? 0 : 1)
                    .animation(.fadeIn(MotionDuration.extraShortIn), value: isPaused)
                    
                    VStack(spacing: 0) {
                        StoryHeader(
                            name: userName,
                            profileImage: story.profileImage,
                            segmentCount: story.segments.count,
                            currentSegment: $currentSegment,
                            progress: $progress,
                            isActive: isActive,
                            isPresented: $isPresented,
                            isPaused: isPaused || isDragging,
                            onSegmentComplete: onNextSegment
                        )
                        .padding(.horizontal, 12)
                        
                        Spacer()
                    }
                    .opacity(isPaused && !isDragging ? 0 : 1)
                    .animation(.fadeIn(MotionDuration.extraShortIn), value: isPaused)
                    
                    // Tap areas overlaying image
                    HStack(spacing: 0) {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onPreviousSegment()
                            }
                            .onLongPressGesture(minimumDuration: 0.4) {
                                // Long press completed
                            } onPressingChanged: { pressing in
                                isCurrentlyPressing = pressing
                                if pressing {
                                    // Started pressing - schedule fade after delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        if isCurrentlyPressing {
                                            withAnimation(.fadeOut(MotionDuration.extraShortOut)) {
                                                isPaused = true
                                            }
                                        }
                                    }
                                } else {
                                    // Released - fade back in
                                    withAnimation(.fadeIn(MotionDuration.extraShortIn)) {
                                        isPaused = false
                                    }
                                }
                            }
                        
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onNextSegment()
                            }
                            .onLongPressGesture(minimumDuration: 0.4) {
                                // Long press completed
                            } onPressingChanged: { pressing in
                                isCurrentlyPressing = pressing
                                if pressing {
                                    // Started pressing - schedule fade after delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        if isCurrentlyPressing {
                                            withAnimation(.fadeOut(MotionDuration.extraShortOut)) {
                                                isPaused = true
                                            }
                                        }
                                    }
                                } else {
                                    // Released - fade back in
                                    withAnimation(.fadeIn(MotionDuration.extraShortIn)) {
                                        isPaused = false
                                    }
                                }
                            }
                    }
                }
                
                .cornerRadius(16)
                
                // Composer below the image
                StoryComposer(
                    replyText: $replyText,
                    isReplyFocused: $isReplyFocused,
                )
                .padding(.top, 12)
                .opacity(isPaused && !isDragging ? 0 : 1)
                .animation(.fadeIn(MotionDuration.extraShortIn), value: isPaused)
            }
            .offset(y: dragOffset)
            .scaleEffect(1 - (abs(dragOffset) / 2000.0))
            .opacity(1 - (abs(dragOffset) / 800.0))
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        // Only allow downward dragging
                        if value.translation.height > 0 {
                            isDragging = true
                            dragOffset = value.translation.height
                            
                            // Trigger haptic when crossing dismissal threshold
                            if value.translation.height > 150 && !hasCrossedThreshold {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                hasCrossedThreshold = true
                            }
                        }
                    }
                    .onEnded { value in
                        // Dismiss if dragged down more than 150 points
                        if value.translation.height > 150 {
                            hasCrossedThreshold = false
                            withAnimation(.exitOut) {
                                isPresented = false
                            }
                            isDragging = false
                        } else {
                            // Bounce back with animation
                            withAnimation(.swapShuffleIn(MotionDuration.shortIn)) {
                                dragOffset = 0
                                isDragging = false
                            }
                            hasCrossedThreshold = false
                        }
                    }
            )
        }
    }
}

// MARK: - Story Header
struct StoryHeader: View {
    let name: String
    let profileImage: String
    let segmentCount: Int
    @Binding var currentSegment: Int
    @Binding var progress: Double
    let isActive: Bool
    @Binding var isPresented: Bool
    let isPaused: Bool
    let onSegmentComplete: () -> Void
    
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bars
            HStack(spacing: 4) {
                ForEach(0..<segmentCount, id: \.self) { index in
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color("progressRingOnMediaBackground"))
                            
                            if index < currentSegment {
                                Capsule()
                                    .fill(Color("progressRingOnMediaForeground"))
                            } else if index == currentSegment {
                                Capsule()
                                    .fill(Color("progressRingOnMediaForeground"))
                                    .frame(width: geometry.size.width * progress)
                            }
                        }
                    }
                    .frame(height: 3)
                }
            }
            .frame(height: 3)
            .padding(.top, 8)
            
            // User info
            HStack(alignment: .center, spacing: 8) {
                Image(profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                Text(name)
                    .headline4Typography()
                    .foregroundStyle(Color("primaryTextOnMedia"))
                    .textOnMediaShadow()
                
                Text("\(currentSegment + 1)h")
                    .headline4DeemphasizedTypography()
                    .foregroundStyle(Color("secondaryTextOnMedia"))
                    .textOnMediaShadow()
                
                Spacer()
                
                HStack(spacing: 16) {
                FDSIconButton(
                    icon: "dots-3-horizontal-outline",
                    size: .size24,
                    color: .secondary,
                    onMedia: true,
                    action: {}
                )
                
                FDSIconButton(
                    icon: "cross-filled",
                    size: .size24,
                    color: .secondary,
                    onMedia: true,
                    action: {
                        withAnimation(.exitOut) {
                            isPresented = false
                        }
                    }
                )
                }
            }
            .padding(.top, 4)
        }
        .onAppear {
            if isActive && !isPaused {
                startTimer()
            }
        }
        .onChange(of: isActive) { _, active in
            if active && !isPaused {
                startTimer()
            } else {
                timer?.invalidate()
            }
        }
        .onChange(of: isPaused) { _, paused in
            if paused {
                timer?.invalidate()
            } else if isActive {
                startTimer()
            }
        }
        .onChange(of: currentSegment) { _, _ in
            progress = 0
            if isActive && !isPaused {
                startTimer()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            progress += 0.016 / 5.0 // 5 second duration
            
            if progress >= 1.0 {
                timer?.invalidate()
                progress = 1.0
                onSegmentComplete()
            }
        }
    }
}

// MARK: - Story Composer
struct StoryComposer: View {
    @Binding var replyText: String
    var isReplyFocused: FocusState<Bool>.Binding
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    TextField("Send message...", text: $replyText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .body3Typography()
                        .foregroundStyle(Color("primaryTextOnMedia"))
                        .lineLimit(1...3)
                        .frame(minHeight: 40)
                        .focused(isReplyFocused)
                        .tint(Color("primaryTextOnMedia"))
                        .colorScheme(.dark)
                }
                .frame(minWidth: 180)
                .padding(.horizontal, 12)
                .background(Color("textInputBarBackgroundOnColor"))
                .cornerRadius(20)
                
                Button(action: {}) {
                    Image("love-large")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                Button(action: {}) {
                    Image("like-large")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                Button(action: {}) {
                    Image("haha-large")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                Button(action: {}) {
                    Image("support-large")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                Button(action: {}) {
                    Image("wow-large")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                Button(action: {}) {
                    Image("sad-large")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                Button(action: {}) {
                    Image("angry-large")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        
        let previewStories = [
            StoryData(userName: "Daniela Giménez", storyImage: "jade1", profileImage: "profile1", segments: ["jade1", "jade2", "jade3"]),
            StoryData(userName: "Justin Harper", storyImage: "image1", profileImage: "justinb", segments: ["image1", "image2", "ocean"]),
            StoryData(userName: "Jeremy Gayle", storyImage: "bandpractice1", profileImage: "jeremytay", segments: ["bandpractice1", "bandpractice2", "jadesurfs"])
        ]
        
        var body: some View {
            StoriesView(isPresented: $isPresented, stories: previewStories, startingIndex: 0)
        }
    }
    
    return PreviewWrapper()
}


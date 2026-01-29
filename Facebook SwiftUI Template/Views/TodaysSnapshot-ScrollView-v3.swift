import SwiftUI
import AVKit
import AVFoundation
import CoreMedia

// MARK: - Today's Snapshot Scroll View v3

struct TodaysSnapshotScrollView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var initialY: CGFloat = 0
    @State private var showVideoPlayer = false
    @State private var selectedVideoName: String = ""
    @State private var expandedUnits: [Int: Bool] = [:]  // Track which units are expanded
    @State private var lastScrollOffset: CGFloat = 0
    @State private var hasSnapped = false
    @State private var showSourcesSheet: Int? = nil  // Track which unit's sources to show
    
    // Snap thresholds: Y positions where each unit is "in focus" (top of unit at top of viewport)
    private let focusPositions: [Int: CGFloat] = [
        1: 640,   // Pantone
        2: 1208,  // Jokic
        3: 1797,  // Winter Kids
        4: 2366,  // Toddler Snacks
        5: 2956   // Denver Restaurant Week
    ]
    private let snapThreshold: CGFloat = 280
    
    // DEBUG: Toggle this to show/hide scroll position indicator
    private let showScrollDebug = false
    
    var body: some View {
        // Main Scrollable Content with Anchors
        ScrollViewReader { proxy in
            ZStack(alignment: .topLeading) {
                // Main Content Layer
                VStack(spacing: 0) {
                    // Navigation Bar (fixed at top)
                    FDSNavigationBarCentered(
                        backAction: { dismiss() }
                    )
                    .shadow(
                        color: scrollOffset >= 10 ? Color.black.opacity(0.1) : Color.clear,
                        radius: scrollOffset >= 10 ? 4 : 0,
                        x: 0,
                        y: 1
                    )
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header Section
                            headerSection
                                .id("header")
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
                                                // Set initial position once when first measured
                                                if initialY == 0 {
                                                    initialY = newValue
                                                }
                                                // Calculate scroll: 0 at top, increases as you scroll down
                                                scrollOffset = max(0, initialY - newValue)
                                            }
                                    }
                                )
                            
                            // Highlights Section
                            highlightsSection(proxy: proxy)
                                .id("highlights")
                            
                            // Snapshot Units Container
                            VStack(spacing: 4) {
                                // 1. Pantone's color of the year
                                snapshotUnit(
                                    unitId: 1,
                                    title: "🎨 Pantone's color of the year",
                                    bodyText: "Cloud Dancer reflects a broader shift toward softer, more grounding aesthetics amid cultural and economic uncertainty. Chosen by Pantone's color experts, the tone is intended to resonate across fashion, interiors, branding, and digital design.",
                                    image1: "pantone",
                                    image2: "pantone-1",
                                    image3: "pantone-2",
                                    image4: "pantone-3",
                                    usernames: ["Design Weekly", "Color Trends", "Studio Palette", "Creative Space"]
                                )
                                .id("snapshot-1")
                                
                                // 2. Jokic MVP race lead
                                snapshotUnit(
                                    unitId: 2,
                                    title: "🏀 Jokic MVP race lead",
                                    bodyText: "Even with limited availability during brief injury absences, Jokic's overall impact continues to separate him from other contenders. His efficiency, playmaking, and on-court control remain central to Denver's success, reinforcing his value beyond raw scoring totals.",
                                    image1: "nba_1",
                                    image2: "nba_2",
                                    image3: "nba_3",
                                    image4: "nba_4",
                                    usernames: ["Nuggets Nation", "Mile High Sports", "NBA Central", "Hoop Digest"]
                                )
                                .id("snapshot-2")
                                
                                // 3. Children Museum Winter Programs
                                snapshotUnit(
                                    unitId: 3,
                                    title: "❄️ Children Museum Winter Programs",
                                    bodyText: "New program focused on movement, sensory play, and early learning experiences designed for colder months. Sessions are structured with shorter time blocks and caregiver-friendly pacing, making them accessible for younger age groups. Registration is now open.",
                                    image1: "WInterKids",
                                    image2: "WInterKids-1",
                                    image3: "WInterKids-2",
                                    image4: "WInterKids-3",
                                    usernames: ["Denver Museums", "Family Activities", "Kids Learning", "Play & Explore"]
                                )
                                .id("snapshot-3")
                                
                                // 4. High Protein Toddler Snacks
                                snapshotUnit(
                                    unitId: 4,
                                    title: "🥣 High Protein Toddler Snacks",
                                    bodyText: "Nutrition experts suggest adding ingredients like hemp hearts, peanut butter, or cottage cheese to familiar snacks. These additions help support healthy growth without requiring complex meal prep. Hemp hearts are especially notable as a complete protein, containing all nine essential amino acids.",
                                    image1: "toddler",
                                    image2: "toddler-1",
                                    image3: "toddler-2",
                                    image4: "toddler-3",
                                    usernames: ["Healthy Kids", "Parent Nutrition", "Toddler Meals", "Smart Snacks"]
                                )
                                .id("snapshot-4")
                                
                                // 5. Denver Restaurant Week
                                snapshotUnit(
                                    unitId: 5,
                                    title: "🍣 Denver Restaurant Week",
                                    bodyText: "The annual event features multi-course menus at set price tiers, giving diners a chance to try new restaurants at a lower cost. Participating spots span downtown, RiNo, LoHi, and neighborhood corridors across the metro area. Reservations tend to book early for higher-profile restaurants.",
                                    image1: "DenverRestaruant",
                                    image2: "DenverRestaruant-1",
                                    image3: "DenverRestaruant-2",
                                    image4: "DenverRestaruant-3",
                                    usernames: ["Denver Eats", "Food Scene", "Mile High Dining", "Restaurant Guide"]
                                )
                                .id("snapshot-5")
                                
                                // Footer Unit (End of scroll)
                                footerSection
                                    .id("footer")
                            }
                            .padding(.top, 4)
                            .background(Color(hex: "C9CCD1"))
                        }
                    }
                }
                
                // DEBUG: Scroll Position Indicator (Floating Layer)
                if showScrollDebug {
                    Text("\(Int(scrollOffset))")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(6)
                        .padding(.leading, 12)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
                
                // Floating Action Button (Bottom Layer) - Conditional based on scroll position
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        if scrollOffset < 2978 {
                            if scrollOffset < 10 {
                                // Show "Explore Today's snapshot" button when near top
                                FDSActionChip(
                                    size: .medium,
                                    label: "Explore Today's snapshot",
                                    leftAddOn: .icon("arrow-down-outline"),
                                    customColor: Color("accentColor"),
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.45)) {
                                            proxy.scrollTo("snapshot-1", anchor: .top)
                                        }
                                    }
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 2)
                                .transition(.opacity)
                            } else {
                                // Show icon-only "back to top" button when scrolled down
                                FDSActionChip(
                                    size: .medium,
                                    label: "",
                                    leftAddOn: .icon("arrow-up-outline"),
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.45)) {
                                            proxy.scrollTo("header", anchor: .top)
                                        }
                                    }
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 2)
                                .transition(.opacity)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .allowsHitTesting(true)
            }
            .navigationBarHidden(true)
            .onChange(of: scrollOffset) { oldValue, newValue in
                checkAndSnapIfNeeded(proxy: proxy, oldOffset: oldValue, newOffset: newValue)
            }
        }
        .fullScreenCover(isPresented: $showVideoPlayer) {
            SnapshotReelPlayerView(videoName: selectedVideoName, isPresented: $showVideoPlayer)
                .transition(.move(edge: .trailing))
        }
        .overlay(
            Group {
                if showSourcesSheet != nil {
                    // Dark overlay background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showSourcesSheet = nil
                        }
                    
                    // Bottom mask frame (covers content behind bottom sheet)
                    VStack {
                        Spacer()
                        Color(hex: "F0F2F5")
                            .frame(height: 100)
                            .ignoresSafeArea(edges: .bottom)
                    }
                    
                    // Sources Bottom Sheet
                    VStack {
                        Spacer()
                        sourcesBottomSheet(unitId: showSourcesSheet!)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3), value: showSourcesSheet)
                }
            }
        )
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title + Meta Container with specific padding
            VStack(alignment: .leading, spacing: 0) {
                // Title
                Text("Today's snapshot")
                    .headline1EmphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)  // Inner top padding
                
                // 12px gap between title and meta
                Spacer().frame(height: 12)
                
                // Metadata
                Text(formattedDate + " · Generated by AI")
                    .meta2Typography()
                    .foregroundStyle(Color("secondaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)  // Inner bottom padding
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)  // Outer top padding
            .padding(.bottom, 20)  // Outer bottom padding
            
            // 0px section divider (no padding)
            // Weather Action Chip
            HStack(spacing: 8) {
                FDSActionChip(
                    size: .medium,
                    label: "☀️72° Palo Alto",
                    isMenu: true,
                    action: {}
                )
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("surfaceBackground"))
    }
    
    // MARK: - Highlights Section
    
    private func highlightsSection(proxy: ScrollViewProxy) -> some View {
        // ListCellTable Container (gray background: F2F4F7)
        VStack(spacing: 0) {
            // White Card with list items
            VStack(spacing: 0) {
                // Unit Header: "Highlights" (has built-in padding: 12h, 20t, 8b)
                FDSUnitHeader(
                    headlineText: "Highlights",
                    hierarchyLevel: .level3
                )
                .padding(.top, 8)  // Additional 8px on top of built-in 20px = 28px total
                // FDSUnitHeader already has: 20px top, 8px bottom, 12px horizontal
                // Need 16px between header and first item: 8px (built-in) + 8px = 16px
                
                // Group Container (Items Container)
                VStack(spacing: 0) {
                    ForEach(highlightItems.indices, id: \.self) { index in
                        highlightListItem(item: highlightItems[index], index: index, proxy: proxy)
                    }
                }
                .padding(.top, 8)  // 8px (UnitHeader bottom) + 8px = 16px total
                .padding(.bottom, 8)
            }
            .background(Color("cardBackground"))  // White background
            .cornerRadius(8)
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
        .padding(.horizontal, 12)
        .background(Color("bottomSheetBackgroundDeemphasized"))  // Gray background F2F4F7
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 0) {
            // Header message
            VStack(spacing: 0) {
                Text("Nice job, you're all caught up today!")
                    .headline4Typography()
                    .foregroundColor(Color("primaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            // "Show more of these topics" section
            FDSUnitHeader(
                headlineText: "Show more of these topics",
                hierarchyLevel: .level3
            )
            
            // Action chips group
            HStack(spacing: 8) {
                FDSActionChip(
                    size: .medium,
                    label: "Grammys",
                    action: {}
                )
                
                FDSActionChip(
                    size: .medium,
                    label: "Robotaxis",
                    action: {}
                )
                
                FDSActionChip(
                    size: .medium,
                    label: "Add a topic",
                    leftAddOn: .icon("plus-outline"),
                    action: {}
                )
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 20)
            
            // "Previous snapshots" footer button
            Button(action: {}) {
                HStack(spacing: 4) {
                    Text("Previous snapshots")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("secondaryText"))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color("secondaryText"))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 32)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .padding(.bottom, 12)
        }
        .background(Color("cardBackground"))  // White background
    }
    
    // MARK: - Snapshot Unit
    
    private func snapshotUnit(unitId: Int, title: String, bodyText: String, image1: String = "pantone_1", image2: String = "pantone_2", image3: String? = nil, image4: String? = nil, usernames: [String] = ["User", "User", "User", "User"]) -> some View {
        VStack(spacing: 0) {
            // Unit Header with emoji + title + 3-dot menu
            FDSUnitHeader(
                headlineText: title,
                hierarchyLevel: .level3,
                rightAddOn: .iconButton(
                    icon: "dots-3-horizontal-filled",
                    action: {},
                    isDisabled: false
                )
            )
            
            // Body Text - Body 3 Typography
            Text(bodyText)
                .body3Typography()
                .foregroundColor(Color("primaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            
            // "Sources" Action Chip
            HStack {
                FDSActionChip(
                    size: .small,
                    label: "Sources",
                    isMenu: false,
                    action: { showSourcesSheet = unitId }
                )
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            
            // "More about this" Heading - Headline 4
            Text("More about this")
                .headline4Typography()
                .foregroundColor(Color("primaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            
            // Row of Posts - 2x1 by default, 2x2 when expanded
            VStack(spacing: 8) {
                // First Row (always visible)
                HStack(spacing: 8) {
                    // Post 1
                    Button(action: {
                        selectedVideoName = "dance"
                        showVideoPlayer = true
                    }) {
                        placeholderPostCard(imageName: image1, username: usernames[0])
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Post 2
                    Button(action: {
                        selectedVideoName = "dance"
                        showVideoPlayer = true
                    }) {
                        placeholderPostCard(imageName: image2, username: usernames[1])
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Second Row (visible when expanded)
                if expandedUnits[unitId] == true {
                    HStack(spacing: 8) {
                        // Post 3
                        Button(action: {
                            selectedVideoName = "dance"
                            showVideoPlayer = true
                        }) {
                            placeholderPostCard(imageName: image3 ?? image1, username: usernames[2])
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Post 4
                        Button(action: {
                            selectedVideoName = "dance"
                            showVideoPlayer = true
                        }) {
                            placeholderPostCard(imageName: image4 ?? image2, username: usernames[3])
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            // "See more" / "See less" Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    expandedUnits[unitId] = !(expandedUnits[unitId] ?? false)
                }
            }) {
                HStack(spacing: 4) {
                    Text(expandedUnits[unitId] == true ? "See less" : "See more")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("secondaryText"))
                    
                    Image(systemName: expandedUnits[unitId] == true ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color("secondaryText"))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 32)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, -4)
            
            // Footer Action Chips (thumbs up/down)
            HStack(spacing: 8) {
                FDSActionChip(
                    size: .large,
                    label: "",
                    leftAddOn: .icon("hand-thumbs-up-outline"),
                    action: {}
                )
                
                FDSActionChip(
                    size: .large,
                    label: "",
                    leftAddOn: .icon("hand-thumbs-down-outline"),
                    action: {}
                )
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color("cardBackground"))  // White background
    }
    
    // MARK: - Placeholder Post Card
    
    private func placeholderPostCard(imageName: String, username: String = "User") -> some View {
        // ZStack with full-bleed image and overlaid text
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Base Layer: Full-bleed image fills entire card
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // Top Layer: Header with text shadow for readability
                HStack(spacing: 8) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                    
                    Text(username)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                }
                .padding(12)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("borderUiEmphasis"), lineWidth: 1)
            )
            .clipped()
        }
        .aspectRatio(172/259.571, contentMode: .fit)
    }
    
    // MARK: - Highlight List Item
    
    private func highlightListItem(item: HighlightItem, index: Int, proxy: ScrollViewProxy) -> some View {
        // Body Outer Container: 8px top/bottom, 0px left/right
        Button(action: {
            withAnimation(.easeInOut(duration: 0.45)) {
                proxy.scrollTo("snapshot-\(index + 1)", anchor: .top)
            }
        }) {
            // ContentRightAddon: 12px left/right, 0px top/bottom, 12px gap between children
            HStack(alignment: .top, spacing: 12) {
                // TextPairing: 4px top/bottom, 0px left/right, 2px gap, grow
                VStack(alignment: .leading, spacing: 2) {
                    // TextBlock: 15px font, 20px line-height
                    (Text(item.title)
                        .font(.body3Link)  // Body 3 Link (bold/semibold)
                    + Text(" ")
                    + Text(item.body)
                        .font(.body3))  // Body 3 (regular)
                        .foregroundColor(Color("primaryText"))
                }
                .padding(.vertical, 4)  // TextPairing padding
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // ProfilePhotoCircle32Px
                Image(item.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 12)  // ContentRightAddon horizontal padding
            .contentShape(Rectangle())
        }
        .padding(.vertical, 8)  // Body Outer Container vertical padding
        .buttonStyle(FDSPressedState(cornerRadius: 0))
    }
    
    // MARK: - Helpers
    
    private func checkAndSnapIfNeeded(proxy: ScrollViewProxy, oldOffset: CGFloat, newOffset: CGFloat) {
        // Prevent multiple snaps in quick succession
        guard !hasSnapped else { return }
        
        // Don't snap if we're beyond 2958 (allow free scrolling at bottom)
        if newOffset > 2958 {
            return
        }
        
        let isScrollingUp = newOffset > oldOffset
        
        // Check each focus position to see if we're in snap range
        for (unitId, focusPosition) in focusPositions {
            let distanceToFocus = focusPosition - newOffset
            
            if isScrollingUp {
                // Scrolling upward: snap when approaching from below (within 280px below focus)
                if distanceToFocus >= 0 && distanceToFocus <= snapThreshold {
                    print("🧲 SNAP UP! Scrolled to \(Int(newOffset)), snapping to unit \(unitId) at \(Int(focusPosition))")
                    performSnap(to: unitId, proxy: proxy)
                    break
                }
            } else {
                // Scrolling downward: snap when approaching from above (within 280px above focus)
                if distanceToFocus <= 0 && abs(distanceToFocus) <= snapThreshold {
                    print("🧲 SNAP DOWN! Scrolled to \(Int(newOffset)), snapping to unit \(unitId) at \(Int(focusPosition))")
                    performSnap(to: unitId, proxy: proxy)
                    break
                }
            }
        }
    }
    
    private func performSnap(to unitId: Int, proxy: ScrollViewProxy) {
        hasSnapped = true
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            proxy.scrollTo("snapshot-\(unitId)", anchor: .top)
        }
        
        // Reset snap flag after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            hasSnapped = false
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }
    
    // MARK: - Sources Bottom Sheet
    
    private func sourcesBottomSheet(unitId: Int) -> some View {
        VStack(spacing: 0) {
            // Scroll Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("bottomSheetHandle"))
                .frame(width: 40, height: 4)
                .padding(.top, 6)
                .padding(.bottom, 6)
            
            // Header with title and X button
            ZStack {
                Text("Sources")
                    .headline3EmphasizedTypography()
                    .foregroundColor(Color("primaryText"))
                
                HStack {
                    Spacer()
                    Button(action: {
                        showSourcesSheet = nil
                    }) {
                        Image("nav-cross-filled")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color("primaryIcon"))
                    }
                    .padding(.trailing, 12)
                }
            }
            .frame(height: 48)
            .background(Color("bottomSheetBackgroundDeemphasized"))
            
            // Source Links List
            VStack(spacing: 12) {
                // Container with white background for list items
                VStack(spacing: 0) {
                    ForEach(getSourceLinks(for: unitId), id: \.title) { source in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(source.title)
                                .headline4Typography()
                                .foregroundColor(Color("primaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(source.url)
                                .meta3Typography()
                                .foregroundColor(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        
                        if source.title != getSourceLinks(for: unitId).last?.title {
                            Divider()
                                .background(Color("divider"))
                                .padding(.horizontal, 12)
                        }
                    }
                }
                .background(Color("cardBackground"))
                .cornerRadius(8)
            }
            .padding(12)
            .background(Color("bottomSheetBackgroundDeemphasized"))
            
            // Home Affordance (iOS bottom bar indicator)
            Color.clear
                .frame(height: 34)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black)
                        .frame(width: 134, height: 5)
                )
                .background(Color("bottomSheetBackgroundDeemphasized"))
        }
        .background(Color("bottomSheetBackgroundDeemphasized"))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -1)
        .shadow(color: Color.black.opacity(0.05), radius: 0, x: 0, y: -1)
    }
    
    // MARK: - Source Links Data
    
    private func getSourceLinks(for unitId: Int) -> [(title: String, url: String)] {
        switch unitId {
        case 1: // Pantone
            return [
                (title: "1. COLOR OF THE YEAR - PANTONE", url: "https://www.pantone.com/articles/color-of-the-year"),
                (title: "2. Pantone names its Color of the Year for...", url: "https://www.cnn.com/2025/12/04/style/pantone"),
                (title: "3. A Guide to All the Pantone Colors", url: "https://www.housebeautiful.com/colors/g69646915")
            ]
        case 2: // Jokic
            return [
                (title: "1. Nikola Jokić Leading MVP Race Again", url: "https://www.espn.com/nba/story/jokic-mvp"),
                (title: "2. Denver Nuggets Center Dominates Stats", url: "https://www.nba.com/stats/jokic-efficiency"),
                (title: "3. MVP Voting Tracker - January Update", url: "https://www.basketball-reference.com/mvp")
            ]
        case 3: // Winter Kids
            return [
                (title: "1. Winter Programs at Children's Museum", url: "https://www.mychildrensmuseum.org/winter"),
                (title: "2. Sensory Play for Cold Weather Months", url: "https://www.earlylearning.org/sensory-winter"),
                (title: "3. Registration Opens for 2026 Sessions", url: "https://www.mychildrensmuseum.org/register")
            ]
        case 4: // Toddler Snacks
            return [
                (title: "1. High-Protein Snacks for Toddlers", url: "https://www.healthline.com/nutrition/toddler-protein"),
                (title: "2. Hemp Hearts: Complete Protein Source", url: "https://www.medicalnewstoday.com/hemp-hearts"),
                (title: "3. Easy Toddler Snack Recipes", url: "https://www.foodnetwork.com/toddler-snacks")
            ]
        case 5: // Denver Restaurant Week
            return [
                (title: "1. Denver Restaurant Week 2026 Guide", url: "https://www.denverrestaurantweek.com"),
                (title: "2. Top Participating Restaurants in RiNo", url: "https://www.westword.com/dining/restaurant-week"),
                (title: "3. How to Make Reservations Early", url: "https://www.opentable.com/denver-restaurant-week")
            ]
        default:
            return []
        }
    }
}

// MARK: - Highlight Item Model

struct HighlightItem {
    let title: String
    let body: String
    let profileImage: String
}

// MARK: - Sample Data

private let highlightItems: [HighlightItem] = [
    HighlightItem(
        title: "Pantone's Color of the Year",
        body: "for 2026, Cloud Dancer, emphasizes connection, adaptability, and optimism.",
        profileImage: "pantone"
    ),
    HighlightItem(
        title: "Jokic MVP race lead",
        body: "holds despite missed games, keeping league-wide debate intense through the midseason stretch.",
        profileImage: "nba_1"
    ),
    HighlightItem(
        title: "Children Museum Winter Programs",
        body: "expansion adds new hands-on activities for toddlers and young children.",
        profileImage: "WInterKids"
    ),
    HighlightItem(
        title: "High protein toddler snacks",
        body: "can be easily upgraded using simple pantry additions recommended by dietitians.",
        profileImage: "toddler"
    ),
    HighlightItem(
        title: "Denver Restaurant Week Dates",
        body: "were announced, featuring prix-fixe menus at 300+ restaurants.",
        profileImage: "DenverRestaruant"
    )
]

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Simple Video Player View

struct SimpleVideoPlayerView: View {
    let videoName: String
    @Binding var isPresented: Bool
    @State private var isPlaying = true
    @State private var player: AVPlayer?
    @State private var isLiked = false
    @State private var likeCount = 342
    @State private var isCaptionExpanded = false
    
    var body: some View {
        ZStack {
            // Video Player Base
            ZStack {
                ZStack {
                    if let player = player {
                        VideoPlayer(player: player)
                            .ignoresSafeArea()
                            .onAppear {
                                player.play()
                            }
                            .onDisappear {
                                player.pause()
                            }
                    }
                    
                    // Dim overlay when paused
                    Color.black.opacity(isPlaying ? 0 : 0.3)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .animation(.linear(duration: 0.2), value: isPlaying)
                }
                
                // Content Protection Gradient
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
            .onTapGesture {
                withAnimation(.linear(duration: 0.2)) {
                    isPlaying.toggle()
                    if isPlaying {
                        player?.play()
                    } else {
                        player?.pause()
                    }
                }
            }
            
            // Back Button (Top Left)
            VStack {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                Spacer()
            }
            
            // Bottom UI Chrome
            VStack {
                Spacer()
                
                HStack(alignment: .bottom, spacing: 12) {
                    // Left side: Profile + Caption
                    VStack(alignment: .leading, spacing: 12) {
                        // Profile Section
                        HStack(alignment: .center, spacing: 8) {
                            Image("pantone_1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .center, spacing: 4) {
                                    Text("Becker Threads")
                                        .headline4Typography()
                                        .textOnMediaShadow()
                                        .foregroundStyle(Color("primaryTextOnMedia"))
                                    
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
                                
                                // Music Info
                                HStack(spacing: 4) {
                                    Image("music-filled")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundStyle(Color("secondaryIconOnMedia"))
                                        .iconOnMediaShadow()
                                    
                                    Text("Original audio · Becker Threads")
                                        .meta4Typography()
                                        .textOnMediaShadow()
                                        .foregroundStyle(Color("secondaryTextOnMedia"))
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                        }
                        
                        // Caption
                        Text("Cloud Dancer by Pantone - the 2026 Color of the Year 🎨")
                            .body3Typography()
                            .textOnMediaShadow()
                            .foregroundStyle(Color("primaryTextOnMedia"))
                            .lineLimit(isCaptionExpanded ? nil : 1)
                            .truncationMode(.tail)
                            .animation(.linear(duration: 0.2), value: isCaptionExpanded)
                            .highPriorityGesture(
                                TapGesture()
                                    .onEnded { _ in
                                        isCaptionExpanded.toggle()
                                    }
                            )
                    }
                    
                    // Right side: Vertical UFI Buttons
                    VStack(spacing: 0) {
                        ReelUFIButton(
                            icon: "like-outline",
                            likedIcon: "like",
                            count: likeCount.formattedString,
                            isLiked: $isLiked,
                            likeCount: $likeCount
                        )
                        ReelUFIButton(icon: "comment-outline", count: "127")
                        ReelUFIButton(icon: "share-outline", count: "42")
                        ReelUFIButton(icon: "bookmark-outline", count: "Save")
                        ReelUFIButton(icon: "dots-3-horizontal-outline", count: nil)
                    }
                }
                .padding(.leading, 12)
                .padding(.bottom, 12)
            }
            
            // Play/Pause Controls (centered)
            if !isPlaying {
                VStack {
                    Spacer()
                    HStack(spacing: 16) {
                        Button {
                            // Skip backward 10 seconds
                            if let player = player {
                                let currentTime = player.currentTime()
                                let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
                                player.seek(to: newTime)
                                player.play()
                                isPlaying = true
                            }
                        } label: {
                            Image("skip-backward-10-filled")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color("secondaryButtonIconOnMedia"))
                                .frame(width: 40, height: 40)
                                .background {
                                    Circle()
                                        .fill(.thinMaterial)
                                        .colorScheme(.dark)
                                }
                        }
                        .buttonStyle(FDSPressedState(circle: true, isOnMedia: true, scale: .small))
                        
                        Button {
                            isPlaying = true
                            player?.play()
                        } label: {
                            Image("play-filled")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color("secondaryButtonIconOnMedia"))
                                .frame(width: 60, height: 60)
                                .background {
                                    Circle()
                                        .fill(.thinMaterial)
                                        .colorScheme(.dark)
                                }
                        }
                        .buttonStyle(FDSPressedState(circle: true, isOnMedia: true, scale: .small))

                        Button {
                            // Skip forward 10 seconds
                            if let player = player {
                                let currentTime = player.currentTime()
                                let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
                                player.seek(to: newTime)
                                player.play()
                                isPlaying = true
                            }
                        } label: {
                            Image("skip-forward-10-filled")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color("secondaryButtonIconOnMedia"))
                                .frame(width: 40, height: 40)
                                .background {
                                    Circle()
                                        .fill(.thinMaterial)
                                        .colorScheme(.dark)
                                }
                        }
                        .buttonStyle(FDSPressedState(circle: true, isOnMedia: true, scale: .small))
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        // Try to load the video from the bundle
        if let bundleURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            player = AVPlayer(url: bundleURL)
            
            // Mute the player
            player?.isMuted = true
        } else {
            // If video doesn't exist, create a blank player
            print("Video not found: \(videoName).mp4")
            player = AVPlayer()
        }
        
        // Setup looping
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
}

// MARK: - Reel UFI Button

struct ReelUFIButton: View {
    private enum ButtonType {
        case action(icon: String, count: String?, action: () -> Void)
        case like(icon: String, likedIcon: String, isLiked: Binding<Bool>, likeCount: Binding<Int>)
    }
    
    private let buttonType: ButtonType
    @State private var isPressed = false
    
    init(icon: String, count: String? = nil, action: @escaping () -> Void = {}) {
        self.buttonType = .action(icon: icon, count: count, action: action)
    }
    
    init(icon: String, likedIcon: String, count: String, isLiked: Binding<Bool>, likeCount: Binding<Int>) {
        self.buttonType = .like(icon: icon, likedIcon: likedIcon, isLiked: isLiked, likeCount: likeCount)
    }
    
    var body: some View {
        Button {
            switch buttonType {
            case .action(_, _, let action):
                action()
            case .like(_, _, let isLiked, let likeCount):
                withAnimation {
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
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    NavigationStack {
        TodaysSnapshotScrollView()
    }
}

// MARK: - View Extension for Custom Corner Radius

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

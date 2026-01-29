import SwiftUI

// MARK: - Data Models

enum SearchResultType: CaseIterable {
    case post
    case person
    case reel
    case group
    case ad
}

struct SearchResult: Identifiable {
    let id = UUID()
    let type: SearchResultType
    let authorName: String
    let profileImage: String
    let timeAgo: String
    let contentImage: String?
    let title: String?
    let subtitle: String?
    let likes: Int?
    let isVerified: Bool
    let isSponsored: Bool
    let isSquare: Bool
}

// MARK: - Sample Data

let sampleSearchResults: [SearchResult] = [
    SearchResult(type: .post, authorName: "Sarah Chen", profileImage: "profile1", timeAgo: "2h", contentImage: "image1", title: "Amazing cinnamon roll recipe", subtitle: nil, likes: 1250, isVerified: true, isSponsored: false, isSquare: false),
    SearchResult(type: .post, authorName: "Mike Johnson", profileImage: "profile2", timeAgo: "5h", contentImage: "image2", title: "Weekend brunch vibes", subtitle: nil, likes: 890, isVerified: false, isSponsored: false, isSquare: false),
    SearchResult(type: .ad, authorName: "Samsung", profileImage: "profile4", timeAgo: "Sponsored", contentImage: "image4", title: "New Galaxy phone available", subtitle: "Pre-order now", likes: nil, isVerified: true, isSponsored: true, isSquare: true),
    SearchResult(type: .person, authorName: "Jennifer Smith", profileImage: "profile3", timeAgo: "Friend", contentImage: "image3", title: nil, subtitle: "12 mutual friends", likes: nil, isVerified: true, isSponsored: false, isSquare: false),
    SearchResult(type: .reel, authorName: "Alex Kim", profileImage: "profile5", timeAgo: "1d", contentImage: "image5", title: "Quick baking tips", subtitle: nil, likes: 5430, isVerified: false, isSponsored: false, isSquare: false),
    SearchResult(type: .group, authorName: "Baking Community", profileImage: "profile6", timeAgo: "Group", contentImage: "story1", title: nil, subtitle: "45K members", likes: nil, isVerified: false, isSponsored: false, isSquare: false),
    SearchResult(type: .post, authorName: "David Lee", profileImage: "profile7", timeAgo: "3h", contentImage: "story2", title: "Best bakery in town", subtitle: nil, likes: 2100, isVerified: true, isSponsored: false, isSquare: false),
    SearchResult(type: .post, authorName: "Emma Wilson", profileImage: "profile8", timeAgo: "6h", contentImage: "story3", title: "Homemade pastries", subtitle: nil, likes: 1670, isVerified: false, isSponsored: false, isSquare: true)
]

// MARK: - Main View

struct SearchResultsPageView: View {
    let searchQuery: String
    
    @State private var selectedTabIndex = 0
    @State private var searchResults: [SearchResult] = sampleSearchResults
    
    private let tabs = [
        SubNavigationItem("All"),
        SubNavigationItem("Posts"),
        SubNavigationItem("People"),
        SubNavigationItem("Reels"),
        SubNavigationItem("Groups"),
        SubNavigationItem("Pages")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            FDSSubNavigationBar(
                items: tabs,
                selectedIndex: $selectedTabIndex
            )
            .padding(.vertical, 8)
            .background(Color("surfaceBackground"))
            
            ScrollView {
                LazyVStack(spacing: 4) {
                    let results = getResultsForTab(tabs[selectedTabIndex].title)
                    let rows = groupResultsIntoRows(results)
                    
                    // Debug info (remove this later)
                    if rows.isEmpty {
                        VStack(spacing: 12) {
                            Text("No results found for '\(searchQuery)'")
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                            Text("Try switching tabs or searching for something else")
                                .body3Typography()
                                .foregroundStyle(Color("tertiaryText"))
                        }
                        .padding(.top, 100)
                    }
                    
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        if row.count == 1, let firstResult = row.first, firstResult.isSquare {
                            SearchTile(result: firstResult, aspectRatio: 1.0, showDotsMenu: true)
                                .padding(.horizontal, 4)
                        } else {
                            HStack(spacing: 4) {
                                ForEach(row) { result in
                                    SearchTile(result: result, aspectRatio: 9/16, showDotsMenu: false)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .background(Color("surfaceBackground"))
        }
        .hideFDSTabBar(true)
    }
    
    private func getResultsForTab(_ tab: String) -> [SearchResult] {
        switch tab {
        case "All":
            return searchResults
        case "Posts":
            return searchResults.filter { $0.type == .post && !$0.isSponsored }
        case "People":
            return searchResults.filter { $0.type == .person }
        case "Reels":
            return searchResults.filter { $0.type == .reel }
        case "Groups":
            return searchResults.filter { $0.type == .group }
        case "Pages":
            return searchResults.filter { $0.type == .person && $0.isVerified }
        default:
            return []
        }
    }
    
    private func groupResultsIntoRows(_ results: [SearchResult]) -> [[SearchResult]] {
        var rows: [[SearchResult]] = []
        var currentVerticalPair: [SearchResult] = []
        
        for result in results {
            if result.isSquare {
                // Add any pending vertical pair first
                if !currentVerticalPair.isEmpty {
                    rows.append(currentVerticalPair)
                    currentVerticalPair = []
                }
                // Add square tile
                rows.append([result])
            } else {
                // Add to vertical pair
                currentVerticalPair.append(result)
                if currentVerticalPair.count == 2 {
                    rows.append(currentVerticalPair)
                    currentVerticalPair = []
                }
            }
        }
        
        // Add any remaining vertical tile
        if !currentVerticalPair.isEmpty {
            rows.append(currentVerticalPair)
        }
        
        return rows
    }
}

// MARK: - Unified Tile Component

struct SearchTile: View {
    let result: SearchResult
    let aspectRatio: CGFloat
    let showDotsMenu: Bool
    
    init(result: SearchResult, aspectRatio: CGFloat = 9/16, showDotsMenu: Bool = true) {
        self.result = result
        self.aspectRatio = aspectRatio
        self.showDotsMenu = showDotsMenu
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let contentImage = result.contentImage {
                    Image(contentImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
                
                VStack {
                    LinearGradient(
                        stops: [
                            .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 0.0),
                            .init(color: Color("overlayOnMediaLight").opacity(0.1), location: 0.2),
                            .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.5),
                            .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.8),
                            .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 1.0)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 100)
                    
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
                    .frame(height: 80)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    // Top Actor Row
                    HStack(alignment: .top, spacing: 8) {
                        Image(result.profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(result.authorName)
                                    .body4LinkTypography()
                                    .foregroundStyle(Color("primaryTextOnMedia"))
                                    .textOnMediaShadow()
                                    .lineLimit(1)
                                
                                if result.isVerified {
                                    Image("badge-checkmark-filled")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                        .foregroundStyle(Color("primaryIconOnMedia"))
                                        .iconOnMediaShadow()
                                }
                            }
                            
                            Text(result.timeAgo)
                                .meta4Typography()
                                .foregroundStyle(Color("secondaryTextOnMedia"))
                                .textOnMediaShadow()
                        }
                        .padding(.top, -2)
                        
                        Spacer()
                        
                        if showDotsMenu {
                            Image("dots-3-horizontal-filled")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color("primaryIconOnMedia"))
                                .iconOnMediaShadow()
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // Bottom Content
                    if let title = result.title {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(title)
                                .body4Typography()
                                .foregroundStyle(Color("primaryTextOnMedia"))
                                .textOnMediaShadow()
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    SearchResultsPageView(searchQuery: "cinnamon rolls")
        .environmentObject(FDSTabBarHelper())
}


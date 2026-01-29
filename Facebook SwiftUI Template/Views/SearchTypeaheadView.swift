import SwiftUI

// MARK: - Data Models

struct SearchItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let imageName: String?
    let iconName: String?
    let profilePhotoType: FDSListCellProfilePhotoType?
    let hasNewContent: Bool
}

// MARK: - Sample Data

let recentSearches: [SearchItem] = [
    SearchItem(title: "Rose Wang", subtitle: "Friend", imageName: "profile11", iconName: nil, profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "Alex Walker", subtitle: "Friend", imageName: "profile2", iconName: nil, profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "golden state warriors rockets game", subtitle: nil, imageName: nil, iconName: "clock-filled", profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "best nyc burgers", subtitle: "Popular now", imageName: nil, iconName: "clock-filled", profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "Mark Zuckerberg", subtitle: "7 mutual friends", imageName: "zuck", iconName: nil, profilePhotoType: nil, hasNewContent: false)
]

let suggestedSearches: [SearchItem] = [
    SearchItem(title: "Active car chase in Austin, TX", subtitle: nil, imageName: "image8", iconName: nil, profilePhotoType: .nonActor, hasNewContent: false),
    SearchItem(title: "Gardening tips", subtitle: nil, imageName: "image6", iconName: nil, profilePhotoType: .nonActor, hasNewContent: false),
    SearchItem(title: "Daniela Giménez", subtitle: "19 mutual friends", imageName: "profile6", iconName: nil, profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "Crochet for beginners", subtitle: nil, imageName: nil, iconName: "magnifying-glass-filled", profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "Zayn Malik canceled Mexico City concert", subtitle: nil, imageName: nil, iconName: "magnifying-glass-filled", profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "Bay Area Skate Club", subtitle: "Public group · 8k members", imageName: "image4", iconName: nil, profilePhotoType: .nonActor, hasNewContent: false)
]

let typeaheadData: [SearchItem] = [
    SearchItem(title: "Justin Bieber", subtitle: "Musician/band · 90M followers", imageName: "justinb", iconName: nil, profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "Justin Trudeau", subtitle: "Politician · 8.5M followers", imageName: "justint", iconName: nil, profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "justin bieber update", subtitle: nil, imageName: nil, iconName: "magnifying-glass-filled", profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "justin trudeau tariffs", subtitle: nil, imageName: nil, iconName: "magnifying-glass-filled", profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "justin baldoni lawsuit", subtitle: nil, imageName: nil, iconName: "magnifying-glass-filled", profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "Justin Leung", subtitle: "Friend", imageName: "profile12", iconName: nil, profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "Justin Torres", subtitle: "Friend · Birthday tomorrow", imageName: "profile14", iconName: nil, profilePhotoType: nil, hasNewContent: false),
    SearchItem(title: "Justin Magana", subtitle: "Friend", imageName: "profile13", iconName: nil, profilePhotoType: nil, hasNewContent: false)
]

// MARK: - Main View

struct SearchTypeaheadView: View {
    @Binding var searchText: String
    let onItemSelect: (String) -> Void
    
    @State private var recentItems: [SearchItem] = recentSearches
    @State private var suggestedItems: [SearchItem] = suggestedSearches
    
    var body: some View {
        ScrollView {
            if searchText.isEmpty {
                VStack(spacing: 0) {
                    FDSUnitHeader(
                        headlineText: "Recent",
                        hierarchyLevel: .level3,
                        rightAddOn: .actionText(label: "See all", action: {})
                    )
                    .padding(.top, -8)
                    
                    ForEach(recentItems) { item in
                        searchListCell(for: item)
                    }
                    
                    FDSUnitHeader(
                        headlineText: "Suggested",
                        hierarchyLevel: .level3,
                        rightAddOn: .actionText(label: "Refresh", action: {})
                    )
                    
                    ForEach(suggestedItems) { item in
                        searchListCell(for: item)
                    }
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredTypeaheadResults) { item in
                        searchListCell(for: item)
                    }
                }
            }
        }
        .background(Color("surfaceBackground"))
        .hideFDSTabBar(true)
    }
    
    private var filteredTypeaheadResults: [SearchItem] {
        typeaheadData.filter { item in
            item.title.localizedCaseInsensitiveContains(searchText) ||
            item.subtitle?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    @ViewBuilder
    private func searchListCell(for item: SearchItem) -> some View {
        FDSListCell(
            hierarchyLevel: .level4,
            headlineText: item.title,
            headlineLineLimit: 1,
            bodyText: item.subtitle,
            leftAddOn: leftAddOn(for: item),
            rightAddOn: searchText.isEmpty ? .icon("dots-3-horizontal-filled") : nil,
            action: {
                onItemSelect(item.title)
            }
            
        )
    }
    
    private func leftAddOn(for item: SearchItem) -> FDSListCellLeftAddOn {
        if let imageName = item.imageName {
            let photoType = item.profilePhotoType ?? .actor
            return .profilePhoto(imageName, type: photoType, size: .size32)
        } else if let iconName = item.iconName {
            return .containedIcon(iconName, size: .size32)
        } else {
            return .containedIcon("magnifying-glass-filled", size: .size32)
        }
    }
}

// MARK: - Main Search Container View

struct SearchView: View {
    @State private var searchText = ""
    @State private var showSearchResults = false
    @State private var isLoading = false
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar with Search
            FDSNavigationBarSearch(
                    searchText: $searchText,
                    placeholder: "Search with Meta AI",
                    isFocused: $isSearchFocused,
                    backAction: {
                        dismiss()
                    },
                    onSubmit: {
                        if !searchText.isEmpty {
                            performSearch()
                        }
                    }
                )
                .onChange(of: searchText) { oldValue, newValue in
                    if newValue.isEmpty {
                        showSearchResults = false
                        isLoading = false
                    }
                }
                
                if isLoading {
                    VStack(spacing: 12) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("secondaryIcon")))
                        Text("Searching...")
                            .body4Typography()
                            .foregroundStyle(Color("secondaryText"))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("surfaceBackground"))
                } else if showSearchResults {
                    // Search Results Page
                    SearchResultsPageView(searchQuery: searchText)
                } else {
                    // Typeahead or Null State
                    SearchTypeaheadView(
                        searchText: $searchText
                    ) { query in
                        searchText = query
                        performSearch()
                    }
                }
        }
        .background(Color("surfaceBackground"))
        .hideFDSTabBar(true)
        .onAppear {
            isSearchFocused = true
        }
    }
    
    private func performSearch() {
        isSearchFocused = false
        hideKeyboard()
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            showSearchResults = true
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview

#Preview {
    SearchView()
        .environmentObject(FDSTabBarHelper())
}


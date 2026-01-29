import SwiftUI

// MARK: - Snapshot Data Models

struct SnapshotItem: Identifiable {
    let id = UUID()
    let emoji: String
    let headline: String
    let meta: String
    let detailTitle: String
    let summaryParagraph: String
    let relatedPosts: [SnapshotPostData]
    let profileImage: String
    let mediaItems: [MediaItem]
}

struct SnapshotPostData: Identifiable {
    let id = UUID()
    let authorName: String
    let profileImage: String
    let isVerified: Bool
    let timeAgo: String
    let text: String?
    let imageName: String?
    let likeCount: String
    let commentCount: String
    let shareCount: String
    let reactions: [String]
}

struct MediaItem: Identifiable {
    let id = UUID()
    let imageName: String
    let aspectRatio: MediaAspectRatio
}

enum MediaAspectRatio {
    case portrait   // 9:16
    case landscape  // 16:9
    case square     // 1:1
    
    var width: CGFloat {
        switch self {
        case .portrait: return 160
        case .landscape: return 280
        case .square: return 200
        }
    }
    
    var height: CGFloat {
        switch self {
        case .portrait: return 284
        case .landscape: return 158
        case .square: return 200
        }
    }
}

// MARK: - Snapshot Emoji Container

struct SnapshotEmojiContainer: View {
    let emoji: String
    let size: CGFloat
    
    var body: some View {
        Text(emoji)
            .font(.system(size: size * 0.7))
            .frame(width: size, height: size)
            .background(Color("accentDeemphasized"))
            .clipShape(Circle())
    }
}

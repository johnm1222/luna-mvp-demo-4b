import SwiftUI

struct MarketplaceTabView: View {
    var bottomPadding: CGFloat = 0
    @State private var selectedTabIndex = 1
    @State private var showSearch = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FDSNavigationBar(
                    title: "Marketplace",
                    icon1Name: "app-messenger-outline",
                    icon2Name: "profile-outline",
                    icon3Name: "magnifying-glass-outline",
                    icon3Action: { showSearch = true }
                )
                    
                    FDSSubNavigationBar(
                        items: [
                            SubNavigationItem("Sell"),
                            SubNavigationItem("For you"),
                            SubNavigationItem("Local"),
                            SubNavigationItem("More")
                        ],
                        selectedIndex: $selectedTabIndex
                    )
                    .padding(.top, 8)
                    .background(Color("surfaceBackground"))
                    
                    FDSUnitHeader(
                        headlineText: "Today's picks",
                        metaPosition: .bottom,
                        hierarchyLevel: .level3,
                        rightAddOn: .actionText(
                            label: "Palo Alto, CA",
                            icon: "pin-filled",
                            action: {}
                        )
                    )
                    .background(Color("surfaceBackground"))
                    
                    MediaTileGrid()
                        .padding(.vertical, 4)
                }
                .padding(.bottom, bottomPadding)
        }
        .background(Color("surfaceBackground"))
    }
}

struct MediaTileGrid: View {
    let products = [
        ProductData(image: "product1", price: "$100", description: "14k new gold hoops"),
        ProductData(image: "product2", price: "$20", description: "Gray cooler"),
        ProductData(image: "product3", price: "$15", description: "Begonia maculata"),
        ProductData(image: "product4", price: "$50", description: "Vintage arm chair"),
        ProductData(image: "product5", price: "$18", description: "Disco ball"),
        ProductData(image: "product6", price: "$20", description: "Decorative pillow"),
        ProductData(image: "product7", price: "$14", description: "Small brass mirror"),
        ProductData(image: "product8", price: "$10", description: "Set of 5 lb dumbbells")
    ]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 4),
            GridItem(.flexible(), spacing: 4)
        ], spacing: 16) {
            ForEach(products.indices, id: \.self) { index in
                MediaTile(
                    image: products[index].image,
                    price: products[index].price,
                    description: products[index].description,
                    meta: nil,
                    isLeftColumn: index % 2 == 0,
                    isInset: false
                )
            }
        }
        .background(Color("surfaceBackground"))
    }
}

struct MediaTile: View {
    let image: String
    let price: String
    let description: String
    let meta: String?
    let isLeftColumn: Bool
    let isInset: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(isInset ? 12 : 0)
                .overlay(
                    Rectangle()
                        .strokeBorder(Color("mediaInnerBorder"), lineWidth: 0.5)
                        .cornerRadius(isInset ? 12 : 0)
                )
            
            HStack(spacing: 4) {
                Text(price)
                    .headline4Typography()
                    .foregroundStyle(Color("primaryText"))
                Text("·")
                    .headline4Typography()
                    .foregroundStyle(Color("primaryText"))
                Text(description)
                    .headline4Typography()
                    .foregroundStyle(Color("primaryText"))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, isLeftColumn ? 12 : 0)
            .padding(.trailing, isLeftColumn ? 4 : (isInset ? 0 : 12))
            .padding(.top, 12)

            if let meta = meta {
                Text(meta)
                    .meta4Typography()
                    .foregroundStyle(Color("secondaryText"))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, isLeftColumn ? 12 : 0)
                    .padding(.trailing, isLeftColumn ? 4 : (isInset ? 0 : 12))
                    .padding(.top, 8)
            }
        }
        .background(Color("surfaceBackground"))
    }
}

struct ProductData {
    let image: String
    let price: String
    let description: String
}

#Preview {
    MarketplaceTabView()
}

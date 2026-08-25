//
//  OrderStripView.swift
//  Merge
//
//  활성 주문을 가로로 스크롤할 수 있는 목록으로 표시합니다.
//

import SwiftUI

struct OrderStripView: View {
    let orders: [GameOrder]
    let itemCounts: [BoardItemKind: Int]
    let onComplete: (GameOrder) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 10) {
                ForEach(orders) { order in
                    OrderCardView(
                        order: order,
                        itemCounts: itemCounts,
                        onComplete: {
                            onComplete(order)
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 5)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    OrderStripView(
        orders: [.flourDelivery, .flourDelivery, .flourDelivery],
        itemCounts: [.flour: 1],
        onComplete: { _ in }
    )
    .background(Color(red: 0.68, green: 0.86, blue: 0.98))
}

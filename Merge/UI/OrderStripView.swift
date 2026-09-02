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
    let completingOrderIDs: Set<UUID>
    let storyOrderTemplateID: String?
    let onComplete: (GameOrder, CGPoint) -> Void

    private var displayedOrders: [GameOrder] {
        GameOrder.prioritizedForDisplay(
            orders,
            itemCounts: itemCounts,
            completingOrderIDs: completingOrderIDs,
            storyOrderTemplateID: storyOrderTemplateID
        )
    }

    private var actionableOrderIDs: [UUID] {
        displayedOrders
            .filter {
                completingOrderIDs.contains($0.id)
                    || $0.isReady(in: itemCounts)
            }
            .map(\.id)
    }

    init(
        orders: [GameOrder],
        itemCounts: [BoardItemKind: Int],
        completingOrderIDs: Set<UUID> = [],
        storyOrderTemplateID: String? = nil,
        onComplete: @escaping (GameOrder, CGPoint) -> Void
    ) {
        precondition(
            orders.count <= GameOrder.maximumActiveCount,
            "활성 주문은 최대 \(GameOrder.maximumActiveCount)개까지 표시할 수 있습니다."
        )

        self.orders = orders
        self.itemCounts = itemCounts
        self.completingOrderIDs = completingOrderIDs
        self.storyOrderTemplateID = storyOrderTemplateID
        self.onComplete = onComplete
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(displayedOrders) { order in
                        OrderCardView(
                            order: order,
                            itemCounts: itemCounts,
                            isCompleting: completingOrderIDs.contains(order.id),
                            isStoryOrder: order.templateID == storyOrderTemplateID,
                            onComplete: { target in
                                onComplete(order, target)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 5)
            }
            .scrollIndicators(.hidden)
            .onChange(of: actionableOrderIDs) { _, newIDs in
                guard let firstActionableID = newIDs.first else {
                    return
                }

                // 사용자가 오른쪽 주문을 보고 있더라도 새로 완료 가능해진 카드를 실제 화면 왼쪽에 보여 줍니다.
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(firstActionableID, anchor: .leading)
                }
            }
        }
    }
}

#Preview {
    OrderStripView(
        orders: [.flourDelivery, .flourDelivery, .flourDelivery],
        itemCounts: [.flour: 1],
        onComplete: { _, _ in }
    )
    .background(Color(red: 0.68, green: 0.86, blue: 0.98))
}

import SwiftUI

struct ReactionSummaryView: View {
    let summaries: [ReactionSummary]
    let currentUserId: String
    let onTap: (String) -> Void

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(summaries, id: \.emoji) { summary in
                Button {
                    onTap(summary.emoji)
                } label: {
                    HStack(spacing: 4) {
                        Text(summary.emoji)
                        Text("\(summary.count)")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        summary.hasUser(currentUserId) ? Color.blue : Color.gray.opacity(0.2)
                    )
                    .foregroundColor(
                        summary.hasUser(currentUserId) ? .white : .primary
                    )
                    .clipShape(Capsule())
                }
            }
        }
    }
}

// Simple FlowLayout implementation for horizontal wrapping
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let position = result.positions[index]
            subview.place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        var sizes: [CGSize]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var sizes: [CGSize] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                sizes.append(size)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.positions = positions
            self.sizes = sizes
            self.size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}

#Preview {
    let summaries = [
        ReactionSummary(emoji: "👍", count: 3, userIds: ["user-1", "user-2", "user-3"]),
        ReactionSummary(emoji: "❤️", count: 1, userIds: ["user-4"]),
        ReactionSummary(emoji: "😂", count: 2, userIds: ["user-1", "user-5"])
    ]

    VStack(alignment: .leading, spacing: 16) {
        Text("User's own reactions (blue):")
        ReactionSummaryView(
            summaries: summaries,
            currentUserId: "user-1",
            onTap: { emoji in
                print("Tapped: \(emoji)")
            }
        )

        Text("Other users' reactions (gray):")
        ReactionSummaryView(
            summaries: summaries,
            currentUserId: "user-999",
            onTap: { emoji in
                print("Tapped: \(emoji)")
            }
        )
    }
    .padding()
}

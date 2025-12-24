import SwiftUI

struct ReactionSummaryView: View {
    let summaries: [ReactionSummary]
    let currentUserId: String
    let alignment: HorizontalAlignment
    let onTap: (String) -> Void

    var body: some View {
        FlowLayout(alignment: alignment, spacing: 8) {
            ForEach(summaries, id: \.emoji) { summary in
                Button {
                    onTap(summary.emoji)
                } label: {
                    HStack(spacing: 4) {
                        Text(summary.emoji)
                        Text("\(summary.count)")
                            .appText(.caption2, color: summary.hasUser(currentUserId) ? App.Color.Text.Default.inversion : App.Color.Text.Default.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        summary.hasUser(currentUserId) ? App.Color.Brand.primary : App.Color.Fill.Default.secondary
                    )
                    .clipShape(Capsule())
                }
            }
        }
    }
}

// Simple FlowLayout implementation for horizontal wrapping
struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            alignment: alignment,
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

        init(in maxWidth: CGFloat, subviews: Subviews, alignment: HorizontalAlignment, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var sizes: [CGSize] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            // Group subviews by line to calculate line widths for trailing alignment
            var lines: [[Int]] = []
            var currentLine: [Int] = []
            var lineWidths: [CGFloat] = []
            var currentLineWidth: CGFloat = 0

            // First pass: calculate sizes and group into lines
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                sizes.append(size)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // Store current line info and move to next line
                    lines.append(currentLine)
                    lineWidths.append(currentLineWidth - spacing) // Remove trailing spacing
                    currentLine = []
                    currentLineWidth = 0
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                currentLine.append(index)
                currentLineWidth += size.width + spacing
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            // Store last line
            if !currentLine.isEmpty {
                lines.append(currentLine)
                lineWidths.append(currentLineWidth - spacing)
            }

            // Second pass: calculate positions with alignment
            currentY = 0
            lineHeight = 0

            for (lineIndex, line) in lines.enumerated() {
                let lineWidth = lineWidths[lineIndex]
                let offsetX = alignment == .trailing ? maxWidth - lineWidth : 0

                currentX = offsetX

                for itemIndex in line {
                    let size = sizes[itemIndex]
                    positions.append(CGPoint(x: currentX, y: currentY))
                    currentX += size.width + spacing
                    lineHeight = max(lineHeight, size.height)
                }

                currentY += lineHeight + spacing
            }

            self.positions = positions
            self.sizes = sizes
            self.size = CGSize(
                width: maxWidth,
                height: max(0, currentY - spacing)
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
        Text("Left aligned:")
        ReactionSummaryView(
            summaries: summaries,
            currentUserId: "user-1",
            alignment: .leading,
            onTap: { emoji in
                print("Tapped: \(emoji)")
            }
        )

        Text("Right aligned:")
        ReactionSummaryView(
            summaries: summaries,
            currentUserId: "user-999",
            alignment: .trailing,
            onTap: { emoji in
                print("Tapped: \(emoji)")
            }
        )
    }
    .padding()
}

import SwiftUI

struct ReactionPickerView: View {
    let onSelect: (String) -> Void

    private let emojis = ["👍", "❤️", "😂", "😮", "🎉", "🔥"]

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 16
        ) {
            ForEach(emojis, id: \.self) { emoji in
                Button {
                    onSelect(emoji)
                } label: {
                    Text(emoji)
                        .font(.system(size: 40))
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ReactionPickerView { emoji in
        print("Selected: \(emoji)")
    }
}

import SwiftUI

/// Manager for displaying toast notifications
@MainActor
class ToastManager: ObservableObject {
    @Published var currentToast: ToastItem?

    struct ToastItem: Identifiable, Equatable {
        let id = UUID()
        let message: String
        let icon: String?
        let type: ToastView.ToastType
        let duration: TimeInterval

        init(message: String, icon: String? = nil, type: ToastView.ToastType = .success, duration: TimeInterval = 2.0) {
            self.message = message
            self.icon = icon
            self.type = type
            self.duration = duration
        }

        static func == (lhs: ToastItem, rhs: ToastItem) -> Bool {
            lhs.id == rhs.id
        }
    }

    /// Show a toast notification
    func show(message: String, icon: String? = nil, type: ToastView.ToastType = .success, duration: TimeInterval = 2.0) {
        let toast = ToastItem(message: message, icon: icon, type: type, duration: duration)
        currentToast = toast

        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            if currentToast?.id == toast.id {
                currentToast = nil
            }
        }
    }

    /// Show success toast
    func showSuccess(_ message: String, icon: String? = nil) {
        show(message: message, icon: icon, type: .success)
    }

    /// Show info toast
    func showInfo(_ message: String, icon: String? = nil) {
        show(message: message, icon: icon, type: .info)
    }

    /// Show warning toast
    func showWarning(_ message: String, icon: String? = nil) {
        show(message: message, icon: icon, type: .warning)
    }

    /// Dismiss current toast
    func dismiss() {
        currentToast = nil
    }
}

/// View modifier to add toast overlay
struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager

    func body(content: Content) -> some View {
        ZStack {
            content

            if let toast = toastManager.currentToast {
                VStack {
                    ToastView(message: toast.message, icon: toast.icon, type: toast.type)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(), value: toastManager.currentToast)
                        .onTapGesture {
                            toastManager.dismiss()
                        }

                    Spacer()
                }
                .padding(.top, 8)
            }
        }
    }
}

extension View {
    /// Add toast notification support to a view
    func toast(_ toastManager: ToastManager) -> some View {
        modifier(ToastModifier(toastManager: toastManager))
    }
}

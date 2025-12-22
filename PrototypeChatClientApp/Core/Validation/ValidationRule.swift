import Foundation

/// バリデーションルールのプロトコル
protocol ValidationRule {
    /// バリデーションを実行
    /// - Parameter value: 検証する値
    /// - Returns: 検証結果（成功時はnil、失敗時はエラーメッセージ）
    func validate(_ value: String) -> String?
}

/// バリデーション結果
enum ValidationResult {
    case valid
    case invalid(String)

    var isValid: Bool {
        if case .valid = self {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case .invalid(let message) = self {
            return message
        }
        return nil
    }
}

/// 複数のルールを組み合わせるバリデーター
struct CompositeValidator {
    private let rules: [ValidationRule]

    init(rules: [ValidationRule]) {
        self.rules = rules
    }

    func validate(_ value: String) -> ValidationResult {
        for rule in rules {
            if let errorMessage = rule.validate(value) {
                return .invalid(errorMessage)
            }
        }
        return .valid
    }
}

import Foundation

// MARK: - Common Validation Rules

/// 空文字チェック
struct NotEmptyRule: ValidationRule {
    let errorMessage: String

    init(errorMessage: String = "入力が必要です") {
        self.errorMessage = errorMessage
    }

    func validate(_ value: String) -> String? {
        return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? errorMessage : nil
    }
}

/// 最小文字数チェック
struct MinLengthRule: ValidationRule {
    let minLength: Int
    let errorMessage: String?

    init(minLength: Int, errorMessage: String? = nil) {
        self.minLength = minLength
        self.errorMessage = errorMessage
    }

    func validate(_ value: String) -> String? {
        if value.count < minLength {
            return errorMessage ?? "\(minLength)文字以上入力してください"
        }
        return nil
    }
}

/// 最大文字数チェック
struct MaxLengthRule: ValidationRule {
    let maxLength: Int
    let errorMessage: String?

    init(maxLength: Int, errorMessage: String? = nil) {
        self.maxLength = maxLength
        self.errorMessage = errorMessage
    }

    func validate(_ value: String) -> String? {
        if value.count > maxLength {
            return errorMessage ?? "\(maxLength)文字以内で入力してください"
        }
        return nil
    }
}

/// 正規表現マッチング
struct RegexRule: ValidationRule {
    let pattern: String
    let errorMessage: String

    init(pattern: String, errorMessage: String) {
        self.pattern = pattern
        self.errorMessage = errorMessage
    }

    func validate(_ value: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: value.utf16.count)
        let matches = regex?.firstMatch(in: value, range: range)
        return matches != nil ? nil : errorMessage
    }
}

/// メールアドレスチェック
struct EmailRule: ValidationRule {
    let errorMessage: String

    init(errorMessage: String = "有効なメールアドレスを入力してください") {
        self.errorMessage = errorMessage
    }

    func validate(_ value: String) -> String? {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: value.utf16.count)
        let matches = regex?.firstMatch(in: value, range: range)
        return matches != nil ? nil : errorMessage
    }
}

/// パスワードチェック（英数字を含む8文字以上）
struct PasswordRule: ValidationRule {
    let errorMessage: String

    init(errorMessage: String = "パスワードは英数字を含む8文字以上である必要があります") {
        self.errorMessage = errorMessage
    }

    func validate(_ value: String) -> String? {
        // 8文字以上
        guard value.count >= 8 else {
            return errorMessage
        }

        // 英字を含む
        let hasLetter = value.range(of: "[A-Za-z]", options: .regularExpression) != nil

        // 数字を含む
        let hasNumber = value.range(of: "[0-9]", options: .regularExpression) != nil

        return (hasLetter && hasNumber) ? nil : errorMessage
    }
}

// MARK: - Convenience Factory

struct Validators {
    static func notEmpty(_ message: String = "入力が必要です") -> ValidationRule {
        NotEmptyRule(errorMessage: message)
    }

    static func minLength(_ length: Int, message: String? = nil) -> ValidationRule {
        MinLengthRule(minLength: length, errorMessage: message)
    }

    static func maxLength(_ length: Int, message: String? = nil) -> ValidationRule {
        MaxLengthRule(maxLength: length, errorMessage: message)
    }

    static func email(_ message: String = "有効なメールアドレスを入力してください") -> ValidationRule {
        EmailRule(errorMessage: message)
    }

    static func password(_ message: String = "パスワードは英数字を含む8文字以上である必要があります") -> ValidationRule {
        PasswordRule(errorMessage: message)
    }

    static func regex(_ pattern: String, message: String) -> ValidationRule {
        RegexRule(pattern: pattern, errorMessage: message)
    }

    /// ユーザー名バリデーション（1文字以上50文字以下）
    static func username() -> CompositeValidator {
        CompositeValidator(rules: [
            notEmpty("ユーザー名を入力してください"),
            maxLength(50, message: "ユーザー名は50文字以内で入力してください")
        ])
    }

    /// グループ名バリデーション（1文字以上100文字以下）
    static func groupName() -> CompositeValidator {
        CompositeValidator(rules: [
            notEmpty("グループ名を入力してください"),
            maxLength(100, message: "グループ名は100文字以内で入力してください")
        ])
    }

    /// メッセージバリデーション（1文字以上1000文字以下）
    static func message() -> CompositeValidator {
        CompositeValidator(rules: [
            notEmpty("メッセージを入力してください"),
            maxLength(1000, message: "メッセージは1000文字以内で入力してください")
        ])
    }
}

//
//  AppColorPrimitives.swift
//  PrototypeChatClientApp
//
//  Design System Color Primitives
//  UIColor extensions for hex-based color definitions
//

import UIKit

extension UIColor {
    /// Create UIColor from hex value
    ///
    /// - Parameters:
    ///   - hex: Hex color value (e.g., 0xFF0000 for red)
    ///   - alpha: Alpha/opacity value (0.0 to 1.0)
    /// - Returns: UIColor instance
    ///
    /// Example:
    /// ```swift
    /// let red = UIColor.hex(0xFF0000)
    /// let semiTransparentBlue = UIColor.hex(0x0000FF, alpha: 0.5)
    /// ```
    public static func hex(_ hex: UInt, alpha: CGFloat = 1) -> UIColor {
        UIColor(
            red: CGFloat((hex & 0xff0000) >> 16) / 255,
            green: CGFloat((hex & 0x00ff00) >> 8) / 255,
            blue: CGFloat(hex & 0x0000ff) / 255,
            alpha: alpha
        )
    }
}

// MARK: - Black Scale

extension UIColor {
    public static let black100 = black1000.withAlphaComponent(0.05)
    public static let black200 = black1000.withAlphaComponent(0.1)
    public static let black300 = black1000.withAlphaComponent(0.2)
    public static let black400 = black1000.withAlphaComponent(0.4)
    public static let black500 = black1000.withAlphaComponent(0.7)
    public static let black600 = black1000.withAlphaComponent(0.8)
    public static let black700 = black1000.withAlphaComponent(0.85)
    public static let black800 = black1000.withAlphaComponent(0.9)
    public static let black900 = black1000.withAlphaComponent(0.95)
    public static let black1000 = hex(0x161213)
}

// MARK: - Gray Scale

extension UIColor {
    public static let gray100 = hex(0xefefef)
    public static let gray200 = hex(0xdcdcdc)
    public static let gray300 = hex(0xbdbdbd)
    public static let gray400 = hex(0x989898)
    public static let gray50010 = gray500100.withAlphaComponent(0.1)
    public static let gray50030 = gray500100.withAlphaComponent(0.3)
    public static let gray50050 = gray500100.withAlphaComponent(0.5)
    public static let gray500100 = hex(0x7c7c7c)
    public static let gray600 = hex(0x656565)
    public static let gray700 = hex(0x525252)
    public static let gray800 = hex(0x464646)
    public static let gray900 = hex(0x3d3d3d)
    public static let gray1000 = hex(0x292929)
}

// MARK: - White Scale

extension UIColor {
    public static let white100 = white1000.withAlphaComponent(0.05)
    public static let white200 = white1000.withAlphaComponent(0.1)
    public static let white300 = white1000.withAlphaComponent(0.2)
    public static let white400 = white1000.withAlphaComponent(0.4)
    public static let white500 = white1000.withAlphaComponent(0.7)
    public static let white600 = white1000.withAlphaComponent(0.8)
    public static let white700 = white1000.withAlphaComponent(0.85)
    public static let white800 = white1000.withAlphaComponent(0.9)
    public static let white900 = white1000.withAlphaComponent(0.95)
    public static let white1000 = hex(0xffffff)
}

// MARK: - System Colors (Semantic)

extension UIColor {
    // Red
    public static let systemRed100 = hex(0xff3d00)
    public static let systemRed80 = systemRed100.withAlphaComponent(0.8)
    public static let systemRed70 = systemRed100.withAlphaComponent(0.7)
    public static let systemRed50 = systemRed100.withAlphaComponent(0.5)
    public static let systemRed30 = systemRed100.withAlphaComponent(0.3)
    public static let systemRed10 = systemRed100.withAlphaComponent(0.1)

    // Orange
    public static let systemOrange100 = hex(0xffbb0c)
    public static let systemOrange80 = systemOrange100.withAlphaComponent(0.8)
    public static let systemOrange70 = systemOrange100.withAlphaComponent(0.7)
    public static let systemOrange50 = systemOrange100.withAlphaComponent(0.5)
    public static let systemOrange30 = systemOrange100.withAlphaComponent(0.3)
    public static let systemOrange10 = systemOrange100.withAlphaComponent(0.1)

    // Yellow
    public static let systemYellow100 = hex(0xfff735)
    public static let systemYellow80 = systemYellow100.withAlphaComponent(0.8)
    public static let systemYellow70 = systemYellow100.withAlphaComponent(0.7)
    public static let systemYellow50 = systemYellow100.withAlphaComponent(0.5)
    public static let systemYellow30 = systemYellow100.withAlphaComponent(0.3)
    public static let systemYellow10 = systemYellow100.withAlphaComponent(0.1)

    // Green (Light variant)
    public static let systemGreen100Light = hex(0x4bc400)
    public static let systemGreen80Light = systemGreen100Light.withAlphaComponent(0.8)
    public static let systemGreen70Light = systemGreen100Light.withAlphaComponent(0.7)
    public static let systemGreen50Light = systemGreen100Light.withAlphaComponent(0.5)
    public static let systemGreen30Light = systemGreen100Light.withAlphaComponent(0.3)
    public static let systemGreen10Light = systemGreen100Light.withAlphaComponent(0.1)

    // Green (Dark variant)
    public static let systemGreen100 = hex(0x56e100)
    public static let systemGreen80 = systemGreen100.withAlphaComponent(0.8)
    public static let systemGreen70 = systemGreen100.withAlphaComponent(0.7)
    public static let systemGreen50 = systemGreen100.withAlphaComponent(0.5)
    public static let systemGreen30 = systemGreen100.withAlphaComponent(0.3)
    public static let systemGreen10 = systemGreen100.withAlphaComponent(0.1)

    // Light Blue
    public static let systemLightBlue100 = hex(0x42e1f0)
    public static let systemLightBlue80 = systemLightBlue100.withAlphaComponent(0.8)
    public static let systemLightBlue70 = systemLightBlue100.withAlphaComponent(0.7)
    public static let systemLightBlue50 = systemLightBlue100.withAlphaComponent(0.5)
    public static let systemLightBlue30 = systemLightBlue100.withAlphaComponent(0.3)
    public static let systemLightBlue10 = systemLightBlue100.withAlphaComponent(0.1)

    // Dark Blue
    public static let systemDarkBlue100 = hex(0x0056fe)
    public static let systemDarkBlue80 = systemDarkBlue100.withAlphaComponent(0.8)
    public static let systemDarkBlue70 = systemDarkBlue100.withAlphaComponent(0.7)
    public static let systemDarkBlue50 = systemDarkBlue100.withAlphaComponent(0.5)
    public static let systemDarkBlue30 = systemDarkBlue100.withAlphaComponent(0.3)
    public static let systemDarkBlue10 = systemDarkBlue100.withAlphaComponent(0.1)

    // Purple
    public static let systemPurple100 = hex(0x8256ff)
    public static let systemPurple80 = systemPurple100.withAlphaComponent(0.8)
    public static let systemPurple70 = systemPurple100.withAlphaComponent(0.7)
    public static let systemPurple50 = systemPurple100.withAlphaComponent(0.5)
    public static let systemPurple30 = systemPurple100.withAlphaComponent(0.3)
    public static let systemPurple10 = systemPurple100.withAlphaComponent(0.1)

    // Magenta
    public static let systemMagenta100 = hex(0xd220ff)
    public static let systemMagenta80 = systemMagenta100.withAlphaComponent(0.8)
    public static let systemMagenta70 = systemMagenta100.withAlphaComponent(0.7)
    public static let systemMagenta50 = systemMagenta100.withAlphaComponent(0.5)
    public static let systemMagenta30 = systemMagenta100.withAlphaComponent(0.3)
    public static let systemMagenta10 = systemMagenta100.withAlphaComponent(0.1)

    // Pink
    public static let systemPink100 = hex(0xfc36b9)
    public static let systemPink80 = systemPink100.withAlphaComponent(0.8)
    public static let systemPink70 = systemPink100.withAlphaComponent(0.7)
    public static let systemPink50 = systemPink100.withAlphaComponent(0.5)
    public static let systemPink30 = systemPink100.withAlphaComponent(0.3)
    public static let systemPink10 = systemPink100.withAlphaComponent(0.1)
}

// MARK: - Brand/Special Colors

extension UIColor {
    /// Diamond/Premium color
    public static let dia = hex(0xd220ff)

    /// Coin/Currency color
    public static let coin = hex(0xffbb0c)
}

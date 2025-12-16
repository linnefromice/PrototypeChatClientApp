# Spec: Logout Navigation Menu

**Capability:** `logout-menu`
**Type:** Feature
**Status:** Active

## Overview

This spec defines how users can access logout functionality through a navigation menu in the conversation list screen. The menu is accessed via a button in the top-left corner of the navigation bar and provides a safe logout flow with confirmation.

## ADDED Requirements

### Requirement: MENU-001 - Menu Button Accessibility

The conversation list MUST provide a menu button in the top-left corner of the navigation bar to access app-level actions.

**Rationale:** Users need a discoverable way to access logout and other app-level functions. The top-left position follows iOS conventions for menu/settings access.

#### Scenario: Menu button is visible and accessible

**Given** the user is viewing the conversation list screen
**And** the user is authenticated
**When** the screen finishes loading
**Then** a menu button (three horizontal lines icon) is visible in the top-left corner
**And** the button uses the SF Symbol "line.3.horizontal"
**And** the button is at the same visual weight as the "+" button on the right

---

#### Scenario: User taps menu button

**Given** the user is viewing the conversation list screen
**When** the user taps the menu button in the top-left corner
**Then** the navigation menu opens as a modal sheet
**And** the conversation list remains visible in the background (dimmed)
**And** the sheet can be dismissed by swiping down

---

### Requirement: MENU-002 - Navigation Menu Display

The navigation menu MUST display available actions in a clear, organized list format.

**Rationale:** A list-based menu is the iOS-standard pattern for presenting multiple action options. This provides familiarity and accommodates future expansion.

#### Scenario: Navigation menu displays correctly

**Given** the user has tapped the menu button
**When** the navigation menu sheet appears
**Then** the sheet displays a navigation bar with title "メニュー"
**And** the navigation bar has a "閉じる" button in the trailing position
**And** the menu body contains a List view
**And** the List includes a "ログアウト" option with a logout icon
**And** the logout option is styled with `.destructive` role (red color)

---

#### Scenario: User closes menu without action

**Given** the navigation menu is open
**When** the user taps "閉じる" button
**Then** the menu sheet closes with animation
**And** the user remains on the conversation list
**And** the user remains logged in

---

#### Scenario: User swipes down to dismiss menu

**Given** the navigation menu is open
**When** the user swipes down on the sheet
**Then** the menu sheet closes with animation
**And** the user remains on the conversation list
**And** the user remains logged in

---

### Requirement: MENU-003 - Logout Confirmation Flow

The system MUST require explicit confirmation before executing logout to prevent accidental data loss.

**Rationale:** Logout is a destructive action that clears the user's session. Accidental logout would disrupt the user's workflow and require re-authentication.

#### Scenario: User initiates logout

**Given** the navigation menu is open
**When** the user taps the "ログアウト" option
**Then** the menu sheet closes
**And** a confirmation alert appears
**And** the alert title is "ログアウト"
**And** the alert message is "ログアウトしますか？"
**And** the alert has two buttons: "キャンセル" and "ログアウト"
**And** the "ログアウト" button is styled as destructive (red)

---

#### Scenario: User cancels logout

**Given** the logout confirmation alert is displayed
**When** the user taps "キャンセル"
**Then** the alert dismisses with animation
**And** the user remains on the conversation list
**And** the user remains logged in
**And** the session is not cleared

---

#### Scenario: User confirms logout

**Given** the logout confirmation alert is displayed
**When** the user taps "ログアウト"
**Then** the alert dismisses
**And** the `AuthenticationViewModel.logout()` method is called
**And** the user session is cleared
**And** the `isAuthenticated` state is set to `false`
**And** the app navigates to the login screen
**And** the user can log in as a different user

---

### Requirement: MENU-004 - State Management

The menu and confirmation dialog states MUST be properly managed to prevent UI conflicts and ensure smooth user experience.

**Rationale:** Proper state management prevents issues like multiple sheets appearing simultaneously, ghost sheets, or state inconsistencies.

#### Scenario: Only one sheet displays at a time

**Given** the user is on the conversation list
**When** the menu is open
**Then** the create conversation sheet cannot be opened
**And** tapping the "+" button has no effect until menu is closed

---

#### Scenario: State resets after logout

**Given** the user has logged out
**And** the app has returned to login screen
**When** the user logs in again
**Then** all menu-related state variables are reset
**And** no sheets or alerts are visible
**And** the conversation list loads fresh data

---

#### Scenario: Rapid tapping does not cause issues

**Given** the user is on the conversation list
**When** the user rapidly taps the menu button multiple times
**Then** only one menu sheet appears
**And** no duplicate sheets are created
**And** the app remains responsive

---

### Requirement: MENU-005 - Integration with Authentication System

The logout menu MUST correctly integrate with the existing authentication system without breaking existing functionality.

**Rationale:** The logout feature depends on the authentication system working correctly. It should not interfere with login, session persistence, or other auth flows.

#### Scenario: Logout clears session data

**Given** the user is logged in as "user-1"
**And** the user has an active session
**When** the user confirms logout
**Then** the `AuthSessionManager.clearSession()` is called
**And** the session is removed from UserDefaults
**And** the `currentSession` property is set to `nil`
**And** the `userId` property is cleared

---

#### Scenario: User can log in as different user after logout

**Given** the user was logged in as "user-1"
**And** the user has logged out successfully
**When** the login screen appears
**And** the user enters "user-2" as the user ID
**And** the user taps login
**Then** the app authenticates as "user-2"
**And** the conversation list shows "user-2"'s conversations
**And** no data from "user-1" is visible

---

#### Scenario: Existing authentication flows remain unchanged

**Given** the logout menu feature is implemented
**When** a new user opens the app for the first time
**Then** the login screen appears normally
**And** authentication works as before
**And** session persistence works as before
**And** auto-login on app restart works as before

---

### Requirement: MENU-006 - Visual Design Consistency

The menu UI MUST follow the app's existing design patterns and iOS Human Interface Guidelines.

**Rationale:** Consistent design provides a cohesive user experience and makes the app feel polished and professional.

#### Scenario: Menu button follows navigation bar styling

**Given** the user is viewing the conversation list
**Then** the menu button icon is the same size as the "+" button
**And** the menu button has the same color as the "+" button
**And** the menu button has the same touch target size
**And** the button responds to taps with standard iOS animation

---

#### Scenario: Menu sheet follows iOS presentation style

**Given** the navigation menu is open
**Then** the sheet uses standard iOS sheet presentation
**And** the sheet has a drag indicator at the top (if iOS 15+)
**And** the sheet background has the standard system blur effect
**And** the sheet corners are rounded
**And** the sheet can be dismissed with the standard swipe-down gesture

---

#### Scenario: Confirmation alert follows iOS styling

**Given** the logout confirmation alert is displayed
**Then** the alert uses iOS standard alert styling
**And** the alert is centered on screen
**And** the alert has semi-transparent background overlay
**And** the "ログアウト" button is styled in red (destructive)
**And** the "キャンセル" button is styled in default blue

---

## Related Specs

- Integrates with: Authentication system (existing)
- Depends on: `AuthenticationViewModel.logout()` (existing)
- Future: Profile settings, app preferences (not yet implemented)

## Implementation Notes

- Uses SwiftUI `.sheet(isPresented:)` for menu presentation
- Uses SwiftUI `.alert` for confirmation dialog
- Leverages `@EnvironmentObject` for `AuthenticationViewModel` access
- Menu button uses SF Symbol `line.3.horizontal`
- Logout icon uses SF Symbol `rectangle.portrait.and.arrow.right`
- State management via `@State` properties in `ConversationListView`

## Testing Strategy

- **Unit Tests:** `AuthenticationViewModel.logout()` behavior (already covered by existing tests)
- **Manual Tests:** Full logout flow in simulator with multiple users
- **Edge Cases:** Rapid tapping, state conflicts, session clearing
- **Regression Tests:** Verify existing auth flows still work correctly

## Accessibility Considerations

- Menu button MUST have accessible label: "メニュー"
- Logout option MUST have accessible label: "ログアウト"
- Confirmation alert MUST be readable by VoiceOver
- All interactive elements MUST have sufficient touch target size (44x44 points)

# ===================================================
# Makefile for PrototypeChatClientApp
# iOS Development Shortcuts
# ===================================================

# Project Configuration
PROJECT_NAME = PrototypeChatClientApp
SCHEME = PrototypeChatClientApp
WORKSPACE = PrototypeChatClientApp.xcodeproj

# Simulator Configuration
DEVICE ?= iPhone 16
OS_VERSION = iOS 17.2

# Build Configuration
CONFIGURATION ?= Debug
DERIVED_DATA = ./DerivedData
BUILD_DIR = ./build

# Bundle Identifier
BUNDLE_ID = com.linnefromice.PrototypeChatClientApp

# Colors for output
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[36m
COLOR_SUCCESS = \033[32m
COLOR_WARNING = \033[33m
COLOR_ERROR   = \033[31m

# Check if xcpretty is installed
XCPRETTY := $(shell command -v xcpretty 2> /dev/null)

# Get Simulator ID
SIMULATOR_ID = $(shell xcrun simctl list devices available | \
	grep "$(DEVICE)" | \
	grep -E -o -i "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" | \
	head -n 1)

# Default target
.DEFAULT_GOAL := help

# Phony targets
.PHONY: help open build run test clean devices boot shutdown reset logs resolve format lint ci

# ===================================================
# Help
# ===================================================

help: ## Show this help message
	@echo "$(COLOR_INFO)PrototypeChatClientApp - Available Commands$(COLOR_RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(COLOR_SUCCESS)%-15s$(COLOR_RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(COLOR_WARNING)Environment Variables:$(COLOR_RESET)"
	@echo "  DEVICE=$(DEVICE)"
	@echo "  CONFIGURATION=$(CONFIGURATION)"
	@echo ""

# ===================================================
# Basic Commands
# ===================================================

open: ## Open project in Xcode
	@echo "$(COLOR_INFO)Opening $(PROJECT_NAME) in Xcode...$(COLOR_RESET)"
	@xed $(WORKSPACE)

build: ## Build the project
	@echo "$(COLOR_INFO)Building $(PROJECT_NAME)...$(COLOR_RESET)"
ifdef XCPRETTY
	@xcodebuild build \
		-project $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(DEVICE)" \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(DERIVED_DATA) \
		| xcpretty
else
	@xcodebuild build \
		-project $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(DEVICE)" \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(DERIVED_DATA)
endif
	@echo "$(COLOR_SUCCESS)✓ Build completed!$(COLOR_RESET)"

run: build boot install launch ## Build and run app on simulator
	@echo "$(COLOR_SUCCESS)✓ App is running on $(DEVICE)$(COLOR_RESET)"

clean: ## Clean build artifacts
	@echo "$(COLOR_INFO)Cleaning build artifacts...$(COLOR_RESET)"
	@xcodebuild clean \
		-project $(WORKSPACE) \
		-scheme $(SCHEME) \
		> /dev/null 2>&1
	@rm -rf $(DERIVED_DATA)
	@rm -rf $(BUILD_DIR)
	@echo "$(COLOR_SUCCESS)✓ Clean completed!$(COLOR_RESET)"

# ===================================================
# Testing
# ===================================================

test: ## Run unit tests
	@echo "$(COLOR_INFO)Running tests...$(COLOR_RESET)"
ifdef XCPRETTY
	@xcodebuild test \
		-project $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(DEVICE)" \
		-configuration $(CONFIGURATION) \
		| xcpretty --test
else
	@xcodebuild test \
		-project $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(DEVICE)" \
		-configuration $(CONFIGURATION)
endif
	@echo "$(COLOR_SUCCESS)✓ Tests completed!$(COLOR_RESET)"

# ===================================================
# Simulator Management
# ===================================================

devices: ## List available simulators
	@echo "$(COLOR_INFO)Available simulators:$(COLOR_RESET)"
	@xcrun simctl list devices available | grep -E "(iPhone|iPad)"

boot: ## Boot simulator
	@echo "$(COLOR_INFO)Booting simulator: $(DEVICE)...$(COLOR_RESET)"
	@if [ -z "$(SIMULATOR_ID)" ]; then \
		echo "$(COLOR_ERROR)✗ Simulator not found: $(DEVICE)$(COLOR_RESET)"; \
		echo "$(COLOR_WARNING)Run 'make devices' to see available simulators$(COLOR_RESET)"; \
		exit 1; \
	fi
	@xcrun simctl boot $(SIMULATOR_ID) 2>/dev/null || true
	@open -a Simulator
	@sleep 2
	@echo "$(COLOR_SUCCESS)✓ Simulator booted!$(COLOR_RESET)"

shutdown: ## Shutdown simulator
	@echo "$(COLOR_INFO)Shutting down simulator...$(COLOR_RESET)"
	@xcrun simctl shutdown $(SIMULATOR_ID) 2>/dev/null || true
	@echo "$(COLOR_SUCCESS)✓ Simulator shut down!$(COLOR_RESET)"

reset: ## Reset simulator to factory settings
	@echo "$(COLOR_WARNING)⚠ Resetting simulator: $(DEVICE)...$(COLOR_RESET)"
	@xcrun simctl shutdown $(SIMULATOR_ID) 2>/dev/null || true
	@xcrun simctl erase $(SIMULATOR_ID)
	@echo "$(COLOR_SUCCESS)✓ Simulator reset!$(COLOR_RESET)"

install: ## Install app to simulator (requires build)
	@echo "$(COLOR_INFO)Installing app to simulator...$(COLOR_RESET)"
	@APP_PATH=$$(find $(DERIVED_DATA) -name "$(PROJECT_NAME).app" | head -n 1); \
	if [ -z "$$APP_PATH" ]; then \
		echo "$(COLOR_ERROR)✗ App not found. Run 'make build' first.$(COLOR_RESET)"; \
		exit 1; \
	fi; \
	xcrun simctl install $(SIMULATOR_ID) "$$APP_PATH"
	@echo "$(COLOR_SUCCESS)✓ App installed!$(COLOR_RESET)"

launch: ## Launch app on simulator
	@echo "$(COLOR_INFO)Launching app...$(COLOR_RESET)"
	@xcrun simctl launch $(SIMULATOR_ID) $(BUNDLE_ID)
	@echo "$(COLOR_SUCCESS)✓ App launched!$(COLOR_RESET)"

logs: ## Show app logs in real-time
	@echo "$(COLOR_INFO)Showing logs for $(PROJECT_NAME)...$(COLOR_RESET)"
	@echo "$(COLOR_WARNING)Press Ctrl+C to stop$(COLOR_RESET)"
	@xcrun simctl spawn $(SIMULATOR_ID) log stream --predicate 'processImagePath contains "$(PROJECT_NAME)"' --color always

# ===================================================
# OpenAPI Management
# ===================================================

OPENAPI_URL = https://linnefromice.github.io/prototype-chat-w-hono-drizzle-by-agent/openapi.yaml
OPENAPI_PATH = PrototypeChatClientApp/openapi.yaml
OPENAPI_BACKUP_PATH = Resources/openapi.yaml

fetch-openapi: ## Fetch OpenAPI spec from backend
	@echo "$(COLOR_INFO)Fetching OpenAPI spec...$(COLOR_RESET)"
	@mkdir -p Resources
	@curl -fsSL $(OPENAPI_URL) -o $(OPENAPI_PATH)
	@cp $(OPENAPI_PATH) $(OPENAPI_BACKUP_PATH)
	@echo "$(COLOR_SUCCESS)✓ OpenAPI spec saved to $(OPENAPI_PATH)$(COLOR_RESET)"
	@echo "$(COLOR_INFO)Backup saved to $(OPENAPI_BACKUP_PATH)$(COLOR_RESET)"

generate-api: fetch-openapi ## Fetch OpenAPI spec and generate Swift client code
	@echo "$(COLOR_INFO)Generating Swift API client code...$(COLOR_RESET)"
	@echo "$(COLOR_WARNING)Code generation will occur during Xcode build$(COLOR_RESET)"
	@echo "$(COLOR_INFO)Run 'make build' to trigger code generation$(COLOR_RESET)"

# ===================================================
# Package Management
# ===================================================

resolve: ## Resolve Swift Package dependencies
	@echo "$(COLOR_INFO)Resolving Swift Package dependencies...$(COLOR_RESET)"
	@xcodebuild -resolvePackageDependencies \
		-project $(WORKSPACE) \
		-scheme $(SCHEME)
	@echo "$(COLOR_SUCCESS)✓ Dependencies resolved!$(COLOR_RESET)"

update: ## Update Swift Package dependencies
	@echo "$(COLOR_INFO)Updating Swift Package dependencies...$(COLOR_RESET)"
	@rm -rf $(WORKSPACE)/project.xcworkspace/xcshareddata/swiftpm
	@xcodebuild -resolvePackageDependencies \
		-project $(WORKSPACE) \
		-scheme $(SCHEME)
	@echo "$(COLOR_SUCCESS)✓ Dependencies updated!$(COLOR_RESET)"

reset-packages: ## Reset Swift Package cache
	@echo "$(COLOR_INFO)Resetting Swift Package cache...$(COLOR_RESET)"
	@rm -rf ~/Library/Caches/org.swift.swiftpm
	@rm -rf ~/Library/Developer/Xcode/DerivedData/*
	@rm -rf $(WORKSPACE)/project.xcworkspace/xcshareddata/swiftpm
	@echo "$(COLOR_SUCCESS)✓ Package cache reset!$(COLOR_RESET)"

# ===================================================
# Code Quality
# ===================================================

format: ## Format Swift code with SwiftFormat
	@if command -v swiftformat > /dev/null; then \
		echo "$(COLOR_INFO)Formatting Swift code...$(COLOR_RESET)"; \
		swiftformat .; \
		echo "$(COLOR_SUCCESS)✓ Formatting completed!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_WARNING)⚠ SwiftFormat not installed$(COLOR_RESET)"; \
		echo "$(COLOR_INFO)Install: brew install swiftformat$(COLOR_RESET)"; \
	fi

lint: ## Run SwiftLint
	@if command -v swiftlint > /dev/null; then \
		echo "$(COLOR_INFO)Running SwiftLint...$(COLOR_RESET)"; \
		swiftlint lint; \
		echo "$(COLOR_SUCCESS)✓ Lint completed!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_WARNING)⚠ SwiftLint not installed$(COLOR_RESET)"; \
		echo "$(COLOR_INFO)Install: brew install swiftlint$(COLOR_RESET)"; \
	fi

# ===================================================
# CI/CD
# ===================================================

ci: clean build test ## Run CI pipeline (clean, build, test)
	@echo "$(COLOR_SUCCESS)✓ CI pipeline completed!$(COLOR_RESET)"

# ===================================================
# Utility
# ===================================================

info: ## Show project information
	@echo "$(COLOR_INFO)Project Information:$(COLOR_RESET)"
	@echo "  Project: $(PROJECT_NAME)"
	@echo "  Scheme: $(SCHEME)"
	@echo "  Device: $(DEVICE)"
	@echo "  Configuration: $(CONFIGURATION)"
	@echo "  Bundle ID: $(BUNDLE_ID)"
	@echo ""
	@echo "$(COLOR_INFO)Simulator:$(COLOR_RESET)"
	@if [ -n "$(SIMULATOR_ID)" ]; then \
		echo "  ID: $(SIMULATOR_ID)"; \
		echo "  Status: $$(xcrun simctl list devices | grep $(SIMULATOR_ID) | grep -o 'Booted' || echo 'Shutdown')"; \
	else \
		echo "  $(COLOR_WARNING)Simulator not found$(COLOR_RESET)"; \
	fi

screenshot: ## Take screenshot from simulator
	@echo "$(COLOR_INFO)Taking screenshot...$(COLOR_RESET)"
	@mkdir -p screenshots
	@FILENAME="screenshots/screenshot_$$(date +%Y%m%d_%H%M%S).png"; \
	xcrun simctl io $(SIMULATOR_ID) screenshot "$$FILENAME"; \
	echo "$(COLOR_SUCCESS)✓ Screenshot saved: $$FILENAME$(COLOR_RESET)"; \
	open "$$FILENAME"

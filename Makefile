# Makefile

# Default target
all: generate

# Generate target
generate:
	@echo "Running Dart build_runner..."
	dart run build_runner build --delete-conflicting-outputs

intl:
	@echo "Running Dart intl..."
	flutter gen-l10n

core-release-gate:
	@test -n "$(ANDROID_DEVICE)" || (echo "ANDROID_DEVICE is required" && exit 64)
	@test -n "$(IOS_DEVICE)" || (echo "IOS_DEVICE is required" && exit 64)
	dart run scripts/core_release_gate.dart \
		--android-device "$(ANDROID_DEVICE)" \
		--ios-device "$(IOS_DEVICE)"

# Phony targets
.PHONY: all generate intl core-release-gate

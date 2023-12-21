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

# Phony targets
.PHONY: all generate

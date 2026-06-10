#!/usr/bin/env bash
set -euo pipefail

APP_NAME="ClipNote"
BUNDLE_ID="com.clipnote.app"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
CONFIGURATION="${CONFIGURATION:-debug}"
BUILD_DIR="$ROOT_DIR/.build/$CONFIGURATION"
APP_DIR="$ROOT_DIR/dist/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

export DEVELOPER_DIR

if [[ ! -d "$DEVELOPER_DIR" ]]; then
  echo "未找到 Xcode: $DEVELOPER_DIR"
  echo "请安装 Xcode，或用 DEVELOPER_DIR=/path/to/Xcode.app/Contents/Developer 指定。"
  exit 1
fi

pkill -x "$APP_NAME" 2>/dev/null || true

cd "$ROOT_DIR"
swift build -c "$CONFIGURATION"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"
cp "$ROOT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"

/usr/bin/codesign --force --sign - --entitlements "$ROOT_DIR/ClipNote.entitlements" "$APP_DIR"

case "${1:-}" in
  --verify)
    /usr/bin/open -n "$APP_DIR"
    sleep 1
    pgrep -x "$APP_NAME" >/dev/null
    echo "$APP_NAME 已启动: $APP_DIR"
    ;;
  --no-run)
    echo "已构建: $APP_DIR"
    ;;
  *)
    /usr/bin/open -n "$APP_DIR"
    echo "已启动: $APP_DIR"
    ;;
esac

# ClockApp

A tiny, self-contained macOS analog clock written in pure Objective-C.

- One file, no Xcode project needed—build with a single clang command.

- Scales gracefully with window size; all proportions (ticks, hands, numbers) are calculated from the current radius.

- Keeps perfect time via NSTimer, uses Cocoa’s native drawing APIs, and includes a minimal “Quit” menu.

Perfect as a teaching sample for Cocoa custom-view drawing, timer usage, 

or as a lightweight desktop clock you can drop straight into /Applications.

## Screenshot
<img width="401" height="430" alt="image" src="https://github.com/user-attachments/assets/27615a49-c51c-44fa-a532-2b194758294c" />

## Build

Create the directory first
```bash
$ mkdir -p ClockApp.app/Contents/MacOS
```

Then create ClockApp.app/Contents/Info.plist

```bash
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>CFBundleName</key>
    <string>ClockApp</string>
    <key>CFBundleExecutable</key>
    <string>ClockApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourname.myapp</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
  </dict>
</plist>
```

Compile main.m and place the binary into the directory

```bash
clang -fobjc-arc -framework Cocoa main.m -o ClockApp.app/Contents/MacOS/ClockApp
```

## Run

Launch the app by opening Clock.app

(Optional) Move Clock.app to /Applications/ and double-click to run.


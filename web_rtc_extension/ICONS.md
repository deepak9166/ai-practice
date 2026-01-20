# Icon Setup

The extension requires three icon files. Here are quick ways to create them:

## Option 1: Use Online Tool
1. Go to https://www.favicon-generator.org/ or similar
2. Upload any image (256x256 or larger recommended)
3. Download the generated icons
4. Rename and place in this directory:
   - `icon16.png`
   - `icon48.png`
   - `icon128.png`

## Option 2: Use Image Editor
1. Create a 128x128 pixel image
2. Export as PNG at three sizes: 16x16, 48x48, 128x128
3. Save as `icon16.png`, `icon48.png`, `icon128.png`

## Option 3: Quick Test Icons
For testing, you can use any simple colored square images. The extension will work without proper icons, but Chrome may show a default icon.

## Temporary Solution
If you just want to test, you can temporarily comment out the icon references in `manifest.json`, though this is not recommended for production.


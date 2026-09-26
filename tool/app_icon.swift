import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let designSide: CGFloat = 360
let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

func color(_ hex: UInt32) -> CGColor {
  CGColor(
    colorSpace: colorSpace,
    components: [
      CGFloat((hex >> 16) & 0xFF) / 255,
      CGFloat((hex >> 8) & 0xFF) / 255,
      CGFloat(hex & 0xFF) / 255,
      1,
    ]
  )!
}

let ground = color(0x1D5999)
let ink = color(0xFFFFFF)
let name = "ذهين"

let fontData = try Data(contentsOf: URL(fileURLWithPath: "assets/fonts/Amiri-Regular.ttf"))
let amiri = CGFont(CGDataProvider(data: fontData as CFData)!)!

enum Ground {
  case square
  case roundedSquare
  case none
}

func render(canvas: Int, content: CGFloat, ground style: Ground, to path: String) throws {
  let side = CGFloat(canvas)
  let opaque = style == .square
  let context = CGContext(
    data: nil,
    width: canvas,
    height: canvas,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: opaque
      ? CGImageAlphaInfo.noneSkipLast.rawValue
      : CGImageAlphaInfo.premultipliedLast.rawValue
  )!
  context.setShouldAntialias(true)
  context.setShouldSmoothFonts(false)

  let unit = content / designSide
  let inset = (side - content) / 2

  switch style {
  case .square:
    context.setFillColor(ground)
    context.fill(CGRect(x: 0, y: 0, width: side, height: side))
  case .roundedSquare:
    let rect = CGRect(x: 0, y: 0, width: side, height: side).insetBy(dx: side / 48, dy: side / 48)
    let radius = rect.width * 80 / designSide
    context.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
    context.setFillColor(ground)
    context.fillPath()
  case .none:
    break
  }

  let fontSize = 120 * unit
  let font = CTFontCreateWithGraphicsFont(amiri, fontSize, nil, nil)
  let line = CTLineCreateWithAttributedString(
    NSAttributedString(
      string: name,
      attributes: [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): ink,
      ]
    )
  )
  let ascent = CTFontGetAscent(font)
  let descent = CTFontGetDescent(font)
  let width = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
  let boxTop = inset + (content - fontSize) / 2 - 10 * unit
  let baselineFromTop = boxTop + (fontSize - (ascent + descent)) / 2 + ascent
  context.textPosition = CGPoint(x: (side - width) / 2, y: side - baselineFromTop)
  CTLineDraw(line, context)

  let image = context.makeImage()!
  let url = URL(fileURLWithPath: path)
  try FileManager.default.createDirectory(
    at: url.deletingLastPathComponent(),
    withIntermediateDirectories: true
  )
  let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(destination, image, nil)
  guard CGImageDestinationFinalize(destination) else {
    throw NSError(domain: "app_icon", code: 1, userInfo: [NSLocalizedDescriptionKey: path])
  }
  print("\(canvas)px \(path)")
}

let appIconSet = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
let contents = try JSONSerialization.jsonObject(
  with: Data(contentsOf: URL(fileURLWithPath: "\(appIconSet)/Contents.json"))
) as! [String: Any]

for entry in contents["images"] as! [[String: Any]] {
  guard let filename = entry["filename"] as? String,
        let size = (entry["size"] as? String)?.split(separator: "x").first.flatMap({ Double($0) }),
        let scale = (entry["scale"] as? String)?.dropLast().description,
        let factor = Double(scale)
  else { continue }
  let pixels = Int((size * factor).rounded())
  try render(canvas: pixels, content: CGFloat(pixels), ground: .square, to: "\(appIconSet)/\(filename)")
}

let densities: [(String, CGFloat)] = [
  ("mdpi", 1), ("hdpi", 1.5), ("xhdpi", 2), ("xxhdpi", 3), ("xxxhdpi", 4),
]
let res = "android/app/src/main/res"

for (name, factor) in densities {
  let legacy = Int(48 * factor)
  try render(
    canvas: legacy,
    content: CGFloat(legacy),
    ground: .roundedSquare,
    to: "\(res)/mipmap-\(name)/ic_launcher.png"
  )

  let layer = Int(108 * factor)
  try render(
    canvas: layer,
    content: 72 * factor,
    ground: .none,
    to: "\(res)/mipmap-\(name)/ic_launcher_foreground.png"
  )
}

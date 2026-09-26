import AVFoundation
import CoreGraphics
import CoreText
import Foundation

let arguments = CommandLine.arguments
guard arguments.count >= 5, let seconds = Int(arguments[2]), seconds > 0 else {
  print("usage: sample_videos <out.mp4> <seconds> <title> <subtitle>")
  exit(1)
}

let outputURL = URL(fileURLWithPath: arguments[1])
let title = arguments[3]
let subtitle = arguments[4]
let width = 640
let height = 360
let fps: Int32 = 10

try? FileManager.default.removeItem(at: outputURL)

let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
let input = AVAssetWriterInput(
  mediaType: .video,
  outputSettings: [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoCompressionPropertiesKey: [
      AVVideoAverageBitRateKey: 48_000,
      AVVideoMaxKeyFrameIntervalKey: 100,
      AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel,
    ],
  ]
)
input.expectsMediaDataInRealTime = false

let adaptor = AVAssetWriterInputPixelBufferAdaptor(
  assetWriterInput: input,
  sourcePixelBufferAttributes: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
    kCVPixelBufferWidthKey as String: width,
    kCVPixelBufferHeightKey as String: height,
  ]
)

writer.add(input)
writer.startWriting()
writer.startSession(atSourceTime: .zero)

let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
  CGColor(
    colorSpace: colorSpace,
    components: [
      CGFloat((hex >> 16) & 0xFF) / 255,
      CGFloat((hex >> 8) & 0xFF) / 255,
      CGFloat(hex & 0xFF) / 255,
      alpha,
    ]
  )!
}

func clock(_ value: Int) -> String {
  String(format: "%d:%02d", value / 60, value % 60)
}

func drawCentered(_ text: String, size: CGFloat, color textColor: CGColor, y: CGFloat, in context: CGContext) {
  let font = CTFontCreateWithName("Georgia" as CFString, size, nil)
  let attributed = NSAttributedString(
    string: text,
    attributes: [
      NSAttributedString.Key(kCTFontAttributeName as String): font,
      NSAttributedString.Key(kCTForegroundColorAttributeName as String): textColor,
    ]
  )
  let line = CTLineCreateWithAttributedString(attributed)
  let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
  context.textPosition = CGPoint(x: (CGFloat(width) - bounds.width) / 2 - bounds.minX, y: y)
  CTLineDraw(line, context)
}

func frame(at second: Int) -> CVPixelBuffer {
  var buffer: CVPixelBuffer?
  CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &buffer)
  let pixels = buffer!
  CVPixelBufferLockBaseAddress(pixels, [])
  let context = CGContext(
    data: CVPixelBufferGetBaseAddress(pixels),
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: CVPixelBufferGetBytesPerRow(pixels),
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
  )!

  context.setFillColor(color(0x282C32))
  context.fill(CGRect(x: 0, y: 0, width: width, height: height))

  context.setStrokeColor(color(0x82BCFF, 0.55))
  context.setLineWidth(1)
  context.stroke(CGRect(x: 24.5, y: 24.5, width: CGFloat(width) - 49, height: CGFloat(height) - 49))

  drawCentered(title, size: 34, color: color(0xF0F6FD), y: 196, in: context)
  drawCentered(subtitle, size: 16, color: color(0xB2B8BF), y: 160, in: context)
  drawCentered(
    "\(clock(second)) / \(clock(seconds))",
    size: 20,
    color: color(0x82BCFF),
    y: 104,
    in: context
  )

  let track = CGRect(x: 72, y: 72, width: CGFloat(width) - 144, height: 2)
  context.setFillColor(color(0xFFFFFF, 0.2))
  context.fill(track)
  context.setFillColor(color(0x82BCFF))
  context.fill(
    CGRect(
      x: track.minX,
      y: track.minY,
      width: track.width * CGFloat(second) / CGFloat(seconds),
      height: track.height
    )
  )

  CVPixelBufferUnlockBaseAddress(pixels, [])
  return pixels
}

for second in 0..<seconds {
  let pixels = frame(at: second)
  for step in 0..<Int(fps) {
    while !input.isReadyForMoreMediaData {
      usleep(1000)
    }
    let time = CMTime(value: CMTimeValue(second * Int(fps) + step), timescale: fps)
    adaptor.append(pixels, withPresentationTime: time)
  }
}

input.markAsFinished()
writer.endSession(atSourceTime: CMTime(value: CMTimeValue(seconds * Int(fps)), timescale: fps))

let done = DispatchSemaphore(value: 0)
writer.finishWriting { done.signal() }
done.wait()

if writer.status != .completed {
  print("failed: \(writer.error?.localizedDescription ?? "unknown")")
  exit(1)
}

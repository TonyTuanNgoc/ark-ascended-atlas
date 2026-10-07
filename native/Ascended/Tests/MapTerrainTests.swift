import XCTest
import UIKit
import QuartzCore
@testable import Ascended

final class MapTerrainTests: XCTestCase {
    @MainActor func testRetinaSourceCropKeepsImageLocalGeometry() {
        let format = UIGraphicsImageRendererFormat(); format.scale = 2
        let source = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 100), format: format).image { context in
            UIColor.red.setFill(); context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
            UIColor.blue.setFill(); context.fill(CGRect(x: 100, y: 0, width: 100, height: 100))
        }
        let view = MapTerrainView(frame: CGRect(origin: .zero, size: source.size)); view.image = source
        let result = UIGraphicsImageRenderer(size: source.size, format: format).image { _ in
            view.drawRegion(CGRect(x: 100, y: 0, width: 100, height: 100))
        }
        let blue = pixel(result, x: 300, y: 100)
        XCTAssertGreaterThan(blue[2], 240); XCTAssertLessThan(blue[0], 10)
        let empty = pixel(result, x: 100, y: 100)
        XCTAssertLessThan(empty[3], 10)
        let gps = MapCoordinateTransform.gps(at: CGPoint(x: 150, y: 25), size: view.bounds.size)!
        XCTAssertEqual(gps.lat, 25); XCTAssertEqual(gps.lon, 75)
    }
    @MainActor func testOverviewIsPresentAndDetailTilesDoNotFadeOrCoverMissingAreas() {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 64, height: 64)).image { context in
            UIColor.green.setFill(); context.fill(CGRect(x: 0, y: 0, width: 64, height: 64))
        }
        let view = MapTerrainView(frame: CGRect(x: 0, y: 0, width: 64, height: 64)); view.image = image
        view.layoutIfNeeded()
        let overview = view.subviews.first as? UIImageView
        XCTAssertNotNil(overview?.image)
        XCTAssertEqual(overview?.frame, view.bounds)
        let detail = view.subviews.last!
        XCTAssertFalse(detail.isOpaque)
        XCTAssertEqual(detail.backgroundColor, UIColor.clear)
        XCTAssertEqual(type(of: detail.layer as! CATiledLayer).fadeDuration(), 0)
        let firstFrame = UIGraphicsImageRenderer(size: view.bounds.size).image { context in
            view.layer.render(in: context.cgContext)
        }
        XCTAssertGreaterThan(pixel(firstFrame, x: 20, y: 20)[1], 200, "Overview must cover the first frame before detail tiles arrive")
    }
    private func pixel(_ image: UIImage, x: Int, y: Int) -> [UInt8] {
        let crop = image.cgImage!.cropping(to: CGRect(x: x, y: y, width: 1, height: 1))!
        var bytes = [UInt8](repeating: 0, count: 4)
        bytes.withUnsafeMutableBytes { pointer in
            let context = CGContext(data: pointer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                                    space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            context.draw(crop, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return bytes
    }
}

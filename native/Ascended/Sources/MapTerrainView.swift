import UIKit
import QuartzCore

/// Render source-image regions at each zoom level rather than scaling a single overview texture.
/// Image-local bounds remain the same GPS plane used by markers and long-press coordinates.
private final class DetailTerrainView: UIView {
    override class var layerClass: AnyClass { ImmediateTerrainLayer.self }
    var image: UIImage? { didSet { layer.setNeedsDisplay() } }
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tiles = layer as! CATiledLayer
        tiles.tileSize = CGSize(width: 512, height: 512)
        tiles.levelsOfDetail = 8
        tiles.levelsOfDetailBias = 5
        isOpaque = false
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func draw(_ rect: CGRect) {
        guard let image, let source = image.cgImage, let context = UIGraphicsGetCurrentContext() else { return }
        let visible = rect.intersection(bounds)
        guard !visible.isNull, !visible.isEmpty else { return }
        let sourceRect = CGRect(x: visible.minX * image.scale, y: visible.minY * image.scale,
                                width: visible.width * image.scale, height: visible.height * image.scale)
            .integral.intersection(CGRect(x: 0, y: 0, width: source.width, height: source.height))
        guard let tile = source.cropping(to: sourceRect) else { return }
        context.interpolationQuality = .high
        UIImage(cgImage: tile).draw(in: CGRect(x: sourceRect.minX / image.scale, y: sourceRect.minY / image.scale,
                                             width: sourceRect.width / image.scale, height: sourceRect.height / image.scale))
    }
}

/// A decoded overview is visible before asynchronous detail tiles finish.
/// Both layers share the same image-local GPS plane; missing tiles are transparent.
final class MapTerrainView: UIView {
    private let overview = UIImageView()
    private let detail = DetailTerrainView()
    var image: UIImage? {
        didSet {
            guard let image else { overview.image = nil; detail.image = nil; return }
            let scale = min(1, 1280 / max(image.size.width, image.size.height))
            let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = true
            let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            overview.image = UIGraphicsImageRenderer(size: size, format: format).image { _ in
                image.draw(in: CGRect(origin: .zero, size: size))
            }
            detail.image = image
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        overview.contentMode = .scaleToFill
        addSubview(overview); addSubview(detail)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews(); overview.frame = bounds; detail.frame = bounds
    }
    // Preserve the source-region renderer used by geometry/pixel QA.
    func drawRegion(_ rect: CGRect) { detail.bounds = bounds; detail.draw(rect) }
}
private final class ImmediateTerrainLayer: CATiledLayer {
    override class func fadeDuration() -> CFTimeInterval { 0 }
}

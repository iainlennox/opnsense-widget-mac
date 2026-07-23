import SwiftUI

struct BandwidthGraphView: View {
    let inHistory: [Double]
    let outHistory: [Double]
    let scale: Double

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(red: 0.07, green: 0.07, blue: 0.11))
            )

            if inHistory.count >= 2, scale > 0 {
                drawLine(context: context, samples: inHistory, scale: scale, w: w, h: h,
                         stroke: Color(red: 0.54, green: 0.71, blue: 0.98),
                         fill: Color(red: 0.54, green: 0.71, blue: 0.98).opacity(0.2))
            }

            if outHistory.count >= 2, scale > 0 {
                drawLine(context: context, samples: outHistory, scale: scale, w: w, h: h,
                         stroke: Color(red: 0.98, green: 0.70, blue: 0.53),
                         fill: Color(red: 0.98, green: 0.70, blue: 0.53).opacity(0.2))
            }
        }
    }

    private func drawLine(context: GraphicsContext, samples: [Double], scale: Double,
                          w: CGFloat, h: CGFloat, stroke: Color, fill: Color) {
        var linePath = Path()
        var fillPath = Path()

        for (i, sample) in samples.enumerated() {
            let x = w * CGFloat(i) / CGFloat(samples.count - 1)
            let normalized = min(1.0, sample / scale)
            let y = h - (normalized * h * 0.88) - h * 0.06

            if i == 0 {
                linePath.move(to: CGPoint(x: x, y: y))
                fillPath.move(to: CGPoint(x: x, y: y))
            } else {
                linePath.addLine(to: CGPoint(x: x, y: y))
                fillPath.addLine(to: CGPoint(x: x, y: y))
            }
        }

        fillPath.addLine(to: CGPoint(x: w, y: h))
        fillPath.addLine(to: CGPoint(x: 0, y: h))
        fillPath.closeSubpath()

        context.fill(fillPath, with: .color(fill))
        context.stroke(linePath, with: .color(stroke), lineWidth: 1.5)
    }
}

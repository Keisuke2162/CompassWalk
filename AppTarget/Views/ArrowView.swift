import SwiftUI

struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // 上向き矢印（ナビゲーション用）
        path.move(to: CGPoint(x: w * 0.5, y: 0))           // 先端
        path.addLine(to: CGPoint(x: w, y: h * 0.7))         // 右下
        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.5))   // 内側のくぼみ
        path.addLine(to: CGPoint(x: 0, y: h * 0.7))         // 左下
        path.closeSubpath()

        return path
    }
}

struct ArrowView: View {
    let rotationDegrees: Double

    var body: some View {
        ArrowShape()
            .fill(
                LinearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
            .rotationEffect(.degrees(rotationDegrees))
            .animation(.easeInOut(duration: 0.3), value: rotationDegrees)
    }
}

#Preview {
    VStack(spacing: 40) {
        ArrowView(rotationDegrees: 0)
            .frame(width: 100, height: 150)
        ArrowView(rotationDegrees: 45)
            .frame(width: 100, height: 150)
        ArrowView(rotationDegrees: 90)
            .frame(width: 100, height: 150)
    }
}

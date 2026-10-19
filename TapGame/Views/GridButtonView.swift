import SwiftUI
import UIKit

struct GridButtonView: View {
    let index: Int
    let isTarget: Bool
    let isPlaying: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        isTarget
                            ? LinearGradient(colors: [Color.red, Color(red: 0.9, green: 0.1, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color(.secondarySystemBackground), Color(.tertiarySystemBackground)], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(
                        color: isTarget ? Color.red.opacity(0.45) : Color.black.opacity(0.06),
                        radius: isTarget ? 10 : 3,
                        x: 0,
                        y: isTarget ? 5 : 2
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isTarget ? Color.white.opacity(0.8) : Color.black.opacity(0.04), lineWidth: isTarget ? 2 : 1)
                    )
                
                if isTarget {
                    VStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                        Text("点我!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.secondary.opacity(0.3))
                }
            }
            .aspectRatio(1.0, contentMode: .fit)
        }
        .buttonStyle(GridCellButtonStyle())
        .disabled(!isPlaying)
        .accessibilityLabel(isTarget ? "目标方格 \(index + 1)" : "方格 \(index + 1)")
        .accessibilityAddTraits(isTarget ? [.isButton, .isSelected] : [.isButton])
    }
}

struct GridCellButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

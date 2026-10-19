import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let maxGridWidth: CGFloat = isPad ? 420 : min(geometry.size.width - 40, 360)
            
            ZStack {
                // Background gradient
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: isPad ? 24 : 16) {
                    // Header title
                    VStack(spacing: 4) {
                        Text("20秒点点乐")
                            .font(.system(size: isPad ? 36 : 28, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("快速点击出现的红色目标！")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, isPad ? 20 : 10)
                    
                    // Stats Dashboard
                    HStack(spacing: 16) {
                        StatCardView(
                            title: "当前得分",
                            value: "\(viewModel.score)",
                            icon: "flame.fill",
                            tint: .orange
                        )
                        
                        StatCardView(
                            title: "剩余时间",
                            value: String(format: "%.1fs", max(0, viewModel.timeRemaining)),
                            icon: "timer",
                            tint: viewModel.timeRemaining <= 5 && viewModel.status == .playing ? .red : .blue
                        )
                        
                        StatCardView(
                            title: "最高记录",
                            value: "\(viewModel.highScore)",
                            icon: "trophy.fill",
                            tint: .yellow
                        )
                    }
                    .frame(maxWidth: maxGridWidth)
                    .padding(.horizontal, 8)
                    
                    // Progress Bar for Time
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(viewModel.timeRemaining <= 5 ? Color.red : Color.blue)
                            .frame(width: max(0, CGFloat(viewModel.timeRemaining / 20.0) * maxGridWidth), height: 8)
                            .animation(.linear(duration: 0.1), value: viewModel.timeRemaining)
                    }
                    .frame(maxWidth: maxGridWidth)
                    .padding(.horizontal, 8)
                    
                    Spacer()
                    
                    // 3x3 Grid
                    VStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(0..<3, id: \.self) { col in
                                    let index = row * 3 + col
                                    GridButtonView(
                                        index: index,
                                        isTarget: viewModel.activeTargetIndex == index,
                                        isPlaying: viewModel.status == .playing
                                    ) {
                                        viewModel.tapCell(at: index)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: maxGridWidth)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // Bottom Controls / Status
                    VStack(spacing: 12) {
                        if viewModel.status == .ready {
                            Button(action: {
                                viewModel.startGame()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                    Text("开始挑战")
                                }
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: maxGridWidth)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.blue.opacity(0.35), radius: 8, x: 0, y: 4)
                            }
                        } else if viewModel.status == .playing {
                            Button(action: {
                                viewModel.resetGame()
                            }) {
                                Text("放弃重来")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 44)
                        } else if viewModel.status == .gameOver {
                            Button(action: {
                                viewModel.startGame()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("再玩一次")
                                }
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: maxGridWidth)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(colors: [Color.green, Color.teal], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.green.opacity(0.35), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                    .padding(.bottom, isPad ? 40 : 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Game Over Overlay Banner
                if viewModel.status == .gameOver {
                    GameOverOverlay(viewModel: viewModel)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
}

// Subview: Stats Card
struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(tint)
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
}

// Subview: Game Over Overlay
struct GameOverOverlay: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if viewModel.isNewHighScore {
                    Text("🎉 创造新纪录！")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
                } else {
                    Text("⏰ 时间到！")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                VStack(spacing: 8) {
                    Text("本局得分")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("\(viewModel.score)")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 8)
                
                HStack(spacing: 24) {
                    VStack {
                        Text("最高纪录")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        Text("\(viewModel.highScore)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                
                Button(action: {
                    viewModel.startGame()
                }) {
                    Text("立即再战")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .padding(.top, 8)
            }
            .padding(28)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
        }
    }
}

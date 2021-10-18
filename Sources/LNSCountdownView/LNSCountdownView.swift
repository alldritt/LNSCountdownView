import SwiftUI
import Foundation


private struct CountdownTrackView: View {
    let lineWidth: CGFloat
    let pausedColor: Color
    @Binding var paused: Bool
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            if paused {
                ZStack {
                    Circle()
                        .stroke(pausedColor.opacity(0.5), lineWidth: lineWidth)
                    Circle()
                        .rotation(.degrees(-90))
                        .stroke(pausedColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .square, dash: [0.5, lineWidth * 2], dashPhase: phase))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear { phase -= lineWidth * 2 }
                        .animation(.linear(duration: 0.8).repeatForever(autoreverses: false))
                        .transition(.opacity)
                }
            }
            else {
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: lineWidth)
                    .transition(.opacity)
            }
        }
        .animation(.linear(duration: 0.3), value: paused)
    }
}


public struct LNSCountdownProgressView: View {
    public let title: String
    public let duration: TimeInterval
    @Binding public var progress: CGFloat
    @Binding public var paused: Bool
    
    public init(title: String, duration: TimeInterval, progress: Binding<CGFloat>, paused: Binding<Bool>) {
        self.title = title
        self.duration = duration
        self._progress = progress
        self._paused = paused
    }
    
    private var localProgress: Double {
        return max(0.0001, min(1.0, progress))
    }
    
    private var remainingTime: String {
        let timeLeft = Int((duration - localProgress * duration).rounded())
        
        let seconds = timeLeft % 60
        let minutes = timeLeft / 60
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
    
    private var completed: Bool {
        return localProgress >= 1
    }

    public var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let lineWidth = size / 8.9

            ZStack {
                let color = completed ? Color.green : Color.blue
                
                //  Title and Time...
                VStack(spacing: 1) {
                    if !title.isEmpty {
                        Text(title)
                            .font(.system(size: size / 7.85))
                    }
                    Text(remainingTime)
                        .font(.system(size: title.isEmpty ? size / 4.25 : size / 5.0))
                        .fontWeight(.black)
                }
                
                //  Progress background circle
                CountdownTrackView(lineWidth: lineWidth - 2,
                                   pausedColor: .orange.opacity(0.7),
                                   paused: $paused)
                    .overlay(
                        //  Progress circle
                        Circle()
                            .trim(from:0, to: CGFloat(localProgress))
                            .rotation(.degrees(-90))
                            .stroke(color,
                                    style: StrokeStyle(
                                        lineWidth: lineWidth,
                                        lineCap: .round)
                            )
                            .overlay(
                                GeometryReader { geo in
                                    // End round line cap
                                    Circle()
                                        .fill(color)
                                        .frame(width: lineWidth, height: lineWidth)
                                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                        .offset(x: min(geo.size.width, geo.size.height) / 2)
                                        .rotationEffect(.degrees(localProgress * 360 - 90))
                                        .shadow(color: .black, radius: lineWidth / 8)
                                        .clipShape(
                                            // Clip end round line cap and shadow to front
                                            Circle()
                                                .rotation(.degrees(-90 + localProgress * 360 - 0.5))
                                                .trim(from: 0, to: 0.25)
                                                .stroke(style: .init(lineWidth: lineWidth))
                                        )
                                }
                            )
                    )
                    .animation(
                        .easeInOut(duration: 1), value: progress
                    )
            }
            .padding(lineWidth / 2)
        }
    }
}


public struct LNSCountdownTimerView: View {
    private let timer = Timer.publish(every: 1.0 / 20, on: .main, in: .common).autoconnect()

    public let title: String
    public let duration: TimeInterval
    public let completion: (() -> Void)
    
    @State private var start = Date.distantFuture
    @State private var update = false
    
    public init(title: String, duration: TimeInterval, completion: @escaping (() -> Void)) {
        self.title = title
        self.duration = duration
        self.completion = completion
    }

    private var progress: Double {
        let now = Date()
        let delta = now.timeIntervalSince(start)
        
        return max(0.0001, min(1.0, delta / duration))
    }
    
    private var remainingTime: String {
        let timeLeft = Int((duration - progress * duration).rounded())
        
        let seconds = timeLeft % 60
        let minutes = timeLeft / 60
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
    
    private var completed: Bool {
        return progress >= 1
    }

    public var body: some View {
        let _ = update
        
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let lineWidth = size / 8.9

            ZStack {
                let color = completed ? Color.orange : Color.blue
                
                VStack(spacing: 1) {
                    if !title.isEmpty {
                        Text(title)
                            .font(.system(size: size / 7.85))
                    }
                    Text(remainingTime)
                        .font(.system(size: title.isEmpty ? size / 4.25 : size / 5.0))
                        .fontWeight(.black)
                }
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: lineWidth - 2)
                    .overlay(
                        Circle()
                            .trim(from:0, to: CGFloat(progress))
                            .rotation(.degrees(-90))
                            .stroke(color,
                                    style: StrokeStyle(
                                        lineWidth: lineWidth,
                                        lineCap: .round)
                            )
                            .overlay(
                                GeometryReader { geo in
                                    // End round line cap
                                    Circle()
                                        .fill(color)
                                        .frame(width: lineWidth, height: lineWidth)
                                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                        .offset(x: min(geo.size.width, geo.size.height) / 2)
                                        .rotationEffect(.degrees(progress * 360 - 90))
                                        .shadow(color: .black, radius: lineWidth / 8)
                                        .clipShape(
                                            // Clip end round line cap and shadow to front
                                            Circle()
                                                .rotation(.degrees(-90 + progress * 360 - 0.5))
                                                .trim(from: 0, to: 0.25)
                                                .stroke(style: .init(lineWidth: lineWidth))
                                        )
                                }
                            )
                    )
                    .animation(
                        .easeInOut(duration: 1), value: progress
                    )
            }
            .padding(lineWidth / 2)
            .onReceive(timer) { time in
                if completed {
                    self.timer.upstream.connect().cancel()
                    completion()
                }
                else {
                    update.toggle()
                }
            }
            .onAppear() {
                start = Date()
            }
        }
    }
}


public struct LNSCountdownPausableTimerView: View {
    private let timer = Timer.publish(every: 1 / 10, on: .main, in: .common).autoconnect()

    private let title: String
    private let duration: TimeInterval
    private let completion: (() -> Void)
    @Binding private var paused: Bool
    
    @State private var progress = CGFloat(0)
    @State private var accumulatedDuration = TimeInterval(0)
    @State private var start: Date?
    
    public init(title: String, duration: TimeInterval, paused: Binding<Bool>, completion: @escaping (() -> Void)) {
        self.title = title
        self.duration = duration
        self.completion = completion
        self._paused = paused
    }
    
    public var body: some View {
        LNSCountdownProgressView(title: title, duration: duration, progress: $progress, paused: $paused)
        .onReceive(timer) { time in
            let now = Date()
            let delta: TimeInterval
            
            if let start = start {
                delta = now.timeIntervalSince(start)
            }
            else {
                delta = 0
            }
            
            progress = (accumulatedDuration + delta) / duration
            if progress >= 1 {
                self.timer.upstream.connect().cancel()
                completion()
            }
            else if paused {
                accumulatedDuration += delta
                start = nil
            }
            else if start == nil {
                start = now
            }
        }
        .onAppear() {
            start = Date()
        }
    }
}

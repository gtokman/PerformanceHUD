import SwiftUI

public struct PerfHUD: View {
	public enum ChartType {
		case path, chart
	}
	private let monitor = PerfMonitor.shared
	
	let position: CGPoint
	let chartType: ChartType
	
	public init(position: CGPoint = .init(x: 0, y: 0), chartType: ChartType = .chart) {
		self.position = position
		self.chartType = chartType
	}
	public var body: some View {
		HStack(spacing: 8) {
			VStack {
				Text("RAM")
				Text(String(format: "%.0f", monitor.ramMB))
				Text("MB")
			}
			.font(.caption2)
			.frame(width: 44)
			
			Group {
				switch chartType {
				case .chart:
					SparklineChart(values: monitor.history)
				case .path:
					SparklinePath(values: monitor.history)
				}
			}
			.frame(width: 60, height: 30)
			.overlay(HStack(spacing: 4) { 
				Text("\(monitor.fps)").font(.subheadline.bold())
				Text("fps").font(.caption)
			})
		}
		.padding(6)
		.background(Color(.systemBackground))
		.overlay(RoundedRectangle(cornerRadius: 4).stroke(.gray, lineWidth: 2))
		.cornerRadius(4)
		.shadow(radius: 2)
		.offset(x: position.x, y: position.y)
		.onAppear { monitor.start() }
	}
}

#Preview {
	NavigationStack {
		PerfHUD()
	}
}

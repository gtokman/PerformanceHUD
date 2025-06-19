import SwiftUI
import Combine
import QuartzCore
import MachO
import Charts

@Observable
public final class PerfMonitor {
	@MainActor public static let shared = PerfMonitor()
	
	var fps: Int = 0
	var ramMB: Double = 0
	var history: [Int] = Array(repeating: 0, count: 30)
	
	private var link: CADisplayLink?
	private var frames = 0
	private var last = CACurrentMediaTime()
	
	public func start() {
		guard link == nil else { return }
		link = CADisplayLink(target: self, selector: #selector(tick))
		link?.add(to: .main, forMode: .common)
	}
	
	@objc private func tick(_ dl: CADisplayLink) {
		frames += 1
		let now = dl.timestamp
		guard now - last >= 1 else { return }
		fps = frames
		frames = 0
		last = now
		
		var info = task_vm_info_data_t()
		var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4
		let kr = withUnsafeMutablePointer(to: &info) {
			$0.withMemoryRebound(to: integer_t.self, capacity: 1) {
				task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
			}
		}
		if kr == KERN_SUCCESS {
			ramMB = Double(info.phys_footprint) / 1_048_576
		}
		
		history.append(fps)
		if history.count > 30 { history.removeFirst() }
	}
}

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

struct SparklineChart: View {
	let values: [Int]
	
	var body: some View {
		Chart {
			ForEach(Array(values.enumerated()), id: \.offset) { i, v in
				LineMark(
					x: .value("t", i),
					y: .value("v", v)
				)
			}
		}
		.chartXAxis(.hidden)
		.chartYAxis(.hidden)
		.chartPlotStyle { $0.padding(.zero) }
	}
}

struct SparklinePath: View {
	let values: [Int]
	var body: some View {
		GeometryReader { geo in
			let maxV = (values.max() ?? 1)
			Path { p in
				for (i, v) in values.enumerated() {
					let x = geo.size.width * CGFloat(i) / CGFloat(values.count - 1)
					let y = geo.size.height * (1 - CGFloat(v) / CGFloat(maxV))
					if i == 0 { p.move(to: .init(x: x, y: y)) }
					else { p.addLine(to: .init(x: x, y: y)) }
				}
			}
			.stroke(Color.gray, lineWidth: 1)
		}
	}
}

#Preview {
	NavigationStack {
		PerfHUD()
	}
}

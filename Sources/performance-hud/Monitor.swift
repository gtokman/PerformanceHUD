//
//  Monitor.swift
//  PerformanceHUD
//
//  Created by Gary Tokman on 6/19/25.
//

import Combine
import QuartzCore
import MachO
import Charts

@Observable
public final class PerfMonitor {
	@MainActor public static let shared = PerfMonitor()
	
	var fps: Int = 0
	var ramMB: Double = 0
	var thermalState: String = "Nominal"
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
		
		thermalState = switch ProcessInfo.processInfo.thermalState {
		case .nominal: "Nominal"
		case .fair: "Fair"
		case .serious: "Serious"
		case .critical: "Critical"
		@unknown default: "Unknown"
		}
	}
}

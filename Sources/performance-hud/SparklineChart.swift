//
//  SparklineChart.swift
//  PerformanceHUD
//
//  Created by Gary Tokman on 6/19/25.
//

import SwiftUI
import Charts

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

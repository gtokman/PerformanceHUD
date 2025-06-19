//
//  SparklinePath.swift
//  PerformanceHUD
//
//  Created by Gary Tokman on 6/19/25.
//

import SwiftUI

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

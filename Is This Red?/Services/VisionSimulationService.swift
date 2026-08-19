//
//  VisionSimulationService.swift
//  Is This Red?
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import PencilKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum VisionMode: String, CaseIterable {
	case normal = "Normal"                  // 일반
	case protanopia = "Protanopia"          // 적색맹
	case deuteranopia = "Deuteranopia"      // 녹색맹
	case tritanopia = "Tritanopia"          // 청색맹
	case achromatopsia = "Achromatopsia"    // 전색맹

	// MARK: - Properties

	/// 이 모드의 RGB 변환 계수. 이미지 시뮬레이션과 색상 시뮬레이션이 공유하는 유일한 출처입니다.
	var colorMatrix: (r: SIMD3<Double>, g: SIMD3<Double>, b: SIMD3<Double>) {
		switch self {
		case .normal:
			return ([1, 0, 0], [0, 1, 0], [0, 0, 1])
		case .protanopia:
			return ([0.567, 0.433, 0], [0.558, 0.442, 0], [0, 0.242, 0.758])
		case .deuteranopia:
			return ([0.625, 0.375, 0], [0.7, 0.3, 0], [0, 0.3, 0.7])
		case .tritanopia:
			return ([0.95, 0.05, 0], [0, 0.433, 0.567], [0, 0.475, 0.525])
		case .achromatopsia:
			let luminance: SIMD3<Double> = [0.299, 0.587, 0.114]
			return (luminance, luminance, luminance)
		}
	}
}

enum VisionSimulator {

	// MARK: - Properties

	private static let context = CIContext()

	// MARK: - Methods

	static func render(drawing: PKDrawing, rect: CGRect) -> UIImage {
		drawing.image(from: rect, scale: 1)
	}

	static func simulate(image: UIImage, mode: VisionMode) -> UIImage {
		guard mode != .normal, let ciImage = CIImage(image: image) else { return image }

		let matrix = mode.colorMatrix
		let filter = CIFilter.colorMatrix()
		filter.inputImage = ciImage
		filter.rVector = CIVector(matrix.r)
		filter.gVector = CIVector(matrix.g)
		filter.bVector = CIVector(matrix.b)

		guard let output = filter.outputImage,
		      let cgImage = context.createCGImage(output, from: output.extent)
		else {
			return image
		}
		return UIImage(cgImage: cgImage)
	}

	/// `CIFilter`는 이미지에만 동작하므로, 팔레트 스와치처럼 개별 색상에는 같은 계수를 직접 곱합니다.
	static func simulate(color: Color, mode: VisionMode) -> Color {
		guard mode != .normal else { return color }

		var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
		UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

		let rgb = SIMD3(Double(red), Double(green), Double(blue))
		let matrix = mode.colorMatrix
		return Color(
			red: channel(matrix.r, rgb),
			green: channel(matrix.g, rgb),
			blue: channel(matrix.b, rgb),
			opacity: Double(alpha)
		)
	}

	/// 가중치와 RGB의 내적을 0...1로 자릅니다.
	private static func channel(_ weights: SIMD3<Double>, _ rgb: SIMD3<Double>) -> Double {
		let weighted = weights * rgb
		return min(max(weighted.x + weighted.y + weighted.z, 0), 1)
	}
}

// MARK: - CIVector + SIMD3

private extension CIVector {

	// MARK: - Initialize

	convenience init(_ vector: SIMD3<Double>) {
		self.init(x: CGFloat(vector.x), y: CGFloat(vector.y), z: CGFloat(vector.z), w: 0)
	}
}

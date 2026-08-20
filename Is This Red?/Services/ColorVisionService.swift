//
//  ColorVisionService.swift
//  Is This Red?
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

/// CoreImage 전담. `VisionMode.colorMatrix`를 이미지와 개별 색에 적용합니다.
enum ColorVisionService {

	// MARK: - Properties

	private static let context = CIContext()

	// MARK: - Methods

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

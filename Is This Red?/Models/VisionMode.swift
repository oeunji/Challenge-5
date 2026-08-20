//
//  VisionMode.swift
//  Is This Red?
//
//  Created by 이은지 on 2/23/26.
//

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

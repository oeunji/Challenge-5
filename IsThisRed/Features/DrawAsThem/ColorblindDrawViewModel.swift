//
//  ColorblindDrawViewModel.swift
//  Is This Red?
//

import SwiftUI
import PencilKit

/// `ColorblindDrawView`의 상태와 판단을 들고 있습니다.
///
/// `PKCanvasView`는 여기 두지 않습니다. `UIViewRepresentable`이 소유해야 하는 뷰라서,
/// 화면 밖 객체가 들고 있으면 재호스팅되며 터치 전달이 깨집니다. 렌더할 때 값(`PKDrawing`)만
/// 건네받습니다.
@Observable
final class ColorblindDrawViewModel {

	// MARK: - Types

	enum RevealSelection: String, CaseIterable {
		case simulated = "Simulated"
		case normal = "Normal"
	}

	// MARK: - Constants

	private static let missions: [String] = [
		"Draw a ripe apple.",
		"Design a traffic light.",
		"Draw a rainbow.",
		"Create a red and green warning sign.",
		"Draw a watermelon.",
		"Design a health bar (red to green)."
	]

	// MARK: - Properties

	let selectedMode: VisionMode
	let missionText: String
	/// 첫 색(검정)은 고정하고 나머지만 섞습니다.
	let palette: [Color]

	private(set) var isRevealActive = false
	var revealSelection: RevealSelection = .simulated
	var showRevealAlert = false
	var renderSize: CGSize = .zero

	private let session = DrawingSession()

	// MARK: - Initialize

	init(selectedMode: VisionMode) {
		self.selectedMode = selectedMode
		self.missionText = Self.missions.randomElement() ?? ""
		self.palette = [Color.black] + DrawingTool.defaultPalette.dropFirst().shuffled()
	}

	// MARK: - Computed Values

	/// Reveal 중 "Normal"을 고른 경우에만 실제 색을, 그 외에는 선택한 색각 모드를 적용합니다.
	var effectiveMode: VisionMode {
		isShowingNormal ? .normal : selectedMode
	}

	var displayedImage: UIImage? {
		isShowingNormal ? session.normalImage : session.simulatedImage
	}

	var isShowingNormal: Bool {
		isRevealActive && revealSelection == .normal
	}

	// MARK: - Actions

	func revealDidConfirm() {
		isRevealActive = true
		revealSelection = .normal
	}

	// MARK: - Methods

	func render(_ drawing: PKDrawing) {
		session.drawing = drawing
		session.render(.fixed(renderSize), mode: selectedMode)
	}
}

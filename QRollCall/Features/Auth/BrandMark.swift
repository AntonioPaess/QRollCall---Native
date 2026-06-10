//
//  BrandMark.swift
//  QRollCall
//
//  Composição QR Code 2x2: finder patterns nas diagonais (top-left e
//  bottom-right) + data grids 3x3 nas outras. O finder do top-left é
//  pintado em primary — dá personalidade à marca sem virar arco-íris.
//  Loading: os 18 dots dos grids fazem onda de luminosidade.
//

import SwiftUI

struct BrandMark: View {
    enum Style {
        /// Padrão: primary no top-left + textPrimary no resto. Para fundos neutros.
        case `default`
        /// Para fundos coloridos sólidos (splash, login success). Tudo branco.
        case onColor
    }

    /// Largura final do view (frame quadrado).
    var size: CGFloat = 48
    var isLoading: Bool = false
    var style: Style = .default

    @State private var phase: Double = 0

    var body: some View {
        // Cada quadrante ocupa ~46% do total; offset dá o gap visual entre eles.
        let q = size * 0.46
        let offset = size * 0.27

        ZStack {
            finderPattern(size: q, color: accentColor)
                .position(x: size / 2 - offset, y: size / 2 - offset)

            dataGrid(size: q, quadrant: 0)
                .position(x: size / 2 + offset, y: size / 2 - offset)

            dataGrid(size: q, quadrant: 1)
                .position(x: size / 2 - offset, y: size / 2 + offset)

            finderPattern(size: q, color: secondaryColor)
                .position(x: size / 2 + offset, y: size / 2 + offset)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
        .onAppear { tickIfNeeded() }
        .onChange(of: isLoading) { _, _ in tickIfNeeded() }
    }

    private var accentColor: Color {
        style == .onColor ? .white : AppColors.primary
    }

    private var secondaryColor: Color {
        style == .onColor ? .white.opacity(0.6) : AppColors.textPrimary
    }

    private var dataBaseColor: Color {
        style == .onColor ? .white : AppColors.textPrimary
    }

    // MARK: - Finder pattern (canto QR)

    private func finderPattern(size s: CGFloat, color: Color) -> some View {
        let stroke = s * 0.18
        let inner = s * 0.30
        let outerCorner = s * 0.26
        return ZStack {
            RoundedRectangle(cornerRadius: outerCorner, style: .continuous)
                .strokeBorder(color, lineWidth: stroke)
                .frame(width: s, height: s)
            RoundedRectangle(cornerRadius: outerCorner * 0.35, style: .continuous)
                .fill(color)
                .frame(width: inner, height: inner)
        }
    }

    // MARK: - Data grid 3x3

    private func dataGrid(size s: CGFloat, quadrant: Int) -> some View {
        let dot = s * 0.24
        let gap = s * 0.13
        return VStack(spacing: gap) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: gap) {
                    ForEach(0..<3, id: \.self) { col in
                        RoundedRectangle(cornerRadius: dot * 0.32, style: .continuous)
                            .fill(dataColor(row: row, col: col, quadrant: quadrant))
                            .frame(width: dot, height: dot)
                    }
                }
            }
        }
    }

    private func dataColor(row: Int, col: Int, quadrant: Int) -> Color {
        if isLoading {
            let dotIdx = quadrant * 9 + row * 3 + col
            let n = 18.0
            let dotPhase = (Double(dotIdx) / n + phase)
                .truncatingRemainder(dividingBy: 1.0)
            let wave = (sin(dotPhase * .pi * 2) + 1.0) / 2.0
            return dataBaseColor.opacity(0.2 + wave * 0.8)
        }
        return dataBaseColor
    }

    // MARK: - Animation

    private func tickIfNeeded() {
        guard isLoading else { return }
        Task { @MainActor in
            while isLoading {
                withAnimation(.linear(duration: 0.04)) {
                    phase = (phase + 1.0 / 32.0).truncatingRemainder(dividingBy: 1.0)
                }
                try? await Task.sleep(nanoseconds: 40_000_000)
            }
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        BrandMark(size: 48)
        BrandMark(size: 48, isLoading: true)
        BrandMark(size: 64)
    }
    .padding()
}

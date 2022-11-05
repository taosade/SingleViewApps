// Simple single view app with Tinder-like card swiping

import SwiftUI

struct Card: Equatable, Identifiable
{
	let id: UUID
	let number: Int
	var color: Color

	init()
	{
		self.id = UUID()
		self.number = Int.random(in: 100...999)
		self.color = [
			Color.orange, Color.green,  Color.red,  Color.brown,
			Color.indigo, Color.blue,   Color.cyan, Color.mint,
			Color.pink,   Color.purple, Color.teal, Color.yellow]
			.randomElement() ?? Color.gray
	}
}

struct OddOrEvenView: View
{
	let screenWidth: CGFloat = UIScreen.main.bounds.size.width

	@State private var score: Int = 0

	@State private var offset: CGSize = .zero

	@State private var stack: [Card] = [Card(), Card()]
	{
		didSet
		{
			// Add random card to the bottom of the stack

			while stack.count < 2 { stack.insert(Card(), at: 0) }
		}
	}

	var body: some View
	{
		VStack
		{
			Spacer(minLength: 0)

			Text("\(score)")
			.font(.largeTitle)
			.foregroundColor(score > 0 ? .primary : .red)
			.zIndex(1)

			Spacer(minLength: 0)

			ZStack
			{
				ForEach(stack)
				{
					card in Text("\(card.number)")
					.font(.custom("Courier", size: screenWidth * 0.3))
					.frame(width: screenWidth * 0.8, height: screenWidth * 1.2)
					.background
					{
						RoundedRectangle(cornerRadius: screenWidth * 0.05)
						.fill(RadialGradient(
							colors: [card.color, Color.white],
							center: .topLeading,
							startRadius: 0,
							endRadius: screenWidth * 2))
					}
					.offset(offsetValue(card))
					.rotationEffect(rotationAngle(card))
					.scaleEffect(scaleFactor(card))
					.gesture(DragGesture()
						.onChanged { value in offset = value.translation }
						.onEnded { value in dragEnded(value) })
				}
			}.zIndex(2)

			Spacer(minLength: 0)

			Text("\(Image(systemName: "arrowshape.turn.up.left")) odd or even \(Image(systemName: "arrowshape.turn.up.right"))")
			.font(.largeTitle)
			.zIndex(1)

			Spacer(minLength: 0)
		}
	}

	private func offsetValue(_ card: Card) -> CGSize
	{
		guard card.id == self.stack.last?.id else { return CGSize.zero }

		return self.offset
	}

	private func rotationAngle(_ card: Card) -> Angle
	{
		guard card.id == self.stack.last?.id else { return Angle.zero }

		return Angle(degrees: Double(self.offset.width * 0.02))
	}

	private func scaleFactor(_ card: Card) -> Double
	{
		guard card.id == self.stack.last?.id else { return 1 }

		return 1 - max(abs(self.offset.width), abs(self.offset.height)) / Double(screenWidth * 10)
	}

	private func dragEnded(_ offset: DragGesture.Value)
	{
		// Put card back after slight drag:

		guard abs(offset.translation.width) > self.screenWidth / 2
		else { withAnimation { self.offset = .zero }; return }

		if let number = self.stack.last?.number
		{
			if
			(offset.translation.width > 0 && number % 2 == 0) || // right swipe, even
			(offset.translation.width < 0 && number % 2 != 0)    // left swipe, odd
			{ score += 1 } else { score = 0 }
		}

		self.stack.removeLast()

		self.offset = .zero
	}
}

struct OddOrEvenView_Previews: PreviewProvider
{
	static var previews: some View
	{
		OddOrEvenView()
	}
}

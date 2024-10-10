import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct SizeRelativeJiggleModifier: ViewModifier {
  let jiggling: Bool
  let rotationTravel: CGFloat
  let offset: CGFloat
  
  @State var size: CGSize = .zero
  
  func body(content: Content) -> some View {
    content
      .overlay {
        GeometryReader { geometry in
          Color.clear.onAppear {
            self.size = geometry.size
          }
        }
      }
      .modifier(JiggleModifier(jiggle: jiggling, size: size, rotationTravel: rotationTravel, offset: offset))
  }
}

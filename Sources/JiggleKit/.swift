import SwiftUI

/// Modifier that jiggles
@available(iOS 17.0, macOS 14.0, *)
struct JiggleModifier: ViewModifier {
  let rotation: CGFloat = 2.4
  let offset: CGFloat = 0.8
  
  let jiggle: Bool

  @State private var triggered: Bool = false
  @State private var reversed: Bool = false
  
  private var offsetAmount: CGFloat {
    if (!jiggle || !triggered) {
      return 0.0
    }
    return offset
  }
  
  private var offsetAnimation: Animation {
    if (!jiggle) {
      return
        .easeInOut(duration: 0.14)
    } else {
      return
        .easeInOut(duration: randomize(interval: 0.14, withVariance: 0.009))
        .repeatForever(autoreverses: true)
        .delay(randomize(interval: 0.07, withVariance: 0.07))
    }
  }
  
  private var rotateAmount: CGFloat {
    if (!jiggle) {
      return 0
    }
    if (triggered) {
      if (reversed) {
        return rotation * -2
      }
      return rotation * 2
    }
    return 0
  }
  
  private var rotateAnimation: Animation {
    if (!jiggle) {
      return
        .easeInOut(duration: 0.12)
    } else {
      return
        .easeInOut(duration: randomize(interval: 0.12, withVariance: 0.009))
        .repeatForever(autoreverses: true)
        .delay(randomize(interval: 0.06, withVariance: 0.06))
    }
  }

  func body(content: Content) -> some View {
    content
      .offset(x: 0, y: offsetAmount)
      .animation(
        offsetAnimation,
        value: triggered == jiggle
      )
      .rotationEffect(.degrees(rotateAmount), anchor: .center)
      .animation(
        rotateAnimation,
        value: triggered == jiggle
      )
      .rotationEffect(.degrees(jiggle ? (reversed ? rotation : -rotation): 0), anchor: .center)
      .animation(
        .easeInOut(duration: 0.12)
        .delay(0.06),
        value: jiggle
      )
      .onAppear {
        // We changed this here so that the animation runs even if it starts with `jiggle == true`
        if (jiggle) {
          triggered = true
        }
      }
      .onChange(of: jiggle) {
        triggered = jiggle
        reversed = Bool.random()
      }
  }

  private func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
    interval + variance * (Double.random(in: -1...1))
  }
}

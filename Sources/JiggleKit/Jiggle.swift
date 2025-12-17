import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
extension View {
  /// Makes this view jiggle.
  ///
  /// - Parameters:
  ///   - isJiggling: Whether this view should be jiggling or not.
  ///   - intensity: The intensity with which this view should jiggle.
  public func jiggling(isJiggling: Bool = true, intensity: JiggleIntensity = .default) -> some View {
    modifier(SizeRelativeJiggleModifier(jiggling: isJiggling, rotationTravel: travelForIntensity(intensity), offset: offsetForIntensity(intensity)))
    }
  
  /// Makes this view jiggle.
  ///
  /// The jiggle effect is achieved through a combination of rotation and vertical offsets. To achieve a jiggling effect
  /// that looks consistent across shapes of different sizes, this modifier allows the amount of pixels to be travelled
  /// so that the  the *angular speed* matches across shapes.
  ///
  ///
  /// - Parameters:
  ///   - isJiggling: Whether this view should be jiggling or not.
  ///   - rotationTravel: The amount of pixels the corner of this view should travel (one way) due to the rotation while jiggling.
  ///   - offset: The amount of pixels this view should bounce up while jiggling.
  public func jiggling(isJiggling: Bool = true, rotationTravel: CGFloat = defaultRotationTravel, offset : CGFloat = defaultOffset) -> some View {
    modifier(SizeRelativeJiggleModifier(jiggling: isJiggling, rotationTravel: rotationTravel, offset: offset))
    }
  
  /// Makes this view jiggle by a fixed angle and offset.
  ///
  /// The jiggle effect is achieved through a combination of rotation and vertical offsets. This modifier allows for
  /// the rotation angle to be set directly. While this can seem more intuitive, having shapes of different size
  /// with the same rotation angle results in the bigger shapes looking like they're jiggling much harder than the
  /// smaller shapes.
  ///
  /// For better results when using with mismatched shapes, consider using ``jiggling(isJiggling:rotationTravel:offset:)`` or ``jiggling(isJiggling:intensity:)``
  ///
  /// - Parameters:
  ///   - isJiggling: Whether this view should be jiggling or not.
  ///   - rotationAngle: The angle in degrees this view should rotate (one way) while jiggling.
  ///   - offset: The amount of pixels this view should bounce up while jiggling.
  public func jiggling(isJiggling: Bool = true, rotationAngle: CGFloat, offset: CGFloat = defaultOffset) -> some View {
    modifier(JiggleModifier(jiggle: isJiggling, rotation: rotationAngle, offset: offset))
  }
}


/// The default amount of pixels travelled by the corner of the shape due to the
@_documentation(visibility: internal)
public let defaultRotationTravel: CGFloat = 1.8
/// The default amount of pixels travelled by the shape
@_documentation(visibility: internal)
public let defaultOffset: CGFloat = 0.8

/// The intensity at which to jiggle.
public enum JiggleIntensity {
  /// A subtle, barely noticeable jiggling effect.
  ///
  /// Corresponds to a rotational travel of `1.2` and an offset of `0.4`
  case subtle
  /// A moderate jiggling effect that aims to be similar to the iPhone's home screen jiggle mode.
  ///
  /// Corresponds to a rotational travel of `1.8` and an offset of `0.8`
  case moderate
  /// A strong jiggling effect guaranteed to grab the attention of your users.
  ///
  /// Corresponds to a rotational travel of `3.2` and an offset of `2.4`
  case vivacious
  /// An extreme jiggling effect that should be reserved for the most dire of circumstances.
  ///
  /// Use with caution. Corresponds to a rotational travel of `6.2` and an offset of `10.0`
  case extreme
  /// A moderate jiggling effect that aims to be similar to the iPhone's home screen jiggle mode.
  ///
  /// Corresponds to a rotational travel of `1.8` and an offset of `0.8`
  case `default`
}

private func travelForIntensity(_ intensity: JiggleIntensity) -> CGFloat {
  switch intensity {
  case .subtle: return 1.2
  case .moderate: return defaultRotationTravel
  case .vivacious: return 3.2
  case .extreme: return 6.2
  case .default: return defaultRotationTravel
  }
}

private func offsetForIntensity (_ intensity: JiggleIntensity) -> CGFloat {
  switch intensity {
  case .subtle: return 0.4
  case .moderate: return defaultOffset
  case .vivacious: return 2.4
  case .extreme: return 10.0
  case .default: return defaultOffset
  }
}

/// View modifier that makes the view it's applied to jiggle. This is acheived through a combination of rotation and bounce animations.
///
/// The tricks to making this look good are twofold:
///  - Make sure the rotation and bounce speed are close but not equal as to produce a beat to to their periods not matching
///  - Randomize the speed and phase so that multiple element don't jiggle all in sync
///
///  This modifier takes in fixed values for the rotation. See ``SizeRelativeJiggleModifier`` for a version
///  that retrieves those value for any view.
@available(iOS 17.0, macOS 14.0, *)
struct JiggleModifier: ViewModifier {
  let rotation: CGFloat
  let offset: CGFloat
  
  let jiggle: Bool
  
  init(jiggle: Bool, rotation: CGFloat, offset: CGFloat) {
    self.jiggle = jiggle
    self.rotation = rotation
    self.offset = offset
    self._id = State(initialValue: UUID())
  }
  
  init(jiggle: Bool, size: CGSize, rotationTravel: CGFloat, offset: CGFloat) {
    self.jiggle = jiggle
    
    // Calculate the distance from the center to a corner (radius of the rectangle)
    let radius = sqrt(pow(size.width / 2, 2) + pow(size.height / 2, 2))
    
    // The target distance traveled by the corner
    let targetDistance = rotationTravel
    
    // Use the formula to calculate the angle in radians: d = 2 * r * sin(θ/2)
    // Rearranged: θ = 2 * arcsin(d / (2 * r))
    let angleRadians = 2 * asin(targetDistance / (2 * radius))
    
    // Convert radians to degrees
    let angleDegrees = angleRadians * 180 / .pi
    self.rotation = angleDegrees
    
    self.offset = offset
    self._id = State(initialValue: UUID())
  }

  @State private var triggered: Bool = false
  @State private var reversed: Bool = false
  @State private var id: UUID
  
  private var offsetAmount: CGFloat {
    if (!jiggle || !triggered) {
      return 0.0
    }

    return offset
  }
  
  private var offsetAnimation: Animation {
    if (!jiggle || !triggered) {
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
    if (!jiggle || !triggered) {
      return 0
    }
    // The reason we multiply by (-)2 here is because we'll counter rotate by a
    // a factor of one in another non-repeating animation. This way we can have a
    // full left-to-right jiggle (-1 to 1) rather that a half (-1 to 0 or 1 to 0)
    if (triggered) {
      if (reversed) {
        return rotation * -2
      }
      return rotation * 2
    }
    return 0
  }
  
  private var rotateAnimation: Animation {
    if (!jiggle || !triggered) {
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
      .animation(offsetAnimation) {
        $0.projectionOffset(x: 0, y: offsetAmount)
      }
      .animation(rotateAnimation) {
        $0.rotationEffect(.degrees(rotateAmount), anchor: .center)
      }
      .animation(.easeInOut(duration: 0.12)
          .delay(0.06)) {
        $0.rotationEffect(.degrees(jiggle ? (reversed ? rotation : -rotation): 0), anchor: .center)
      }

      .onAppear {
        // We change this here so that the animation runs even if it starts with `jiggle == true`
        if (jiggle) {
          // Fixes a bug where when you put this in a LazyVStack, if you scroll too fast,
          // the animation doesn't actually trigger, even though all the changes
          // seem to happen in the right order. This is quite a hack, but I haven't
          // found a better solution.
          triggered = false
          Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(50))
            triggered = true
          }
        }
      }
      .onDisappear {
        if (jiggle) {
          triggered = false
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


@available(iOS 17.0, *)
#Preview("Many Small Squares") {
  @Previewable @State var isJiggling: Bool = false
  
  let colors: [Color] = [.red, .blue, .yellow, .green, .orange, .purple]
  
  VStack {
    Toggle("Jiggle", isOn: $isJiggling)
      .padding()
    Grid (verticalSpacing: 32.0){
      ForEach(0..<6) { row in
        GridRow {
          ForEach(0..<4) { col in
            RoundedRectangle(cornerRadius: 12)
              .fill(Color(colors[(row * 4 + col) % colors.count]))
              .frame(width: 64, height: 64)
              .jiggling(isJiggling: isJiggling)
          }
        }.frame(maxWidth:.infinity)
      }
    }
  }.padding()
}

@available(iOS 17.0, *)
#Preview("Big And Small Rectangles") {
  @Previewable @State var isJiggling: Bool = false
  
  let colors: [Color] = [.red, .blue, .yellow, .green, .orange, .purple]
  
  VStack {
    Toggle("Jiggle", isOn: $isJiggling)
      .padding()
    VStack(spacing: 16.0) {
      HStack(spacing: 16.0) {
        RoundedRectangle(cornerRadius: 24)
          .fill(Color(colors[0]))
          .frame(width: 144, height: 144)
          .jiggling(isJiggling: isJiggling)
        VStack(spacing: 16.0) {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color(colors[1]))
            .frame(width: 64, height: 64)
            .jiggling(isJiggling: isJiggling)
          RoundedRectangle(cornerRadius: 12)
            .fill(Color(colors[2]))
            .frame(width: 64, height: 64)
            .jiggling(isJiggling: isJiggling)
         }
        VStack(spacing: 16.0) {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color(colors[3]))
            .frame(width: 64, height: 64)
            .jiggling(isJiggling: isJiggling)
          RoundedRectangle(cornerRadius: 12)
            .fill(Color(colors[4]))
            .frame(width: 64, height: 64)
            .jiggling(isJiggling: isJiggling)
         }
      }
      
      RoundedRectangle(cornerRadius: 24)
        .fill(Color(colors[5]))
        .frame(width: 305, height: 144)
        .jiggling(isJiggling: isJiggling)
    }
  }.padding()
}

@available(iOS 17.0, *)
#Preview("Different Intensity") {
  @Previewable @State var isJiggling: Bool = false
  
  let colors: [Color] = [.red, .blue, .yellow, .green, .orange, .purple]
  
  VStack {
    Toggle("Jiggle", isOn: $isJiggling)
      .padding()
    ForEach(Array([JiggleIntensity.subtle, JiggleIntensity.moderate, JiggleIntensity.vivacious, JiggleIntensity.extreme].enumerated()), id: \.offset) { index, intensity in
      RoundedRectangle(cornerRadius: 24)
        .fill(Color(colors[index % colors.count]))
        .frame(width: 128, height: 128)
        .jiggling(isJiggling: isJiggling, intensity: intensity)
    }
  }.padding()
}

@available(iOS 17.0, *)
#Preview("Single for logs") {
  @Previewable @State var isJiggling: Bool = false
  
  let colors: [Color] = [.red, .blue, .yellow, .green, .orange, .purple]
  
  VStack {
    Toggle("Jiggle", isOn: $isJiggling)
      .padding()
    ForEach(Array([JiggleIntensity.extreme].enumerated()), id: \.offset) { index, intensity in
      RoundedRectangle(cornerRadius: 24)
        .fill(Color(colors[index % colors.count]))
        .frame(width: 128, height: 128)
        .jiggling(isJiggling: isJiggling, intensity: intensity)
    }
  }.padding()
}

@available(iOS 17.0, *)
#Preview("With disappear") {
  @Previewable @State var isJiggling: Bool = true
  let colors: [Color] = [.red, .blue, .yellow, .green, .orange, .purple]
  
  VStack {
    Toggle("Jiggle", isOn: $isJiggling)
      .padding()
    ScrollView {
      LazyVStack {
        ForEach(Array((1...100).enumerated()), id: \.offset) { index, value in
          RoundedRectangle(cornerRadius: 24)
            .fill(Color(colors[index % colors.count]))
            .frame(width: 128, height: 128)
            .jiggling(isJiggling: isJiggling, intensity: JiggleIntensity.vivacious)
        }
      }
    }
  }.padding()
}

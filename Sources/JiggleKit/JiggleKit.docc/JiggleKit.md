# ``JiggleKit``

## Overview

``JiggleKit`` is a revolutionary SwiftUI package that enables your `Views` to jiggle, like the iPhone home screen "jiggle mode". It has been developed by Vis Fitness for implementing a jiggle-mode-like functionality in our upcoming [Vis](https://vis.fitness) iOS app. We think you're gonna to love it.

![A set of rectangle of different shapes and colors all jiggling together in a delightful manner.](jiggle)

## Usage

Using this groundbreaking package is easy, as demonstrated by the following example:

```swift
struct JigglingRectable: View {

  var body: some View {
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(Color.red)
        .frame(width: 64, height: 64)
        // That's it.
        .jiggling()
    }
    .padding()
  }
}
```

However, for an even jigglier rounded rectangle, one can even set the intensity of the jiggling.

```swift
struct VeryJigglingRectable: View {

  var body: some View {
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(Color.red)
        .frame(width: 64, height: 64)
        // Now that's some strong jiggling!
        .jiggling(intensity: .vivacious)
    }
    .padding()
  }
}
```

## Github

The git repository as well as issue tracker for this project can be found at  [https://github.com/visfitness/JiggleKit](https://github.com/visfitness/JiggleKit).


## Topics

### Regular usage

- ``SwiftUICore/View/jiggling(isJiggling:intensity:)``
- ``JiggleKit/JiggleIntensity``

### Fine-tuned usage

- ``SwiftUICore/View/jiggling(isJiggling:rotationTravel:offset:)``
- ``SwiftUICore/View/jiggling(isJiggling:rotationAngle:offset:)``

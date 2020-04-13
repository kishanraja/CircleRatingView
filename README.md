# CircleRatingView
# CircleRatingView, a circular star rating control for iOS
It shows a star rating and takes rating input from the user. CircleRatingView is a subclass of a UIView

## Setup

#### Setup with CocoaPods

If you are using CocoaPods add this text to your Podfile and run `pod install`.

    use_frameworks!
    target 'Your target name'
    pod 'CircleRatingView',
    
#### Add source

Simply add [CircleRatingView.swift](https://github.com/kishanraja/CircleRatingView/tree/master/CircleRatingView/CircleRatingView.swift) file into your Xcode project. And add your desire rating image.

## Usage

1) Drag `View` object from the *Object Library* into your storyboard.

2) Set the view's class to `CircleRatingView` in the *Identity Inspector*.

3) Customize the CircleRatingView view appearance.

## Using CircleRatingView in code and Customization

Add `import CircleRatingView` to your source code, unless you used the file setup method.

You can style and control CircleRatingView view from your code by creating an outlet in your view controller.

```Swift
// Change circular line color
viewCircluerRating.lineColor = .red

// Allowed user to give rating or not
viewCircluerRating.isEditable = false

// Set default rate
viewCircluerRating.defaultRate = 2

// Set animation duration
viewCircluerRating.duration = 0.2

// Set icon size
viewCircluerRating.iconSize = CGSize(width: 35, height: 35)


# SwiftUI ScrollView Position Tracking Guide

## Overview
This guide explains how to reliably track scroll position in SwiftUI ScrollViews to trigger UI changes based on scroll offset.

---

## 📊 The Problem We Solved

### Initial Challenges:
- Multiple attempts using `PreferenceKey` and coordinate spaces returned 0 or didn't update
- Preference keys in ScrollViews are unreliable and require complex setup
- Coordinate space naming conflicts caused tracking failures
- Multiple GeometryReaders setting the same variable created conflicts

### The Root Cause:
SwiftUI's `PreferenceKey` pattern doesn't propagate reliably from within deeply nested ScrollView content. The preference values often fail to update or get lost in the view hierarchy.

---

## ✅ The Solution

Use **GeometryReader with `.onChange()` directly monitoring global frame position**

### Why This Works:
1. **GeometryReader** is attached as a `.background()` to the content that scrolls
2. **`.frame(in: .global)`** gives the Y position relative to the entire screen (not just the scroll view)
3. **`.onChange()`** fires **immediately** whenever the frame position changes (i.e., when scrolling)
4. As you scroll down, the content moves up, so `minY` becomes **negative**

### Expected Values:
- **At top of scroll**: Y ≈ 52 (just below navigation bar) or 0 depending on layout
- **Scrolling down**: Y becomes negative: -10, -50, -100, -200...
- **Scrolling up past initial**: Y can become more positive

---

## 📋 Implementation Spec

### **Step 1: Add State Variable**

```swift
@State private var scrollOffset: CGFloat = 0
```

### **Step 2: Attach GeometryReader to Scrollable Content**

```swift
ScrollView {
    VStack {
        // Your scrollable content here
        Text("Header")
        Text("Content")
        // ... more content
    }
    .background(
        GeometryReader { geo in
            Color.clear
                .onAppear {
                    scrollOffset = geo.frame(in: .global).minY
                }
                .onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
                    scrollOffset = newValue
                    
                    // Add your scroll-based logic here
                    // Example: Hide FAB when scrolled down
                    if newValue < -10 {
                        showFAB = false
                    } else {
                        showFAB = true
                    }
                }
        }
    )
}
```

### **Step 3: Use ScrollOffset for UI Logic**

Compare `scrollOffset` to thresholds to trigger UI changes:

```swift
// Example 1: Hide floating action button when scrolled > 10px
if scrollOffset < -10 {
    showFAB = false
}

// Example 2: Show header shadow when scrolled
if scrollOffset < 0 {
    showHeaderShadow = true
}

// Example 3: Auto-snap to sections
if scrollOffset < -snapThreshold {
    scrollToNextSection()
}
```

---

## 🎯 Complete Working Example

```swift
struct ScrollableView: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var showFAB = true
    
    private let fabHideThreshold: CGFloat = 10
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<50) { index in
                        Text("Item \(index)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                scrollOffset = geo.frame(in: .global).minY
                            }
                            .onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
                                scrollOffset = newValue
                                
                                // Hide FAB when scrolled down more than threshold
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showFAB = newValue > -fabHideThreshold
                                }
                            }
                    }
                )
            }
            
            // Floating Action Button
            if showFAB {
                VStack {
                    Spacer()
                    Button(action: {
                        // Action here
                    }) {
                        Text("Action")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 60)
                }
            }
            
            // Debug indicator (optional)
            VStack {
                HStack {
                    Spacer()
                    Text("Y: \(Int(scrollOffset))")
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
                Spacer()
            }
        }
    }
}
```

---

## ✅ Do's and ❌ Don'ts

### ✅ DO:
- Use `.frame(in: .global)` for reliable positioning
- Use `.onChange()` modifier to capture real-time updates
- Attach GeometryReader as `.background()` to scrolling content
- Store scroll offset in a `@State` variable
- Use `withAnimation()` for smooth UI transitions based on scroll

### ❌ DON'T:
- Don't use `PreferenceKey` patterns (unreliable in ScrollView)
- Don't use `.frame(in: .named())` (requires complex coordinate space setup)
- Don't use `DragGesture` (doesn't capture native scroll momentum)
- Don't attach multiple GeometryReaders setting the same variable (they conflict)
- Don't use `.onPreferenceChange()` (values often don't propagate)

---

## 🔧 Common Use Cases

### 1. **Hide/Show Floating Action Button**
```swift
.onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
    scrollOffset = newValue
    withAnimation(.easeInOut(duration: 0.2)) {
        showFAB = newValue > -10 // Show when at top, hide when scrolled
    }
}
```

### 2. **Show Header Shadow on Scroll**
```swift
.onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
    showShadow = newValue < 0 // Show shadow when scrolled past top
}
```

### 3. **Auto-Snap to Section**
```swift
.onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
    if !hasSnapped && newValue < -snapThreshold {
        hasSnapped = true
        withAnimation {
            proxy.scrollTo("sectionID", anchor: .top)
        }
    }
}
```

### 4. **Change Navigation Bar Style**
```swift
.onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
    useOpaqueNavBar = newValue < -50 // Solid nav bar when scrolled
}
```

### 5. **Parallax Effect**
```swift
.offset(y: scrollOffset * 0.5) // Content moves at half scroll speed
```

---

## 🐛 Troubleshooting

### Problem: ScrollOffset Always Returns 0
**Solution:** Make sure the GeometryReader is attached to content that actually moves during scroll, not the ScrollView itself.

### Problem: ScrollOffset Doesn't Update
**Solution:** Verify you're using `.onChange(of: geo.frame(in: .global).minY)` not `.onAppear` or other modifiers.

### Problem: Jerky/Laggy Updates
**Solution:** Avoid heavy computations inside `.onChange()`. Use `withAnimation()` for smooth transitions.

### Problem: Multiple Conflicting Values
**Solution:** Only use ONE GeometryReader setting the scrollOffset variable. Remove any duplicate trackers.

---

## 📝 Summary

The reliable way to track scroll position in SwiftUI is:
1. Attach a GeometryReader as `.background()` to your scrollable content
2. Use `.onChange(of: geo.frame(in: .global).minY)` to capture position updates
3. Store the value in a `@State` variable
4. Use that variable to drive UI changes with thresholds

This approach is **simple, reliable, and performant** compared to PreferenceKey patterns.

---

## 📅 Document Info

- **Created:** January 27, 2026
- **SwiftUI Version:** iOS 17+
- **Tested On:** iPhone 17 Pro
- **Status:** Production-ready ✅

---

## 🔗 Related Topics

- ScrollViewReader for programmatic scrolling
- ScrollView performance optimization
- LazyVStack vs VStack in ScrollViews
- Coordinate spaces in SwiftUI
- GeometryReader best practices

---

**End of Guide**

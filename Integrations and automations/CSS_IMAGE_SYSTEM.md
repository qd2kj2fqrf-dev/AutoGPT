# CSS IMAGE SYSTEM
## Tailored Image Handling for Integrations & Automations Studio

**Scope:** All image assets use CSS-wrapped styling with theme-aware color injection, responsive breakpoints, and accessibility.

---

## IMAGE ARCHITECTURE

### Three Image Categories

| Category | Use Case | Storage | Loading |
|----------|----------|---------|---------|
| **Icons** | Integration logos, node kind badges | Base64 inline CSS | Instant (no HTTP) |
| **Backgrounds** | Theme gradients, texture overlays | CSS gradients | Rendered by browser |
| **Assets** | Marketing images, screenshots (Phase 2) | URL references or SVG | Lazy-loaded with `loading="lazy"` |

---

## 1. ICON SYSTEM (CSS-Based)

Instead of image files, icons are rendered as **CSS shapes + gradients**.

### Icon Patterns

```css
/* Integration Category Icons (CSS-only, no files) */

.icon {
  display: inline-block;
  width: 24px;
  height: 24px;
  border-radius: 6px;
  background: linear-gradient(135deg, var(--accent), var(--accent-soft));
  position: relative;
}

/* Category-specific icons use ::before/::after for visual distinction */

.icon.messaging::before {
  content: "✉"; /* Email symbol for messaging */
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--bg-1);
  font-weight: bold;
}

.icon.data::before {
  content: "⊡"; /* Grid for data */
}

.icon.ops::before {
  content: "⚙"; /* Gear for operations */
}

.icon.finance::before {
  content: "💰"; /* Money for finance */
}

.icon.devtools::before {
  content: "◇"; /* Diamond for devtools */
}

.icon.ai::before {
  content: "⚡"; /* Lightning for AI */
}

.icon.docs::before {
  content: "📄"; /* Document for docs */
}

/* Hover: Icon rotates + glows */
.icon:hover {
  animation: iconRotate 0.6s ease-out;
  filter: drop-shadow(0 0 12px var(--accent));
}

@keyframes iconRotate {
  from { transform: rotate(0deg) scale(1); }
  to { transform: rotate(360deg) scale(1.1); }
}
```

### Node Kind Badges (Visual Indicators)

```css
/* Each node kind gets a left border + background tint */

.node.trigger {
  border-left: 4px solid rgba(255, 190, 120, 0.8);
  background: linear-gradient(90deg, 
    rgba(255, 190, 120, 0.1), 
    rgba(0, 0, 0, 0));
}

.node.action {
  border-left: 4px solid rgba(120, 255, 210, 0.8);
  background: linear-gradient(90deg, 
    rgba(120, 255, 210, 0.1), 
    rgba(0, 0, 0, 0));
}

.node.filter {
  border-left: 4px solid rgba(255, 255, 255, 0.4);
  background: linear-gradient(90deg, 
    rgba(255, 255, 255, 0.05), 
    rgba(0, 0, 0, 0));
}

.node.decision {
  border-left: 4px solid rgba(255, 255, 255, 0.4);
  background: linear-gradient(90deg, 
    rgba(255, 255, 255, 0.05), 
    rgba(0, 0, 0, 0));
}

.node.transform {
  border-left: 4px solid rgba(140, 200, 255, 0.8);
  background: linear-gradient(90deg, 
    rgba(140, 200, 255, 0.1), 
    rgba(0, 0, 0, 0));
}

.node.delay {
  border-left: 4px solid rgba(140, 200, 255, 0.8);
  background: linear-gradient(90deg, 
    rgba(140, 200, 255, 0.1), 
    rgba(0, 0, 0, 0));
}
```

---

## 2. BACKGROUND IMAGES (Gradient Overlays)

### Theme-Aware Gradient System

The studio background uses **layered gradients** to create depth without image files.

```css
body {
  /* Base layer: Dark gradient foundation */
  background: linear-gradient(135deg, 
    var(--bg-1) 0%, 
    var(--bg-2) 100%);

  /* Accent layer 1: Warm glow (top-left) */
  background-image: 
    radial-gradient(circle at 20% 20%, 
      rgba(255, 200, 120, 0.18), 
      transparent 45%);

  /* Accent layer 2: Cool glow (bottom-right) */
  background-image: 
    radial-gradient(circle at 80% 60%, 
      rgba(60, 240, 220, 0.15), 
      transparent 35%);

  background-size: 100% 100%;
  background-attachment: fixed;
}

/* Hero background: Enhanced gradient with shimmer */
.hero {
  background: linear-gradient(135deg,
    rgba(0, 0, 0, 0.3) 0%,
    rgba(0, 0, 0, 0.1) 100%);
  
  /* Overlay: Subtle noise texture (CSS-only, no image file) */
  position: relative;
}

.hero::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image: 
    radial-gradient(circle at 100% 100%, 
      rgba(255, 255, 255, 0.1), 
      transparent 50%);
  border-radius: inherit;
}
```

### Theme Color Injection

Each theme preset defines colors used in these gradients:

```swift
public struct StudioTheme {
  let accent: String        // Primary brand color (used in gradients)
  let accentSoft: String    // Lighter accent (used in shadows)
  let background: String    // Dark base
  let backgroundAlt: String // Medium dark
  let foreground: String    // Text color
  let highlight: String     // Bright accent (used in glows)
}
```

CSS receives these via `:root` variables:

```css
:root {
  --bg-1: var(--theme-background);
  --bg-2: var(--theme-backgroundAlt);
  --text: var(--theme-foreground);
  --accent: var(--theme-accent);
  --accent-soft: var(--theme-accentSoft);
  --highlight: var(--theme-highlight);
}
```

---

## 3. ASSET IMAGES (Lazy Loading, Phase 2+)

For screenshots, marketing images, or custom illustrations (Phase 2):

```html
<!-- SVG images (preferred for icons + illustrations) -->
<svg class="flow-diagram" viewBox="0 0 400 200">
  <!-- Inline SVG content -->
</svg>

<!-- Raster images with lazy loading -->
<img 
  src="/assets/screenshot-flow.png" 
  alt="Automation flow visualization"
  loading="lazy"
  class="screenshot-img"
  width="800"
  height="600"
/>
```

```css
/* Responsive image sizing */
.screenshot-img {
  width: 100%;
  height: auto;
  max-width: 800px;
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.15);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.35);
  animation: fadeUp 0.8s ease-out;
}

/* SVG images: Theme-aware stroke/fill */
.flow-diagram {
  width: 100%;
  height: auto;
  max-width: 600px;
}

.flow-diagram path {
  stroke: var(--accent-soft);
  stroke-width: 2;
  fill: none;
}

.flow-diagram circle {
  fill: var(--accent);
  opacity: 0.8;
}
```

---

## 4. FAVICON & SOCIAL METADATA

```html
<!-- Favicon (SVG, theme-aware) -->
<link 
  rel="icon" 
  type="image/svg+xml" 
  href="data:image/svg+xml,
    <svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'>
      <circle cx='50' cy='50' r='40' fill='%23ff8a5b'/>
      <text x='50' y='55' text-anchor='middle' font-size='60' fill='white' font-weight='bold'>A</text>
    </svg>"
/>

<!-- Open Graph (social media) -->
<meta property="og:title" content="Integrations & Automations Studio" />
<meta property="og:description" content="A playful control room for stitching apps into cinematic automations." />
<meta property="og:image" content="data:image/svg+xml,..." />
<meta property="og:url" content="https://your-domain.com/studio" />
```

---

## 5. RESPONSIVE IMAGE BREAKPOINTS

### Desktop (1024px+)
- Integration cards: 3 columns, full-size images
- Flow nodes: Horizontal scroll, images visible
- Background: Dual-gradient with blur

### Tablet (720px - 1023px)
- Integration cards: 2 columns
- Flow nodes: Horizontal scroll (smaller)
- Background: Simplified gradient (less blur)

### Mobile (< 720px)
- Integration cards: 1 column, full-width
- Flow nodes: Vertical stack, images smaller
- Background: Base gradient only (no extra blur)

```css
@media (max-width: 1024px) {
  .grid {
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  }
  
  body::before {
    filter: blur(6px); /* Reduce blur on smaller screens */
  }
}

@media (max-width: 720px) {
  .grid {
    grid-template-columns: 1fr;
  }
  
  body::before {
    filter: blur(3px); /* Minimal blur on mobile */
  }
}
```

---

## 6. PERFORMANCE OPTIMIZATION

### Image Strategies

| Strategy | When to Use | Benefit |
|----------|------------|---------|
| **CSS Gradients** | Backgrounds, simple shapes | 0 HTTP requests, theme-aware |
| **SVG Inline** | Icons, diagrams, illustrations | Scalable, theme-colorable, small size |
| **Base64 Encoding** | Small icons/logos | No external requests |
| **WebP with JPEG fallback** | Photographs/screenshots | Modern format with fallback |
| **Lazy Loading** | Below-fold assets | Deferred loading, faster page load |

### Lazy Loading Implementation

```html
<!-- Images below fold use loading="lazy" -->
<img 
  src="/assets/detailed-flow.png" 
  alt="Detailed flow diagram"
  loading="lazy"
  width="800"
  height="600"
/>

<!-- Critical images (hero) load immediately -->
<img 
  src="/assets/hero-illustration.svg" 
  alt="Hero visual"
  loading="eager" <!-- or omit (defaults to eager) -->
/>
```

### CSS Containment (Prevents reflows)

```css
.card, .flow, .bench {
  contain: layout style paint; /* Isolate paint context */
}

.node-row {
  contain: layout style; /* Prevent layout thrashing on scroll */
}
```

---

## 7. ACCESSIBILITY (Alt Text & ARIA)

All images must have meaningful alt text or ARIA labels:

```html
<!-- Icons with aria-label -->
<span class="icon messaging" aria-label="Messaging integration"></span>

<!-- Images with alt text -->
<img 
  src="/assets/flow-diagram.svg" 
  alt="Automation flow showing trigger → filter → action sequence"
/>

<!-- Decorative images with empty alt -->
<img 
  src="/assets/decorative-circle.svg" 
  alt="" <!-- Decorative, skip screen reader -->
  aria-hidden="true"
/>
```

---

## 8. THEME-AWARE IMAGE COLORING

Some SVG images can be recolored via CSS:

```html
<svg class="icon-dynamic" viewBox="0 0 24 24">
  <path d="..." class="icon-stroke"/>
  <circle cx="12" cy="12" r="4" class="icon-fill"/>
</svg>
```

```css
.icon-dynamic .icon-stroke {
  stroke: var(--accent);
  stroke-width: 2;
  fill: none;
}

.icon-dynamic .icon-fill {
  fill: var(--highlight);
}

/* Dark theme variant */
@media (prefers-color-scheme: dark) {
  .icon-dynamic .icon-stroke {
    stroke: var(--accent-soft);
  }
}
```

---

## 9. CURRENT STATUS

### Implemented (Phase 1)
✅ CSS gradient backgrounds  
✅ Theme color variables  
✅ Icon badges by node kind  
✅ Responsive image breakpoints  
✅ Hero + section styling  

### Deferred (Phase 2+)
🔲 Custom SVG illustrations  
🔲 Screenshot/asset library  
🔲 Animation overlays on images  
🔲 Image upload/management UI  
🔲 Dynamic asset generation  

---

## 10. ADDING IMAGES TO THE STUDIO

### When You Need an Image:

1. **Is it an icon or badge?** → Use CSS `.icon` + `::before` pattern
2. **Is it a background?** → Use CSS gradient with theme colors
3. **Is it a screenshot/asset?** → Use `<img loading="lazy">` with alt text
4. **Is it a diagram?** → Use inline `<svg>` with CSS styling

### Example: Adding a New Integration Icon

```swift
// In Integrations_and_automations.swift, update the Integration card rendering:

// Instead of:
// <p class="eyebrow">\(htmlEscape(integration.category.label))</p>

// Do:
// <span class="icon \(integration.category.rawValue)" aria-label="\(integration.category.label)"></span>
// <p class="eyebrow">\(htmlEscape(integration.category.label))</p>
```

Then add CSS:

```css
.card .icon {
  margin-right: 8px;
  vertical-align: middle;
}
```

---

## 11. QUICK CHECKLIST

When adding images:
```
□ Is this CSS-first? (gradients, shapes, SVG)
□ Does it use theme colors? (--accent, --highlight)
□ Is it responsive? (different sizes per breakpoint)
□ Does it have alt text or aria-label?
□ Does it load lazily if below fold?
□ Did you test on light + dark themes?
→ If ALL ✓, you're good to commit.
```

---

## 12. THEME COLOR REFERENCE

### Copper Tide (Warm + Industrial)
```
Accent:      #ff8a5b (warm orange)
Accent-Soft: #ffb089 (light orange)
Highlight:   #ffd6a8 (cream)
Background:  #0c1a1f (dark blue-black)
Background-Alt: #14262e (medium dark)
Foreground:  #f3f2ea (off-white)
```

### Mint Voltage (Sharp + Energetic)
```
Accent:      #2cead3 (cyan-green)
Accent-Soft: #97f2e7 (light cyan)
Highlight:   #b6fff5 (bright cyan)
Background:  #081b20 (dark teal)
Background-Alt: #0f2c33 (medium teal)
Foreground:  #e7fbf8 (off-white)
```

### Solar Drift (Warm + Mellow)
```
Accent:      #ffcc4d (bright yellow)
Accent-Soft: #ffe7a3 (light yellow)
Highlight:   #ffe9c2 (pale yellow)
Background:  #1c1410 (dark brown)
Background-Alt: #2b1b12 (medium brown)
Foreground:  #fff5e3 (off-white)
```

---

## RESOURCES

- [MDN: CSS Gradients](https://developer.mozilla.org/en-US/docs/Web/CSS/gradient)
- [MDN: SVG Styling](https://developer.mozilla.org/en-US/docs/Web/SVG/Styling_SVG)
- [Web Performance: Image Optimization](https://web.dev/image-optimization/)
- [Accessible Images](https://www.w3.org/WAI/tutorials/images/)

---

**Last Updated:** January 11, 2026  
**Status:** PHASE 1 - CSS-only image system complete  
**Next:** Phase 2 will add custom illustrations and screenshot library

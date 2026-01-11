# DESIGN PROMPTS FOR RADICAL FRONTEND ITERATIONS
## Hyper-Focused Unconventional Design System

**Purpose:** These prompts guide future design decisions away from normality toward theatrical, intentional, cinematic interfaces.

---

## PROMPT SET A: "BREAK THE GRID"

### A1: Asymmetric Layout Experiment
**Prompt:** "The hero section should NOT center. Align the title to the left at 8% margin. Let the tagline sit BELOW the title but indented +24px. Why? Because centered = default. Off-center = intentional. Run this test."

**Execution:**
```css
.hero {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 32px;
  /* Title on left, accent shape on right */
}

.hero h1 {
  align-self: start;
  margin-left: 8%;
  margin-right: auto;
}

.hero p {
  margin-left: 32px; /* Indent tagline */
}
```

---

### A2: Overlapping Card Sections
**Prompt:** "What if the Integration Orbit OVERLAPS the hero slightly? Like it's too eager to show itself. Negative margin-top: -12px on the grid container. The cards peek behind the hero. This breaks hierarchy but creates visual tension."

**Execution:**
```css
.section:nth-of-type(2) { /* Integration Orbit */
  margin-top: -12px;
  position: relative;
  z-index: 1;
}

.hero {
  position: relative;
  z-index: 2;
}
```

---

### A3: Staggered Column Widths
**Prompt:** "Instead of uniform columns in the Integration grid, use CSS Grid with explicit column assignments. Card 1 spans 1 column, Card 2 spans 1.2 columns, Card 3 spans 0.95 columns. Creates visual rhythm without losing alignment."

**Execution:**
```css
.grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 18px;
}

.card:nth-child(3n+1) { grid-column: span 4; }
.card:nth-child(3n+2) { grid-column: span 5; } /* Wider */
.card:nth-child(3n) { grid-column: span 3; }   /* Narrower */
```

---

## PROMPT SET B: "ANIMATION CHAOS"

### B1: Ripple Effect on Scroll
**Prompt:** "When a user scrolls to a flow card, trigger a ripple animation from its center. Large circle expands 2s, opacity fades 0→0. Use `IntersectionObserver` to detect scroll position. This rewards scrolling."

**Execution (CSS):**
```css
@keyframes ripple {
  from {
    transform: scale(0.5);
    opacity: 0.8;
  }
  to {
    transform: scale(3);
    opacity: 0;
  }
}

.flow.in-view::after {
  content: "";
  position: absolute;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: var(--accent);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  animation: ripple 2s ease-out;
}
```

### B2: Text Shimmer on Hover
**Prompt:** "Hover over any card title and a shimmer effect slides across it. From left to right, opacity 0→1→0 over 800ms. Use a linear gradient with `background-clip: text`."

**Execution:**
```css
.card:hover h3 {
  background: linear-gradient(90deg, 
    var(--text) 0%, 
    var(--highlight) 50%, 
    var(--text) 100%);
  background-size: 200% 100%;
  background-clip: text;
  -webkit-background-clip: text;
  animation: shimmer 0.8s ease-in-out;
}

@keyframes shimmer {
  from { background-position: 200% 0; }
  to { background-position: -200% 0; }
}
```

---

### B3: Staggered Metrics Pop-In
**Prompt:** "In the flow metrics section, each metric bubble pops in at slightly different times. First metric at 0ms, second at 120ms, third at 240ms. Use `animation-delay` on `span` elements."

**Execution:**
```css
.metrics span:nth-child(1) { animation-delay: 0ms; }
.metrics span:nth-child(2) { animation-delay: 120ms; }
.metrics span:nth-child(3) { animation-delay: 240ms; }

.metrics span {
  animation: popIn 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) both;
}

@keyframes popIn {
  from {
    opacity: 0;
    transform: scale(0.6) rotate(-10deg);
  }
  to {
    opacity: 1;
    transform: scale(1) rotate(0deg);
  }
}
```

---

## PROMPT SET C: "COLOR MANIPULATION"

### C1: Dynamic Border Colors by Node Kind
**Prompt:** "Right now borders are static. What if they pulse with the theme accent? `.node.trigger` border pulses between `rgba(accent, 0.4)` and `rgba(accent, 0.8)` over 3s, infinite. Creates life."

**Execution:**
```css
.node.trigger {
  border-color: rgba(255, 190, 120, 0.4);
  animation: borderPulse 3s ease-in-out infinite;
}

@keyframes borderPulse {
  0%, 100% { border-color: rgba(255, 190, 120, 0.4); }
  50% { border-color: rgba(255, 190, 120, 0.8); }
}
```

### C2: Hover-State Color Shift
**Prompt:** "Hovering over a card rotates its border color through the accent spectrum. If accent is orange, shift toward red then yellow. Use CSS `filter: hue-rotate()`."

**Execution:**
```css
.card:hover {
  filter: hue-rotate(15deg);
  transition: filter 300ms ease-out;
}

.card {
  transition: filter 300ms ease-out;
}
```

### C3: Gradient Text Headers
**Prompt:** "Section headers (h2) should use a gradient text effect. From `accent` color to `accent-soft`, left to right. `background: linear-gradient()` + `background-clip: text`."

**Execution:**
```css
.section h2 {
  background: linear-gradient(90deg, var(--accent), var(--accent-soft));
  background-clip: text;
  -webkit-background-clip: text;
  color: transparent;
}
```

---

## PROMPT SET D: "SPATIAL TRICKS"

### D1: 3D Tilt on Card Hover
**Prompt:** "Cards tilt slightly on hover using `perspective` and `rotateX`/`rotateY` based on mouse position. This is subtle (1-2 degree rotation max) but creates depth. Requires JavaScript but worth it."

**Execution (CSS for setup):**
```css
.card {
  transform-style: preserve-3d;
  perspective: 1000px;
  transition: transform 200ms ease-out;
}

/* JavaScript would apply rotateX/Y based on mouse */
```

### D2: Parallax Background on Scroll
**Prompt:** "The fixed animated background (the dashed circle + gradient blobs) should move SLOWER than scroll. `background-attachment: fixed` creates this effect naturally. Enhances cinematic feel."

**Execution:**
```css
body::before, body::after {
  background-attachment: fixed;
  /* Already applied in current code */
}
```

### D3: Floating Elements
**Prompt:** "Small accent shapes (circles, lines) float around the page, bobbing up/down slowly. Place them in pseudo-elements or SVG. Opacity 0.1-0.2. They give the interface life without distraction."

**Execution:**
```css
body::before {
  /* Already has radial gradient blobs, enhance with animation */
  animation: float 8s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(20px); }
}
```

---

## PROMPT SET E: "TYPOGRAPHIC REBELLION"

### E1: Mix Serif + Sans in Headers
**Prompt:** "Instead of all-serif or all-sans, alternate. Section names (h2) use SANS in caps. Card titles (h3) use SERIF in sentence case. This creates visual variety and guides hierarchy."

**Execution:**
```css
.section h2 {
  font-family: "Gill Sans", sans-serif;
  text-transform: uppercase;
}

.card h3, .flow h3, .bench h3 {
  font-family: "Baskerville", serif;
  text-transform: none;
}
```

### E2: Variable Font Weights on Hover
**Prompt:** "Hovering over card titles increases font-weight from 600 to 700 and adds letter-spacing +0.5px. Subtle but feels premium."

**Execution:**
```css
.card h3:hover {
  font-weight: 700;
  letter-spacing: 0.5px;
  transition: all 200ms ease-out;
}
```

### E3: Mono for Metrics
**Prompt:** "All metrics (success rate, runtime, volume) display in a monospace font. This signals 'technical data' vs. narrative text. Use `font-family: 'Monaco', monospace` for `.metrics` and `.node-meta`."

**Execution:**
```css
.metrics span,
.node-meta {
  font-family: "Monaco", "Courier New", monospace;
  font-size: 0.85rem;
}
```

---

## PROMPT SET F: "INTERACTION FEEDBACK"

### F1: Ripple Click Feedback
**Prompt:** "When clicking a card, trigger a ripple effect from cursor position. Circle expands 400ms, fades out. Use CSS `radial-gradient` on `::after` pseudo-element."

**Execution (would need JS):**
```css
.card::after {
  content: "";
  position: absolute;
  border-radius: 50%;
  transform: scale(0);
  animation: ripple 0.6s ease-out;
  background: radial-gradient(circle, var(--highlight), transparent);
  pointer-events: none;
}
```

### F2: Glow on Focus
**Prompt:** "Interactive elements (would be buttons/links in Phase 2) glow on focus. Apply `box-shadow: 0 0 20px var(--accent)` with smooth transition."

**Execution:**
```css
button, a[role="button"] {
  transition: box-shadow 200ms ease-out;
}

button:focus, a[role="button"]:focus {
  box-shadow: 0 0 20px var(--accent), 0 0 40px var(--accent);
  outline: none;
}
```

---

## PROMPT SET G: "MOBILE RADICAL TRANSFORMATIONS"

### G1: Full-Height Mobile Flow View
**Prompt:** "On mobile (<720px), flows should stack full-height vertically. Node row VERTICAL (grid-auto-flow: row) instead of horizontal. Nodes stack top-to-bottom with '->' connectors between them (show `.connector`)."

**Execution:**
```css
@media (max-width: 720px) {
  .node-row {
    grid-auto-flow: row;
    grid-auto-columns: unset;
    gap: 8px;
  }

  .connector {
    display: block;
    text-align: center;
    color: var(--accent-soft);
    opacity: 0.6;
    font-size: 0.8rem;
  }
}
```

### G2: Full-Width Cards on Mobile
**Prompt:** "On mobile, cards become full-width with horizontal scroll disabled. Feels like native mobile app cards. `grid-template-columns: 1fr` in media query."

**Execution:**
```css
@media (max-width: 720px) {
  .grid, .bench-grid {
    grid-template-columns: 1fr;
  }

  .card, .bench {
    width: 100%;
  }
}
```

---

## PROMPT SET H: "EMERGENT DESIGN PATTERNS"

### H1: "The Signal Path" Visual
**Prompt:** "Create a subtle visual line connecting trigger → action in flows. Not a visible line, but nodes have a `background: linear-gradient()` that points in flow direction. Very subtle, almost subliminal."

### H2: "Workbench Depth"
**Prompt:** "Workbenches appear closer to user than flows. Increase z-index, slightly larger shadows, slightly brighter borders. They 'float' in front of flows."

### H3: "Integration Personality"
**Prompt:** "Each integration gets a unique subtle gradient background (slightly different hue per category). Messaging → warm, Data → cool, AI → cyan. Makes catalog visually scannable at a glance."

---

## PROMPT SET I: "PERFORMANCE OPTIMIZATIONS"

### I1: Lazy Load Animations
**Prompt:** "Don't animate elements that aren't visible. Use `IntersectionObserver` to trigger `fadeUp` animations only when elements enter viewport. Saves CPU, feels snappier."

### I2: GPU-Accelerated Transforms
**Prompt:** "All animations use `transform` and `opacity` (GPU-accelerated properties) never `left`/`top`/`width`. Already done in current code, but verify all hover states use `transform`."

### I3: Debounce Scroll Events
**Prompt:** "If adding scroll-based effects, debounce with `requestAnimationFrame` to prevent jank. Max 60fps, not 1000fps event fires."

---

## PROMPT SET J: "EASTER EGGS & DELIGHT"

### J1: Hidden Constellation
**Prompt:** "If user hovers over 3 cards in sequence (random), a subtle SVG constellation appears briefly in top-right corner, then fades. Reward for exploration."

### J2: Color Breathing
**Prompt:** "The background gradient colors slowly shift hue over 20 seconds (infinite loop). Very subtle—like the interface is breathing. Uses CSS animation on `:root` variables."

### J3: Random Theme on Reload
**Prompt:** "If no theme is persisted, randomly pick from the 3 theme presets each page load. Users see a different aesthetic each time they refresh. Encourages repeated visits."

---

## SUMMARY: DESIGN SYSTEM PILLARS

| Pillar | Principle | Example |
|--------|-----------|---------|
| **Asymmetry** | Break centered layouts | Off-center hero, overlapping sections |
| **Motion** | Choreograph every entry | Staggered fadeUp animations |
| **Color** | Semantic + theatrical | Node borders by kind, theme gradients |
| **Depth** | Layers and floating | Box-shadows, z-index, parallax |
| **Typography** | Serif + Sans contrast | Serif headers, mono metrics |
| **Interactivity** | Feedback on every interaction | Ripple, glow, tilt, shimmer |
| **Responsiveness** | Radical transformation, not scaling | Mobile flows vertical, full-width cards |

---

## NEXT STEPS FOR DESIGN ITERATION

1. **Pick 2-3 prompts from sets A-C** that resonate with you
2. **Implement them in the HTML/CSS**
3. **Test on dark + light backgrounds**
4. **Get feedback** on whether they enhance or distract
5. **Keep what works, discard what doesn't**
6. **Document decisions** in this file

---

## HOW TO READ THESE PROMPTS

Each prompt is a **design experiment**, not a mandate. They're options. Some will feel right. Some will feel like over-design.

**The goal:** Push your thinking beyond "normal dashboard" into "intentional theatrical interface." Even if you reject 90% of these prompts, the 10% you keep will be gold.

---

**Last Updated:** January 11, 2026  
**Status:** DESIGN EXPLORATION GUIDE  
**Next:** Implement, test, iterate, keep what resonates.

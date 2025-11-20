# Pulse Intelligence Design System

**Version:** 1.0
**Last Updated:** November 20, 2025
**Purpose:** Complete design scheme documentation for creating a consistent and cohesive application-wide design system

---

## Table of Contents
1. [Color Palette](#color-palette)
2. [Typography](#typography)
3. [Spacing System](#spacing-system)
4. [Shadows](#shadows)
5. [Border Radius](#border-radius)
6. [Components](#components)
7. [Icons](#icons)
8. [Animations & Transitions](#animations--transitions)
9. [Breakpoints](#breakpoints)
10. [Z-Index Scale](#z-index-scale)
11. [Design Tokens](#design-tokens)

---

## Color Palette

### Brand Colors

#### Primary Brand Color
```css
--primary: 94 83% 54%           /* HSL */
Hex: #7C3AED                    /* Vivid Purple */
RGB: rgb(124, 58, 237)
Usage: Primary actions, links, focus states, brand elements
```

**Alternative Purple Shades in Components:**
- `#6D28D9` - Used in buttons (darker purple)
- `#5B21B6` - Hover state for buttons

### Semantic Color System

#### Light Mode
```css
/* Background & Foreground */
--background: 220 13% 97%       /* #F8FAFC - Very light blue-gray */
--foreground: 222 47% 11%       /* #1E293B - Dark slate */

/* Cards & Surfaces */
--card: 0 0% 100%               /* #FFFFFF - Pure white */
--card-foreground: 222 47% 11%  /* #1E293B - Dark slate */

/* Popovers */
--popover: 0 0% 100%            /* #FFFFFF - Pure white */
--popover-foreground: 222 47% 11% /* #1E293B - Dark slate */

/* Secondary */
--secondary: 240 5% 96%         /* #F1F5F9 - Light gray */
--secondary-foreground: 240 10% 3.9% /* #09090B - Near black */

/* Muted (for less emphasis) */
--muted: 240 5% 96%             /* #F1F5F9 - Light gray */
--muted-foreground: 215 28% 44% /* #475569 - Medium gray */

/* Accent */
--accent: 240 5% 96%            /* #F1F5F9 - Light gray */
--accent-foreground: 240 10% 3.9% /* #09090B - Near black */

/* Destructive (errors, danger) */
--destructive: 0 84% 60%        /* #EF4444 - Red */
--destructive-foreground: 0 0% 100% /* #FFFFFF - White */

/* Borders & Inputs */
--border: 214 32% 91%           /* #E2E8F0 - Light blue-gray */
--input: 214 32% 91%            /* #E2E8F0 - Light blue-gray */
--ring: 94 83% 54%              /* #7C3AED - Primary purple (focus rings) */
```

#### Dark Mode
```css
/* Background & Foreground */
--background: 222 47% 11%       /* #1E293B - Dark slate */
--foreground: 210 40% 98%       /* #F8FAFC - Very light */

/* Cards & Surfaces */
--card: 222 47% 11%             /* #1E293B - Dark slate */
--card-foreground: 210 40% 98%  /* #F8FAFC - Very light */

/* Popovers */
--popover: 222 47% 11%          /* #1E293B - Dark slate */
--popover-foreground: 210 40% 98% /* #F8FAFC - Very light */

/* Secondary */
--secondary: 217 33% 17%        /* Darker slate */
--secondary-foreground: 210 40% 98% /* #F8FAFC - Very light */

/* Muted */
--muted: 217 33% 17%            /* Darker slate */
--muted-foreground: 215 20% 65% /* #94A3B8 - Medium gray */

/* Accent */
--accent: 217 33% 17%           /* Darker slate */
--accent-foreground: 210 40% 98% /* #F8FAFC - Very light */

/* Destructive */
--destructive: 0 63% 31%        /* Darker red */
--destructive-foreground: 210 40% 98% /* #F8FAFC - Very light */

/* Borders & Inputs */
--border: 217 33% 17%           /* Darker slate */
--input: 217 33% 17%            /* Darker slate */
--ring: 94 83% 54%              /* #7C3AED - Primary purple */
```

### Sidebar Colors

#### Light Mode
```css
--sidebar-background: 0 0% 98%  /* Very light gray */
--sidebar-foreground: 240 5.3% 26.1% /* Dark gray */
--sidebar-primary: 240 5.9% 10% /* Near black */
--sidebar-primary-foreground: 0 0% 98% /* Very light gray */
--sidebar-accent: 240 4.8% 95.9% /* Light gray */
--sidebar-accent-foreground: 240 5.9% 10% /* Near black */
--sidebar-border: 220 13% 91%   /* Light blue-gray */
--sidebar-ring: 217.2 91.2% 59.8% /* Bright blue */
```

#### Dark Mode
```css
--sidebar-background: 240 5.9% 10% /* Very dark */
--sidebar-foreground: 240 4.8% 95.9% /* Very light */
--sidebar-primary: 224.3 76.3% 48% /* Blue */
--sidebar-primary-foreground: 0 0% 100% /* White */
--sidebar-accent: 240 3.7% 15.9% /* Dark gray */
--sidebar-accent-foreground: 240 4.8% 95.9% /* Very light */
--sidebar-border: 240 3.7% 15.9% /* Dark gray */
--sidebar-ring: 217.2 91.2% 59.8% /* Bright blue */
```

### Chart Colors

#### Light Mode
```css
--chart-1: 12 76% 61%           /* Coral/Orange */
--chart-2: 173 58% 39%          /* Teal */
--chart-3: 197 37% 24%          /* Dark blue */
--chart-4: 43 74% 66%           /* Yellow */
--chart-5: 27 87% 67%           /* Orange */
```

#### Dark Mode
```css
--chart-1: 220 70% 50%          /* Blue */
--chart-2: 160 60% 45%          /* Green */
--chart-3: 30 80% 55%           /* Orange */
--chart-4: 280 65% 60%          /* Purple */
--chart-5: 340 75% 55%          /* Pink */
```

### Additional Component Colors
```css
/* Badge Secondary */
Background: #F8FAFC
Text: #475569
Border: #E2E8F0

/* Badge Destructive */
Background: #EF4444
Text: #FFFFFF

/* Text Colors (common usage) */
text-violet-600              /* Links, primary text accents */
text-muted-foreground        /* Secondary text, labels */
```

---

## Typography

### Font Family
```css
/* System Font Stack (Tailwind Default) */
font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
             "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans",
             sans-serif, "Apple Color Emoji", "Segoe UI Emoji",
             "Segoe UI Symbol", "Noto Color Emoji";
```

### Font Weights
```css
font-medium: 500       /* Labels, regular emphasis */
font-semibold: 600     /* Headings, strong emphasis */
font-bold: 700         /* Heavy emphasis, titles */
```

### Font Sizes (Tailwind Scale)
```css
text-xs: 0.75rem       /* 12px - Small labels, captions */
text-sm: 0.875rem      /* 14px - Body text, inputs, buttons */
text-base: 1rem        /* 16px - Default body text */
text-lg: 1.125rem      /* 18px - Large body text, subheadings */
text-xl: 1.25rem       /* 20px - Headings */
text-2xl: 1.5rem       /* 24px - Large headings */
text-3xl: 1.875rem     /* 30px - Display text */
text-4xl: 2.25rem      /* 36px - Large display text */
```

### Line Heights
```css
leading-none: 1
leading-tight: 1.25
leading-snug: 1.375
leading-normal: 1.5
leading-relaxed: 1.625
leading-loose: 2
```

### Common Typography Patterns
```css
/* Labels */
text-sm font-medium

/* Headings */
text-lg font-semibold

/* Subheadings */
text-base font-semibold

/* Body Text */
text-sm

/* Secondary/Muted Text */
text-sm text-muted-foreground

/* Button Text */
text-sm font-medium

/* Badge Text */
text-xs font-medium
```

---

## Spacing System

### Tailwind Spacing Scale
```css
0: 0px
0.5: 0.125rem    /* 2px */
1: 0.25rem       /* 4px */
1.5: 0.375rem    /* 6px */
2: 0.5rem        /* 8px */
2.5: 0.625rem    /* 10px */
3: 0.75rem       /* 12px */
3.5: 0.875rem    /* 14px */
4: 1rem          /* 16px */
5: 1.25rem       /* 20px */
6: 1.5rem        /* 24px */
8: 2rem          /* 32px */
10: 2.5rem       /* 40px */
12: 3rem         /* 48px */
16: 4rem         /* 64px */
20: 5rem         /* 80px */
24: 6rem         /* 96px */
```

### Common Spacing Patterns
```css
/* Card Padding */
p-6                 /* 24px - Standard card padding */

/* Component Gaps */
gap-2               /* 8px - Small gaps between elements */
gap-3               /* 12px - Medium gaps */
gap-4               /* 16px - Large gaps */

/* Button Padding */
px-4 py-2          /* Default button (16px horizontal, 8px vertical) */
px-3               /* Small button (12px) */
px-8               /* Large button (32px) */

/* Section Spacing */
space-y-4          /* 16px vertical spacing between children */
space-y-6          /* 24px vertical spacing */

/* Container Padding */
padding: 2rem      /* From tailwind.config.ts container */

/* Sidebar Width */
Desktop: 16rem     /* 256px */
Mobile: 18rem      /* 288px */
```

---

## Shadows

### Tailwind Shadow Scale
```css
shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05)
shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1),
        0 1px 2px -1px rgb(0 0 0 / 0.1)
shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1),
           0 2px 4px -2px rgb(0 0 0 / 0.1)
shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1),
           0 4px 6px -4px rgb(0 0 0 / 0.1)
shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1),
           0 8px 10px -6px rgb(0 0 0 / 0.1)
shadow-2xl: 0 25px 50px -12px rgb(0 0 0 / 0.25)
shadow-none: 0 0 #0000
```

### Usage Patterns
```css
/* Cards */
shadow-sm           /* Subtle card elevation */

/* Popovers & Dropdowns */
shadow-lg           /* Medium elevation */

/* Modals & Dialogs */
shadow-2xl          /* High elevation */

/* Custom Shadow (found in codebase) */
shadow-[2px_2px_20px_0px_#707070AD]  /* Custom shadow variation */
```

---

## Border Radius

### Base Radius
```css
--radius: 0.5rem    /* 8px - Base border radius */
```

### Radius Scale
```css
rounded-sm: calc(var(--radius) - 4px)  /* 4px / 0.25rem */
rounded-md: calc(var(--radius) - 2px)  /* 6px / 0.375rem */
rounded-lg: var(--radius)              /* 8px / 0.5rem */
rounded-xl: 0.75rem                    /* 12px */
rounded-2xl: 1rem                      /* 16px */
rounded-3xl: 1.5rem                    /* 24px */
rounded-full: 9999px                   /* Full circle */
```

### Common Usage
```css
/* Buttons & Inputs */
rounded-md          /* 6px - Standard for most interactive elements */

/* Cards */
rounded-lg          /* 8px */

/* Badges */
rounded-md          /* 6px */

/* Avatars */
rounded-full        /* Circular */

/* Responsive Pattern */
rounded-lg sm:rounded-lg  /* 8px on all screens */
```

---

## Components

### UI Component Library

**Framework:** Radix UI + Tailwind CSS
**Utility:** class-variance-authority (CVA) for variants
**Location:** `/src/components/ui/`

#### Core Components (60+ total)

**Layout & Structure:**
- Card
- Accordion
- Tabs
- Table
- Separator
- Scroll Area
- Resizable Panels

**Forms & Inputs:**
- Button
- Input
- Textarea
- Label
- Checkbox
- Radio Group
- Switch
- Slider
- Select
- OTP Input

**Navigation:**
- Breadcrumb
- Menubar
- Navigation Menu
- Pagination
- Sidebar

**Feedback:**
- Alert
- Badge
- Progress
- Toast (Sonner)
- Loading Indicator
- AI Typing Indicator

**Overlays:**
- Dialog
- Alert Dialog
- Drawer
- Sheet
- Popover
- Hover Card
- Tooltip
- Dropdown Menu
- Context Menu

**Display:**
- Avatar
- Aspect Ratio
- Carousel (Embla)

### Button Component

**Variants:**
```css
default: bg-[#6D28D9] text-white hover:bg-[#5B21B6]
destructive: bg-destructive text-destructive-foreground hover:bg-destructive/90
destructive-outline: border border-destructive bg-transparent text-destructive hover:bg-destructive/10
outline: border border-border bg-transparent text-violet-600 hover:bg-accent
secondary: bg-secondary text-secondary-foreground hover:bg-secondary/80
ghost: text-text-body hover:bg-accent hover:text-text-title
link: text-violet-600 underline-offset-4 hover:underline
```

**Sizes:**
```css
default: h-10 px-4 py-2       /* Height: 40px, Padding: 16px 8px */
sm: h-9 rounded-md px-3       /* Height: 36px, Padding: 12px */
lg: h-11 rounded-md px-8      /* Height: 44px, Padding: 32px */
icon: h-10 w-10               /* Square: 40px × 40px */
```

**Base Styles:**
```css
inline-flex items-center justify-center gap-2
whitespace-nowrap rounded-md text-sm font-medium
transition-colors
focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2
disabled:pointer-events-none disabled:opacity-50
[&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0
```

### Badge Component

**Variants:**
```css
default: bg-[#6D28D9] text-white border-transparent
secondary: bg-[#F8FAFC] text-[#475569] border-[#E2E8F0]
destructive: bg-[#EF4444] text-white border-transparent
outline: text-[#475569] border-[#E2E8F0]
```

**Base Styles:**
```css
inline-flex items-center rounded-md border
px-2.5 py-0.5 text-xs font-medium
transition-colors
focus:outline-none focus:ring-0
```

### Card Component Pattern
```css
/* Card Container */
rounded-lg border bg-card text-card-foreground shadow-sm

/* Card Header */
flex flex-col space-y-1.5 p-6

/* Card Title */
text-2xl font-semibold leading-none tracking-tight

/* Card Content */
p-6 pt-0
```

---

## Icons

### Icon Library

**Primary:** Lucide React v0.475.0
**Installation:** `lucide-react`

### Commonly Used Icons
```javascript
// Navigation
ChevronDown, ChevronLeft, ChevronRight, ChevronUp
PanelLeft, Menu, X

// Actions
Check, Plus, Minus, Search, Filter
Upload, Download, Edit, Trash2, Save

// Status
AlertCircle, CheckCircle, XCircle, Info
Bell, BellOff

// UI
GripVertical, MoreVertical, MoreHorizontal
Settings, User, LogOut

// Content
File, Folder, Image, FileText
Calendar, Clock, Mail
```

### Custom Icons
```javascript
// Location: /src/components/ui/
BrainIcon       /* Custom AI/brain visualization */
```

### Icon Sizing Pattern
```css
/* Default (in buttons) */
size-4          /* 16px × 16px */

/* Sizes */
size-3          /* 12px × 12px - Extra small */
size-4          /* 16px × 16px - Default */
size-5          /* 20px × 20px - Medium */
size-6          /* 24px × 24px - Large */
size-8          /* 32px × 32px - Extra large */

/* SVG Classes */
[&_svg]:size-4 [&_svg]:shrink-0 [&_svg]:pointer-events-none
```

---

## Animations & Transitions

### Animation Library
**Package:** tailwindcss-animate
**Additional:** Framer Motion v12.4.7 (installed but minimal usage)

### Transition Durations
```css
duration-100: 100ms
duration-150: 150ms
duration-200: 200ms    /* Most common */
duration-300: 300ms
duration-500: 500ms
duration-700: 700ms
duration-1000: 1000ms
```

### Transition Timing Functions
```css
ease-linear
ease-in
ease-out          /* Most common */
ease-in-out
```

### Common Animation Patterns
```css
/* Standard Transition */
transition-colors  /* Color changes */
transition-all     /* All properties */
transition-transform

/* Hover States */
hover:bg-accent
hover:text-accent-foreground
hover:scale-105
```

### Custom Keyframes
```javascript
// From tailwind.config.ts
accordion-down: {
  from: { height: "0" },
  to: { height: "var(--radix-accordion-content-height)" }
}

accordion-up: {
  from: { height: "var(--radix-accordion-content-height)" },
  to: { height: "0" }
}
```

### Animation Classes
```css
/* Built-in Tailwind */
animate-spin       /* Loading spinners */
animate-pulse      /* Subtle pulsing */
animate-bounce     /* Attention grabbing */

/* Custom */
animate-accordion-down    /* 0.2s ease-out */
animate-accordion-up      /* 0.2s ease-out */
```

### Radix UI Animation Patterns
```css
/* Enter Animations */
data-[state=open]:animate-in
data-[state=closed]:animate-out

/* Fade */
fade-in-0
fade-out-0
fade-in-50
fade-out-80

/* Zoom */
zoom-in-95
zoom-out-95

/* Slide */
slide-in-from-top-2
slide-in-from-bottom-2
slide-in-from-left-2
slide-in-from-right-2
```

---

## Breakpoints

### Responsive Breakpoints (Tailwind Default)
```css
/* Mobile First Approach */
sm: 640px         /* Small devices (landscape phones) */
md: 768px         /* Medium devices (tablets) */
lg: 1024px        /* Large devices (laptops) */
xl: 1280px        /* Extra large devices (desktops) */
2xl: 1536px       /* 2X extra large devices (large desktops) */
```

### Container Configuration
```javascript
// From tailwind.config.ts
container: {
  center: true,
  padding: "2rem",
  screens: {
    "2xl": "1400px"
  }
}
```

### Common Responsive Patterns
```css
/* Hide/Show */
hidden md:block          /* Hidden on mobile, shown on tablet+ */
md:hidden                /* Hidden on tablet+ */

/* Sizing */
w-full md:w-1/2         /* Full width on mobile, half on tablet+ */

/* Spacing */
p-4 md:p-6              /* 16px on mobile, 24px on tablet+ */

/* Layout */
flex-col md:flex-row    /* Column on mobile, row on tablet+ */

/* Text */
text-sm md:text-base    /* Smaller text on mobile */

/* Grid */
grid-cols-1 md:grid-cols-2 lg:grid-cols-3

/* Sidebar Breakpoint */
md                      /* Toggle between mobile sheet and desktop sidebar */
```

---

## Z-Index Scale

### Layering System
```css
z-0: 0               /* Default layer */
z-10: 10             /* Sidebar background */
z-20: 20             /* Sidebar resizable handle */
z-30: 30
z-40: 40             /* Mobile navigation */
z-50: 50             /* Modals, dialogs, dropdowns, popovers, tooltips */
z-[100]: 100         /* Toast notifications (top layer) */
```

### Component Z-Index Usage
```css
/* Sidebar */
z-10                 /* Background */
z-20                 /* Resizable handle */

/* Navigation */
z-40                 /* Mobile nav */

/* Overlays (Primary Interactive Layer) */
z-50                 /* Dialogs, Popovers, Dropdowns, Tooltips, Sheets */

/* Notifications (Top Layer) */
z-[100]              /* Toast notifications */
```

---

## Design Tokens

### Configuration Files

**Primary Config:** `/tailwind.config.ts`
**Global Styles:** `/app/globals.css`
**Utility Function:** `/lib/utils.js` (cn() for class merging)

### CSS Custom Properties Usage
```javascript
// Pattern in Tailwind Config
colors: {
  border: "hsl(var(--border))",
  input: "hsl(var(--input))",
  ring: "hsl(var(--ring))",
  background: "hsl(var(--background))",
  foreground: "hsl(var(--foreground))",
  primary: {
    DEFAULT: "hsl(var(--primary))",
    foreground: "hsl(var(--primary-foreground))",
  },
  // ... etc
}
```

### Class Name Utility
```javascript
// /lib/utils.js
import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs) {
  return twMerge(clsx(inputs))
}
```

**Usage:**
```javascript
cn(
  "base-classes",
  variantClass,
  conditionalClass && "additional-classes",
  className
)
```

---

## Package Dependencies

### Core Design & UI
```json
"tailwindcss": "^3.4.17"
"tailwindcss-animate": "^1.0.7"
"class-variance-authority": "^0.7.1"
"clsx": "^2.1.1"
"tailwind-merge": "^3.0.2"
```

### Radix UI Components (Accessibility & Headless UI)
```json
"@radix-ui/react-accordion": "^1.2.3"
"@radix-ui/react-alert-dialog": "^1.1.6"
"@radix-ui/react-avatar": "^1.1.3"
"@radix-ui/react-checkbox": "^1.1.4"
"@radix-ui/react-dialog": "^1.1.6"
"@radix-ui/react-dropdown-menu": "^2.1.6"
"@radix-ui/react-label": "^2.1.2"
"@radix-ui/react-popover": "^1.1.6"
"@radix-ui/react-progress": "^1.1.2"
"@radix-ui/react-select": "^2.1.6"
"@radix-ui/react-slider": "^1.2.3"
"@radix-ui/react-switch": "^1.1.3"
"@radix-ui/react-tabs": "^1.1.3"
"@radix-ui/react-tooltip": "^1.1.8"
// ... and more
```

### Icons & Graphics
```json
"lucide-react": "^0.475.0"
```

### Animation
```json
"framer-motion": "^12.4.7"
```

### Theming
```json
"next-themes": "^0.4.4"
```

### Toast Notifications
```json
"sonner": "^2.0.1"
```

### Other UI Utilities
```json
"embla-carousel-react": "^8.5.2"
"react-resizable-panels": "^2.1.7"
"vaul": "^1.1.2"          /* Drawer component */
"cmdk": "^1.0.0"          /* Command menu */
```

---

## Design System Inconsistencies & Recommendations

### Current Inconsistencies

1. **Mixed Color References**
   - Some components use hex codes directly (`#6D28D9`)
   - Others use CSS custom properties (`hsl(var(--primary))`)
   - **Recommendation:** Standardize to CSS custom properties for better theme support

2. **Button Purple Variations**
   - Primary uses `#7C3AED`
   - Button default uses `#6D28D9`
   - Button hover uses `#5B21B6`
   - **Recommendation:** Create a unified purple scale with -50, -100, -200... variants

3. **Custom Shadow**
   - One instance of `shadow-[2px_2px_20px_0px_#707070AD]`
   - **Recommendation:** Add to design tokens if needed consistently, otherwise remove

4. **Animation Duration Variations**
   - Mix of 100ms, 200ms, 300ms, 500ms
   - **Recommendation:** Standardize to 2-3 core durations (e.g., 150ms, 300ms, 500ms)

### Strengths

1. **Excellent HSL-based theming** enables robust dark mode support
2. **Consistent spacing scale** using Tailwind defaults
3. **Strong component library** with Radix UI providing accessibility
4. **Semantic color system** with clear naming conventions
5. **Responsive design patterns** consistently applied

---

## Implementation Guidelines

### Creating New Components

1. **Use existing design tokens** from `globals.css`
2. **Follow component patterns** in `/src/components/ui/`
3. **Use CVA** for variant management
4. **Include dark mode styles** for all color usages
5. **Apply focus states** with `focus-visible:ring-2 focus-visible:ring-ring`
6. **Use semantic colors** over hardcoded values

### Color Usage
```javascript
// ✅ Good
className="bg-primary text-primary-foreground"

// ❌ Avoid
className="bg-[#7C3AED] text-white"
```

### Spacing
```javascript
// ✅ Good - Use Tailwind scale
className="p-6 gap-4"

// ❌ Avoid - Custom values
className="p-[23px] gap-[17px]"
```

### Typography
```javascript
// ✅ Good - Consistent patterns
className="text-sm font-medium"

// ❌ Avoid - Arbitrary values
className="text-[13.5px] font-[550]"
```

---

## Future Design System Improvements

### Recommended Additions

1. **Purple Color Scale**
   ```css
   purple-50 through purple-950
   ```

2. **Typography Scale Documentation**
   - Heading hierarchy (H1-H6)
   - Body text sizes
   - Caption/label sizes

3. **Motion System**
   - Standardized easing functions
   - Duration tokens (fast, medium, slow)
   - Complex animation patterns

4. **Elevation System**
   - Formalized shadow levels (0-5)
   - Usage guidelines for each level

5. **Icon Size System**
   - Standardized sizes (xs, sm, md, lg, xl)
   - Usage context guidelines

6. **Layout Patterns**
   - Page templates
   - Section layouts
   - Grid systems

---

## Resources

**Tailwind CSS Docs:** https://tailwindcss.com
**Radix UI Docs:** https://www.radix-ui.com
**Lucide Icons:** https://lucide.dev
**CVA (Class Variance Authority):** https://cva.style

---

**Document maintained by:** Development Team
**Contact for design system questions:** [Insert contact information]
**Last reviewed:** November 20, 2025

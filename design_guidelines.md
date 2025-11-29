# Design Guidelines: Zeliang Tribe & Morung Cultural Explorer

## Design Approach

**Reference-Based**: Drawing inspiration from Airbnb's location exploration patterns, National Geographic's cultural storytelling, and modern museum digital experiences. Mobile-first with immersive, educational focus.

## Core Design Principles

1. **Cultural Reverence**: Design honors tradition while being accessible to modern audiences
2. **Mobile-First Navigation**: Touch-friendly, swipeable interactions throughout
3. **Storytelling Through Visuals**: Images and content work together to educate and inspire
4. **Layered Discovery**: Progressive disclosure from overview to deep cultural details

## Typography System

**Fonts**: 
- Primary: Inter (Google Fonts) - Clean, highly legible for body text
- Display: Playfair Display (Google Fonts) - Elegant for headings, cultural significance

**Hierarchy**:
- Hero Headlines: text-4xl to text-5xl, font-bold (Playfair Display)
- Section Headers: text-2xl to text-3xl, font-semibold (Playfair Display)
- Subsections: text-xl, font-medium (Inter)
- Body Text: text-base, font-normal, leading-relaxed (Inter)
- Captions: text-sm, font-light (Inter)

## Layout System

**Spacing Units**: Tailwind units of 4, 6, 8, 12, 16, 24 (p-4, mb-8, space-y-12, etc.)

**Container Strategy**:
- Full-width hero sections with inner max-w-7xl containers
- Content sections: max-w-6xl mx-auto
- Reading content: max-w-prose
- Mobile padding: px-4, desktop: px-6 to px-8

**Grid Patterns**:
- Village Cards: grid-cols-1 on mobile, stays single column for content depth
- Cultural Elements: 2-column grids (md:grid-cols-2) for feature highlights
- Gallery Images: Masonry-style or 2-3 column grids

## Component Library

### Navigation
- **Sticky Header**: Mobile hamburger menu with smooth slide-in drawer
- **Bottom Navigation Bar**: Fixed mobile nav with 4-5 key sections (Home, Villages, Morung, Festivals, Map)
- **Breadcrumbs**: For deep navigation within village/cultural pages

### Hero Section
- **Full-Screen Immersive**: 85vh height with overlaid content
- **Image**: Dramatic landscape of Nagaland hills or traditional Morung architecture
- **Content**: Centered text with semi-transparent backdrop blur (backdrop-blur-md, bg-black/40)
- **CTA Buttons**: Blurred backgrounds (backdrop-blur-sm bg-white/20) with clear text

### Village Explorer Cards
- **Card Structure**: Full-width cards with large images (aspect-video or aspect-[4/3])
- **Content Layout**: Image top, text content below with padding p-6
- **Distance Badge**: Absolute positioned pill showing KM from Kohima
- **Quick Info**: Icon + text pairs (location, attractions, best season)
- **Swipeable**: Horizontal scroll snap on mobile for multiple villages

### Interactive Map Section
- **Map Container**: Full-width with aspect-[16/9] on mobile
- **Village Markers**: Clickable pins that expand info cards
- **Route Visualization**: Connected path showing journey through villages

### Morung Cultural Section
- **Image Gallery**: Large hero image of Rehangki, followed by detail shots
- **Information Cards**: Accordion-style expandable sections for different aspects (Structure, Rituals, Social Role, Caretakers)
- **Cultural Glossary**: Drawer or modal with term definitions (Rehangki, Teei Peu Tei, Hangsiupui, etc.)
- **Illustrated Diagrams**: Simple line drawings showing Morung floor plan and key elements

### Festival Calendar
- **Timeline View**: Vertical timeline for mobile with festival cards
- **Festival Cards**: Date, name, location, description with featured image
- **Month Navigation**: Horizontal scroll tabs for different months

### Content Pages (Village Details)
- **Hero Image**: Full-width banner of the village (aspect-[21/9])
- **Sticky Info Bar**: Distance, elevation, best time to visit
- **Content Sections**: Attractions, History, Trekking Info in clearly divided sections with generous spacing (space-y-16)
- **Photo Grid**: 2-column grid of location photos

### Interactive Elements
- **Swipe Cards**: Horizontal scrolling for galleries and village previews (snap-x snap-mandatory)
- **Expandable Sections**: Smooth height transitions for cultural information
- **Image Lightbox**: Tap to expand images to full screen
- **Smooth Scrolling**: Between page sections

## Images

**Hero Images**:
- Homepage: Panoramic view of Nagaland hills with traditional village in valley (full-width, 85vh)
- Morung Page: Front view of traditional thatched Rehangki with spears at entrance (full-width, 70vh)

**Village Pages** (each needs):
- Landscape hero shot showing village setting
- 4-6 detail images: festivals, landscapes, landmarks, cultural activities

**Cultural Content**:
- Morung interior with fireplace and wooden bed
- Traditional crafts and artifacts
- Festival celebrations (Hega, Cosmos Festival)
- Trekking trails and mountain peaks

**Illustrations/Diagrams**:
- Morung floor plan (simple line drawing)
- Map showing village routes from Kohima

## Animations

Use sparingly and purposefully:
- **Scroll Reveal**: Subtle fade-up on content sections (intersection observer)
- **Card Hover**: Slight scale (scale-105) on village cards (desktop only)
- **Smooth Transitions**: All state changes (transition-all duration-300)
- **Page Transitions**: Fade between major sections

## Accessibility

- Touch targets minimum 44x44px for all interactive elements
- High contrast text over images (use overlays or blur backdrops)
- Clear focus states for keyboard navigation
- Alt text for all cultural and location images
- Semantic HTML throughout (nav, main, article, section)

## Mobile-Specific Patterns

- **Pull-to-Refresh**: Subtle indicator for content updates
- **Swipe Gestures**: Natural horizontal scrolling for galleries
- **Fixed Bottom Navigation**: Always accessible primary navigation
- **Collapsible Sections**: Reduce scroll length on content-heavy pages
- **Large Touch Targets**: Buttons and clickable areas at least 48px height
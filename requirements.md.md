# Zeliang Cultural Explorer

An interactive mobile-first web application showcasing the rich cultural heritage of the Zeliang tribe and the stunning villages of Peren District, Nagaland.

## Project Overview

This educational platform allows visitors to explore:
- **Seven Villages**: Poilwa, Benreu, Pedi, Peletkie, Peren, Puilwa, and Nzauna - each with unique attractions, history, and cultural significance
- **Traditional Morung (Rehangki)**: Detailed information about the traditional male dormitory and cultural training center
- **Cultural Festivals**: Hega Festival, Cosmos Festival, Milei Ngyi Festival, and traditional ceremonies
- **Cultural Glossary**: Comprehensive guide to Zeliang terms, traditions, and spiritual concepts

## Technical Stack

- **Frontend**: React 18 with TypeScript, TanStack Query for data management
- **Backend**: Express.js serving cultural content via REST API
- **Styling**: Tailwind CSS with Shadcn UI component library
- **Fonts**: Inter (body text), Playfair Display (headings)
- **Mobile-First**: Designed primarily for mobile devices with responsive layouts

## Application Structure

### Pages
- **Home** (`/`): Hero section with featured villages and festivals
- **Villages**: Browse all 7 villages with detailed information pages
- **Morung**: Learn about the traditional Rehangki with accordion sections
- **Festivals**: Explore cultural celebrations and ceremonies
- **Glossary**: Terms and concepts organized by category

### API Endpoints
- `GET /api/villages` - Returns all village data
- `GET /api/villages/:id` - Returns specific village by ID
- `GET /api/festivals` - Returns all festival information
- `GET /api/morung` - Returns Morung cultural data
- `GET /api/glossary` - Returns glossary terms with categories

### Key Components
- `Hero`: Immersive hero section with image overlay
- `VillageCard`: Card component displaying village highlights
- `VillageDetail`: Full-page village information view
- `BottomNav`: Fixed bottom navigation for mobile
- `MorungSection`: Accordion-based cultural information
- `FestivalCard`: Festival details with dates and locations
- `GlossarySheet`: Bottom drawer with cultural terms

## Data Source

All cultural content is based on official documentation about:
- Places to visit in Zeliang Area/Peren District, Nagaland
- The Zeliang Rehangki/Morung traditions and practices

Content includes historical sites, spiritual connections, festivals, and cultural practices preserved by the Zeliang community.

## Design Principles

1. **Cultural Reverence**: Design honors tradition while remaining accessible
2. **Mobile-First**: Touch-friendly interactions throughout
3. **Storytelling**: Images and content work together to educate
4. **Progressive Disclosure**: From overview to detailed cultural information

## Running the Project

The application runs on port 5000 with both frontend and backend served together.

```bash
npm run dev
```

## Color Scheme

- Primary: Green (#31A565) - representing Nagaland's lush landscapes
- Neutral backgrounds for content readability
- Dark mode support for comfortable viewing

## Last Updated

November 25, 2025 - Initial version with complete village, festival, and cultural information.

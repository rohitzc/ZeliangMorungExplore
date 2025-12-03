import { MapPin, Mountain, Calendar, ExternalLink } from "lucide-react";

interface VillageCardProps {
  name: string;
  imageSrc: string;
  distance: string;
  highlights: string[];
  bestSeason?: string;
  onClick?: () => void;
}

// Parse distance string to extract km, location, and route
function parseDistance(distance: string): { km: string; location: string; route: string } {
  // Format: "52 KM from Kohima via Khonoma-Dzulakie"
  // or: "70-75 KM from Kohima via Khonoma-Dzulakie-Poilwa-Benreu"
  // or: "25-30 KM from Peren"
  // or: "124 KM approx from Peren (southernmost part of Peren district)"
  const viaMatch = distance.match(/via\s+(.+)$/i);
  const kmMatch = distance.match(/^([\d-]+)\s*KM/i);
  
  const km = kmMatch ? `${kmMatch[1]} KM` : distance.split(' ')[0] + ' KM';
  const route = viaMatch ? viaMatch[1] : '';
  
  // Extract location: text after "from" and before " via" or "(" or end of string
  const fromMatch = distance.match(/from\s+([^(\n]+?)(?:\s+via|\(|$)/i);
  const location = fromMatch ? fromMatch[1].trim() : 'Kohima'; // Default to Kohima if not found
  
  return { km, location, route };
}

export default function VillageCard({ 
  name, 
  imageSrc, 
  distance, 
  highlights,
  bestSeason,
  onClick 
}: VillageCardProps) {
  const { km, location, route } = parseDistance(distance);
  const googleMapsUrl = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${name}, Nagaland, India`)}`;

  return (
    <div 
      className="overflow-hidden rounded-xl border bg-card border-card-border text-card-foreground shadow-sm hover-elevate active-elevate-2 cursor-pointer group"
      onClick={() => onClick?.()}
      data-testid={`card-village-${name.toLowerCase()}`}
    >
      {/* Clean image without overlays */}
      <div className="relative aspect-video w-full overflow-hidden">
        <img 
          src={imageSrc} 
          alt={name}
          className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
          loading="lazy"
          decoding="async"
        />
        {/* Subtle gradient overlay on hover for better text readability if needed */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/0 to-black/0 group-hover:from-black/5 group-hover:to-black/0 transition-all duration-300" />
      </div>
      
      <div className="p-6 space-y-4">
        {/* Village Name */}
        <h3 className="font-serif text-2xl font-semibold" data-testid={`text-village-name-${name.toLowerCase()}`}>
          {name}
        </h3>
        
        {/* Distance Information - Clean section below image */}
        <div className="flex items-start justify-between gap-4 pb-3 border-b">
          <div className="flex-1 min-w-0 space-y-1">
            <div className="flex items-center gap-2 text-sm">
              <MapPin className="h-4 w-4 text-primary flex-shrink-0" />
              <span className="font-medium text-foreground">{km} from {location}</span>
            </div>
            {route && (
              <div className="text-xs text-muted-foreground ml-6">
                via {route}
              </div>
            )}
          </div>
          <a
            href={googleMapsUrl}
            target="_blank"
            rel="noopener noreferrer"
            onClick={(e) => e.stopPropagation()}
            className="inline-flex items-center gap-1.5 text-xs text-primary hover:text-primary/80 transition-colors flex-shrink-0"
          >
            <ExternalLink className="h-3.5 w-3.5" />
            <span className="hidden sm:inline">Maps</span>
          </a>
        </div>
        
        {/* Highlights */}
        <div className="space-y-2.5">
          {highlights.map((highlight, index) => (
            <div key={index} className="flex items-start gap-2.5 text-sm text-muted-foreground">
              <Mountain className="h-4 w-4 mt-0.5 flex-shrink-0 text-primary" />
              <span className="leading-relaxed">{highlight}</span>
            </div>
          ))}
        </div>
        
        {/* Best Season */}
        {bestSeason && (
          <div className="flex items-center gap-2 pt-3 border-t text-sm">
            <Calendar className="h-4 w-4 text-primary flex-shrink-0" />
            <span className="text-muted-foreground">
              <span className="font-medium">Best time:</span> {bestSeason}
            </span>
          </div>
        )}
      </div>
    </div>
  );
}

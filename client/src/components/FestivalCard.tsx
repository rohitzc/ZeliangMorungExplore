import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Calendar, MapPin } from "lucide-react";

interface FestivalCardProps {
  name: string;
  date: string;
  location: string;
  description: string;
  imageSrc?: string;
  highlight?: string;
}

export default function FestivalCard({ 
  name, 
  date, 
  location, 
  description,
  imageSrc,
  highlight 
}: FestivalCardProps) {
  return (
    <Card className="overflow-hidden hover-elevate active-elevate-2" data-testid={`card-festival-${name.toLowerCase().replace(/\s+/g, '-')}`}>
      {imageSrc && (
        <div className="aspect-video w-full overflow-hidden">
          <img 
            src={imageSrc} 
            alt={name}
            className="h-full w-full object-cover"
            loading="lazy"
            decoding="async"
          />
        </div>
      )}
      
      <CardContent className="p-6 space-y-4">
        <div className="flex items-start justify-between gap-4 flex-wrap">
          <h3 className="font-serif text-xl font-semibold" data-testid={`text-festival-name-${name.toLowerCase().replace(/\s+/g, '-')}`}>
            {name}
          </h3>
          {highlight && (
            <Badge variant="secondary">{highlight}</Badge>
          )}
        </div>
        
        <div className="space-y-2 text-sm">
          <div className="flex items-center gap-2 text-muted-foreground">
            <Calendar className="h-4 w-4 text-primary" />
            <span>{date}</span>
          </div>
          <div className="flex items-center gap-2 text-muted-foreground">
            <MapPin className="h-4 w-4 text-primary" />
            <span>{location}</span>
          </div>
        </div>
        
        <p className="text-sm text-muted-foreground leading-relaxed">
          {description}
        </p>
      </CardContent>
    </Card>
  );
}

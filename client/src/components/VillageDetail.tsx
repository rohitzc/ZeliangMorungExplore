import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ArrowLeft, Mountain, Info } from "lucide-react";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  type CarouselApi,
} from "@/components/ui/carousel";

interface VillageDetailProps {
  name: string;
  imageSrc: string;
  distance: string;
  description: string;
  attractions: string[];
  bestTime?: string;
  additionalImages?: string[];
  onBack?: () => void;
}

export default function VillageDetail({
  name,
  imageSrc,
  distance,
  description,
  attractions,
  bestTime,
  additionalImages = [],
  onBack
}: VillageDetailProps) {
  const [api, setApi] = useState<CarouselApi>();

  // Encode image URLs to handle spaces and special characters
  const encodeImageUrl = (url: string) => {
    // Split the URL and encode only the filename part
    const parts = url.split('/');
    const filename = parts[parts.length - 1];
    const encodedFilename = encodeURIComponent(filename);
    return parts.slice(0, -1).join('/') + '/' + encodedFilename;
  };

  // Combine main image with additional images and encode URLs
  const allImages = [imageSrc, ...additionalImages].map(encodeImageUrl);
  const hasMultipleImages = allImages.length > 1;

  // Auto-scroll carousel
  useEffect(() => {
    if (!api || !hasMultipleImages) return;

    const interval = setInterval(() => {
      if (api.canScrollNext()) {
        api.scrollNext();
      } else {
        // Loop back to start
        api.scrollTo(0);
      }
    }, 4000); // Change image every 4 seconds

    return () => clearInterval(interval);
  }, [api, hasMultipleImages]);

  return (
    <div className="min-h-screen pb-20">
      <div className="sticky top-0 z-40 bg-background/80 backdrop-blur-sm border-b">
        <div className="flex items-center gap-4 p-4">
          <Button 
            variant="ghost" 
            size="icon"
            onClick={onBack}
            data-testid="button-back"
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <h1 className="font-serif text-xl font-semibold">{name}</h1>
        </div>
      </div>

      {hasMultipleImages ? (
        <div className="w-full relative">
          <Carousel 
            className="w-full" 
            setApi={setApi}
            opts={{
              align: "start",
              loop: true,
              dragFree: false,
            }}
          >
            <CarouselContent>
              {allImages.map((img, index) => (
                <CarouselItem key={index}>
                  <div className="aspect-video md:aspect-[21/9] w-full overflow-hidden">
                    <img 
                      src={img} 
                      alt={`${name} - Image ${index + 1}`}
                      className="h-full w-full object-cover"
                    />
                  </div>
                </CarouselItem>
              ))}
            </CarouselContent>
          </Carousel>
        </div>
      ) : (
        <div className="aspect-video md:aspect-[21/9] w-full overflow-hidden">
          <img 
            src={encodeImageUrl(imageSrc)} 
            alt={name}
            className="h-full w-full object-cover"
          />
        </div>
      )}

      <div className="px-4 py-6 md:px-6 md:py-8 space-y-6 md:space-y-8 max-w-6xl mx-auto">
        <div className="space-y-4">
          <h2 className="font-serif text-2xl md:text-3xl font-semibold">About</h2>
          <p className="text-base md:text-lg leading-relaxed text-foreground">
            {description}
          </p>
        </div>

        <Card>
          <CardContent className="p-4 md:p-6 space-y-4">
            <div className="flex items-center gap-2">
              <Mountain className="h-5 w-5 text-primary flex-shrink-0" />
              <h3 className="font-semibold text-lg md:text-xl">Key Attractions</h3>
            </div>
            <ul className="space-y-3">
              {attractions.map((attraction, index) => (
                <li 
                  key={index} 
                  className="flex items-start gap-3 text-sm md:text-base text-muted-foreground"
                >
                  <Info className="h-4 w-4 mt-0.5 flex-shrink-0 text-primary" />
                  <span className="leading-relaxed">{attraction}</span>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

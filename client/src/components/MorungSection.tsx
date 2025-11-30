import { useState, useEffect } from "react";
import { Card, CardContent } from "@/components/ui/card";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  type CarouselApi,
} from "@/components/ui/carousel";

interface MorungSectionProps {
  title: string;
  description: string;
  imageSrc: string;
  additionalImages?: string[];
  sections: {
    title: string;
    content: string;
    imageSrc?: string;
  }[];
}

// Helper function to format image name to display text
const formatImageName = (imagePath: string): string => {
  const filename = imagePath.split('/').pop() || '';
  // Remove extension
  let name = filename.replace(/\.[^/.]+$/, '');
  // Replace underscores and hyphens with spaces
  name = name.replace(/[_-]/g, ' ');
  // Convert to title case
  name = name.replace(/\b\w/g, (char) => char.toUpperCase());
  // Special handling for morung images
  if (name.toLowerCase().includes('morung')) {
    return 'Morung';
  }
  return name;
};

export default function MorungSection({ title, description, imageSrc, additionalImages = [], sections }: MorungSectionProps) {
  const [api, setApi] = useState<CarouselApi>();
  const [current, setCurrent] = useState(0);

  // Encode image URLs to handle spaces and special characters
  const encodeImageUrl = (url: string) => {
    const parts = url.split('/');
    const filename = parts[parts.length - 1];
    const encodedFilename = encodeURIComponent(filename);
    return parts.slice(0, -1).join('/') + '/' + encodedFilename;
  };

  // Combine main image with additional images
  const allImagePaths = [imageSrc, ...additionalImages];
  const allImages = allImagePaths.map(encodeImageUrl);
  const hasMultipleImages = allImages.length > 1;

  // Track current slide
  useEffect(() => {
    if (!api) return;

    setCurrent(api.selectedScrollSnap());

    api.on("select", () => {
      setCurrent(api.selectedScrollSnap());
    });
  }, [api]);

  // Auto-scroll carousel
  useEffect(() => {
    if (!api || !hasMultipleImages) return;

    const interval = setInterval(() => {
      if (api.canScrollNext()) {
        api.scrollNext();
      } else {
        api.scrollTo(0);
      }
    }, 4000);

    return () => clearInterval(interval);
  }, [api, hasMultipleImages]);

  return (
    <div className="space-y-8">
      {hasMultipleImages ? (
        <div className="w-full relative -mx-4 md:-mx-8">
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
                <CarouselItem key={index} className="pl-0">
                  <div className="w-full">
                    <img 
                      src={img} 
                      alt={`${title} - Image ${index + 1}`}
                      className="w-full h-auto object-contain"
                    />
                  </div>
                </CarouselItem>
              ))}
            </CarouselContent>
          </Carousel>
          
          {/* Carousel Indicators */}
          <div className="flex justify-center gap-2 mt-4 px-4">
            {allImages.map((_, index) => (
              <button
                key={index}
                onClick={() => api?.scrollTo(index)}
                className={`h-2 w-2 rounded-full transition-all ${
                  current === index
                    ? 'bg-primary w-6'
                    : 'bg-muted-foreground/30 hover:bg-muted-foreground/50'
                }`}
                aria-label={`Go to slide ${index + 1}`}
              />
            ))}
          </div>
          
          {/* Image Label */}
          <div className="text-center mt-2 px-4">
            <p className="text-sm text-muted-foreground">
              {formatImageName(allImagePaths[current])}
            </p>
          </div>
        </div>
      ) : (
        <div className="w-full -mx-4 md:-mx-8">
          <div className="w-full">
            <img 
              src={encodeImageUrl(imageSrc)} 
              alt={title}
              className="w-full h-auto object-contain"
            />
          </div>
          <div className="text-center mt-2 px-4">
            <p className="text-sm text-muted-foreground">
              {formatImageName(imageSrc)}
            </p>
          </div>
        </div>
      )}
      
      <div className="space-y-4">
        <h2 className="font-serif text-3xl font-bold" data-testid="text-morung-title">
          {title}
        </h2>
        <p className="text-base leading-relaxed text-foreground">
          {description}
        </p>
      </div>
      
      <div className="space-y-6">
        <h3 className="font-serif text-2xl font-semibold">Cultural Details</h3>
        <div className="grid grid-cols-1 gap-6">
          {sections.map((section, index) => (
            <Card key={index} className="overflow-hidden hover-elevate transition-shadow">
              <CardContent className="p-0">
                <h4 className="font-serif text-xl font-semibold p-6 pb-4">
                  {section.title}
                </h4>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-0">
                  {section.imageSrc && (
                    <div className="w-full md:h-full min-h-[250px] md:min-h-0 overflow-hidden bg-muted/30 flex items-center justify-center">
                      <img 
                        src={encodeImageUrl(section.imageSrc)} 
                        alt={section.title}
                        className="w-full h-full object-contain md:object-cover"
                      />
                    </div>
                  )}
                  <div className={`p-6 ${section.imageSrc ? 'md:flex md:flex-col md:justify-center' : ''}`}>
                    <p className="text-base leading-relaxed text-muted-foreground">
                      {section.content}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
}

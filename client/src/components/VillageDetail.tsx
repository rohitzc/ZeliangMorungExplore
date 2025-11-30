import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import Footer from "@/components/Footer";
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

// Helper function to format image name to display text
const formatImageName = (imagePath: string): string => {
  const filename = imagePath.split('/').pop() || '';
  // Remove extension
  let name = filename.replace(/\.[^/.]+$/, '');
  
  // Special handling for Peren-Village2.jpg
  if (name.toLowerCase() === 'peren-village2' || name.toLowerCase() === 'peren village2') {
    return 'Milei Ngyi Festival in Peren';
  }
  
  // Special handling for saltwater lake
  if (name.toLowerCase().includes('saltwater lake')) {
    return 'Mineral Salt Spring well';
  }
  
  // Special handling for rani cave images
  if (name.toLowerCase().includes('rani cave')) {
    return 'Rani Cave';
  }
  
  // Special handling for inspection bungalow images
  if (name.toLowerCase().includes('inspection bunglow') || name.toLowerCase().includes('inspection bungalow')) {
    return 'British Inspection Bunglow';
  }
  
  // Special handling for traditional salt making images
  if (name.toLowerCase().includes('traditional salt making')) {
    return 'Traditional Salt Making';
  }
  
  // Special handling for morung images
  if (name.toLowerCase().includes('morung')) {
    return 'Morung';
  }
  
  // Replace underscores and hyphens with spaces
  name = name.replace(/[_-]/g, ' ');
  // Convert to title case
  name = name.replace(/\b\w/g, (char) => char.toUpperCase());
  
  return name;
};

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
  const [current, setCurrent] = useState(0);

  // Encode image URLs to handle spaces and special characters
  const encodeImageUrl = (url: string) => {
    // Split the URL and encode only the filename part
    const parts = url.split('/');
    const filename = parts[parts.length - 1];
    const encodedFilename = encodeURIComponent(filename);
    return parts.slice(0, -1).join('/') + '/' + encodedFilename;
  };

  // Combine main image with additional images
  const allImagePaths = [imageSrc, ...additionalImages];
  const allImages = allImagePaths.map(encodeImageUrl);
  const hasMultipleImages = allImages.length > 1;

  // Track current slide and preload adjacent images
  useEffect(() => {
    if (!api) return;

    setCurrent(api.selectedScrollSnap());

    const handleSelect = () => {
      const newCurrent = api.selectedScrollSnap();
      setCurrent(newCurrent);
      
      // Preload next and previous images for smoother transitions
      if (newCurrent < allImages.length - 1) {
        const nextImg = new Image();
        nextImg.src = allImages[newCurrent + 1];
      }
      if (newCurrent > 0) {
        const prevImg = new Image();
        prevImg.src = allImages[newCurrent - 1];
      }
    };

    api.on("select", handleSelect);

    return () => {
      api.off("select", handleSelect);
    };
  }, [api, allImages]);

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
                      loading={index === 0 ? "eager" : "lazy"}
                      fetchpriority={index === 0 ? "high" : "low"}
                      decoding="async"
                      onLoad={(e) => {
                        // Preload next image for smoother carousel transitions
                        if (index < allImages.length - 1) {
                          const nextImg = new Image();
                          nextImg.src = allImages[index + 1];
                        }
                      }}
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
        <div>
          <div className="aspect-video md:aspect-[21/9] w-full overflow-hidden">
            <img 
              src={encodeImageUrl(imageSrc)} 
              alt={name}
              className="h-full w-full object-cover"
              loading="eager"
              fetchpriority="high"
              decoding="async"
            />
          </div>
          <div className="text-center mt-2 px-4">
            <p className="text-sm text-muted-foreground">
              {formatImageName(imageSrc)}
            </p>
          </div>
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
      <Footer />
    </div>
  );
}

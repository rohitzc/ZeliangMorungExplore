import { Button } from "@/components/ui/button";
import { ArrowDown } from "lucide-react";

interface HeroProps {
  title: string;
  subtitle: string;
  imageSrc: string;
  onExplore?: () => void;
}

export default function Hero({ title, subtitle, imageSrc, onExplore }: HeroProps) {
  return (
    <div className="relative h-[85vh] w-full overflow-hidden">
      <img 
        src={imageSrc}
        alt="Zeliang Heritage"
        className="absolute inset-0 h-full w-full object-cover"
        onError={(e) => {
          console.error('Failed to load hero image:', imageSrc);
          // Fallback to a solid color if image fails
          e.currentTarget.style.display = 'none';
        }}
      />
      <div className="absolute inset-0 bg-gradient-to-b from-black/60 via-black/40 to-black/70" />
      
      <div className="relative z-10 flex h-full flex-col items-center justify-center px-4 text-center">
        <h1 className="font-serif text-4xl font-bold text-white md:text-5xl lg:text-6xl mb-4">
          {title}
        </h1>
        <p className="text-lg text-white/90 md:text-xl max-w-2xl mb-8 font-light leading-relaxed">
          {subtitle}
        </p>
        <Button 
          size="lg"
          variant="outline"
          onClick={onExplore}
          className="backdrop-blur-sm bg-white/20 border-white/30 text-white hover:bg-white/30 min-h-12"
          data-testid="button-explore"
        >
          Explore Heritage
          <ArrowDown className="ml-2 h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}

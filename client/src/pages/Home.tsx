import { useQuery } from "@tanstack/react-query";
import Hero from "@/components/Hero";
import VillageCard from "@/components/VillageCard";
import FestivalCard from "@/components/FestivalCard";
import GlossarySheet from "@/components/GlossarySheet";
import Footer from "@/components/Footer";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { ArrowRight } from "lucide-react";
import type { Village, Festival } from "@shared/schema";

// Using a scenic village image for the hero - using image without spaces for better compatibility
const heroImage = '/assets/peren-village.jpg';

interface HomeProps {
  onNavigate: (section: string) => void;
  onVillageClick?: (villageId: string) => void;
}

export default function Home({ onNavigate, onVillageClick }: HomeProps) {
  const { data: villages, isLoading: villagesLoading } = useQuery<Village[]>({
    queryKey: ['/api/villages'],
  });

  const { data: festivals, isLoading: festivalsLoading } = useQuery<Festival[]>({
    queryKey: ['/api/festivals'],
  });

  const handleExplore = () => {
    const villagesSection = document.getElementById('villages-preview');
    villagesSection?.scrollIntoView({ behavior: 'smooth' });
  };

  const featuredVillages = villages?.slice(0, 3) || [];
  const featuredFestivals = festivals?.slice(0, 2) || [];

  return (
    <div className="min-h-screen pb-20">
      <Hero 
        title="Discover Zeliang Heritage"
        subtitle="Explore the rich cultural traditions of the Zeliang tribe and the stunning villages of Peren District, Nagaland"
        imageSrc={heroImage}
        onExplore={handleExplore}
      />
      
      <div className="px-4 py-12 space-y-12 max-w-6xl mx-auto" id="villages-preview">
        <div className="space-y-6">
          <div className="flex items-center justify-between gap-4 flex-wrap">
            <div>
              <h2 className="font-serif text-3xl font-bold mb-2">Explore Villages</h2>
              <p className="text-muted-foreground">Discover the beauty of Peren District</p>
            </div>
            <Button 
              variant="outline" 
              onClick={() => onNavigate('villages')}
              className="gap-2"
              data-testid="button-view-all-villages"
            >
              View All
              <ArrowRight className="h-4 w-4" />
            </Button>
          </div>
          
          {villagesLoading ? (
            <div className="grid grid-cols-1 gap-6">
              {[...Array(3)].map((_, i) => (
                <div key={i} className="space-y-4">
                  <Skeleton className="aspect-video w-full" />
                  <Skeleton className="h-8 w-3/4" />
                  <Skeleton className="h-4 w-full" />
                </div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-6">
              {featuredVillages.map((village) => (
                <VillageCard 
                  key={village.id}
                  name={village.name}
                  imageSrc={village.imageSrc}
                  distance={village.distance}
                  highlights={village.highlights}
                  bestSeason={village.bestSeason}
                  onClick={() => onVillageClick?.(village.id)}
                />
              ))}
            </div>
          )}
        </div>

        <div className="space-y-6">
          <div className="flex items-center justify-between gap-4 flex-wrap">
            <div>
              <h2 className="font-serif text-3xl font-bold mb-2">Cultural Festivals</h2>
              <p className="text-muted-foreground">Vibrant celebrations throughout the year</p>
            </div>
            <Button 
              variant="outline" 
              onClick={() => onNavigate('festivals')}
              className="gap-2"
              data-testid="button-view-all-festivals"
            >
              View All
              <ArrowRight className="h-4 w-4" />
            </Button>
          </div>
          
          {festivalsLoading ? (
            <div className="grid grid-cols-1 gap-6">
              {[...Array(2)].map((_, i) => (
                <div key={i} className="space-y-4">
                  <Skeleton className="aspect-video w-full" />
                  <Skeleton className="h-6 w-1/2" />
                  <Skeleton className="h-4 w-full" />
                </div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-6">
              {featuredFestivals.map((festival) => (
                <FestivalCard 
                  key={festival.id}
                  name={festival.name}
                  date={festival.date}
                  location={festival.location}
                  description={festival.description}
                  imageSrc={festival.imageSrc}
                  highlight={festival.highlight}
                />
              ))}
            </div>
          )}
        </div>

        <div className="bg-card p-8 rounded-lg border space-y-6">
          <div className="space-y-2">
            <h2 className="font-serif text-2xl font-bold">Learn About Morung Culture</h2>
            <p className="text-muted-foreground leading-relaxed">
              Discover the traditional Rehangki, a male dormitory that served as a training center 
              and social hub where young men learned tribal laws, customs, and traditions.
            </p>
          </div>
          
          <div className="flex flex-wrap gap-4">
            <Button 
              onClick={() => onNavigate('morung')}
              className="gap-2"
              data-testid="button-explore-morung"
            >
              Explore Morung Heritage
              <ArrowRight className="h-4 w-4" />
            </Button>
            <GlossarySheet />
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
}

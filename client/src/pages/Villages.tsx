import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import VillageCard from "@/components/VillageCard";
import VillageDetail from "@/components/VillageDetail";
import Footer from "@/components/Footer";
import { Skeleton } from "@/components/ui/skeleton";
import type { Village } from "@shared/schema";

interface VillagesProps {
  initialVillageId?: string | null;
  onVillageDeselect?: () => void;
}

export default function Villages({ initialVillageId = null, onVillageDeselect }: VillagesProps = {}) {
  const [selectedVillage, setSelectedVillage] = useState<Village | null>(null);
  const [prevInitialVillageId, setPrevInitialVillageId] = useState<string | null>(initialVillageId);
  
  const { data: villages, isLoading } = useQuery<Village[]>({
    queryKey: ['/api/villages'],
  });

  // Auto-select village if initialVillageId is provided
  useEffect(() => {
    if (initialVillageId && villages) {
      const village = villages.find(v => v.id === initialVillageId);
      if (village) {
        setSelectedVillage(village);
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    } else if (!initialVillageId && prevInitialVillageId) {
      // Clear selection only when initialVillageId changes from a value to null
      // This happens when clicking villages tab from detail view
      setSelectedVillage(null);
    }
    setPrevInitialVillageId(initialVillageId);
  }, [initialVillageId, villages, prevInitialVillageId]);

  // Scroll to top when village detail opens
  useEffect(() => {
    if (selectedVillage) {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  }, [selectedVillage]);

  const handleBack = () => {
    setSelectedVillage(null);
    onVillageDeselect?.();
  };

  if (selectedVillage) {
    return (
      <VillageDetail 
        name={selectedVillage.name}
        imageSrc={selectedVillage.imageSrc}
        distance={selectedVillage.distance}
        description={selectedVillage.description}
        attractions={selectedVillage.attractions}
        bestTime={selectedVillage.bestSeason}
        additionalImages={selectedVillage.additionalImages}
        onBack={handleBack}
      />
    );
  }

  return (
    <div className="min-h-screen pb-20 px-4 py-8 max-w-6xl mx-auto">
      <div className="space-y-6">
        <div>
          <h1 className="font-serif text-3xl font-bold mb-2">Places to Visit</h1>
          <p className="text-muted-foreground">
            Discover the beauty and heritage of Peren District's seven remarkable villages
          </p>
        </div>
        
        {isLoading ? (
          <div className="grid grid-cols-1 gap-6">
            {[...Array(7)].map((_, i) => (
              <div key={i} className="space-y-4">
                <Skeleton className="aspect-video w-full" />
                <Skeleton className="h-8 w-3/4" />
                <Skeleton className="h-4 w-full" />
                <Skeleton className="h-4 w-5/6" />
              </div>
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-6">
            {villages?.map((village) => (
              <VillageCard 
                key={village.id}
                name={village.name}
                imageSrc={village.imageSrc}
                distance={village.distance}
                highlights={village.highlights}
                bestSeason={village.bestSeason}
                onClick={() => setSelectedVillage(village)}
              />
            ))}
          </div>
        )}
      </div>
      <Footer />
    </div>
  );
}

import { useQuery } from "@tanstack/react-query";
import FestivalCard from "@/components/FestivalCard";
import { Skeleton } from "@/components/ui/skeleton";
import type { Festival } from "@shared/schema";

export default function Festivals() {
  const { data: festivals, isLoading } = useQuery<Festival[]>({
    queryKey: ['/api/festivals'],
  });

  return (
    <div className="min-h-screen pb-20 px-4 py-8 max-w-6xl mx-auto">
      <div className="space-y-6">
        <div>
          <h1 className="font-serif text-3xl font-bold mb-2">Cultural Festivals</h1>
          <p className="text-muted-foreground">
            Experience the vibrant celebrations and traditions of the Zeliang people
          </p>
        </div>
        
        {isLoading ? (
          <div className="grid grid-cols-1 gap-6">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="space-y-4">
                <Skeleton className="aspect-video w-full" />
                <Skeleton className="h-6 w-1/2" />
                <Skeleton className="h-4 w-full" />
                <Skeleton className="h-4 w-5/6" />
              </div>
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-6">
            {festivals?.map((festival) => (
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
    </div>
  );
}

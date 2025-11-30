import { useQuery } from "@tanstack/react-query";
import MorungSection from "@/components/MorungSection";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import GlossarySheet from "@/components/GlossarySheet";
import Footer from "@/components/Footer";
import type { MorungResponse } from "@shared/schema";

export default function Morung() {
  const { data: morungData, isLoading } = useQuery<MorungResponse>({
    queryKey: ['/api/morung'],
  });

  if (isLoading) {
    return (
      <div className="min-h-screen pb-20 px-4 py-8 max-w-6xl mx-auto space-y-8">
        <Skeleton className="aspect-[21/9] w-full" />
        <Skeleton className="h-10 w-3/4" />
        <Skeleton className="h-6 w-full" />
        <Skeleton className="h-6 w-5/6" />
        <div className="space-y-4">
          {[...Array(4)].map((_, i) => (
            <Skeleton key={i} className="h-16 w-full" />
          ))}
        </div>
      </div>
    );
  }

  if (!morungData) return null;

  return (
    <div className="min-h-screen pb-20 px-4 py-8 max-w-6xl mx-auto space-y-12">
      <MorungSection 
        title={morungData.title}
        description={morungData.description}
        imageSrc={morungData.imageSrc}
        sections={morungData.sections}
      />

      <div className="pt-4">
        <GlossarySheet />
      </div>
      <Footer />
    </div>
  );
}

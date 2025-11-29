import { useQuery } from "@tanstack/react-query";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import type { GlossaryTerm } from "@shared/schema";

export default function Glossary() {
  const { data: glossaryTerms, isLoading } = useQuery<GlossaryTerm[]>({
    queryKey: ['/api/glossary'],
  });

  const categories = Array.from(new Set(glossaryTerms?.map(t => t.category) || []));

  if (isLoading) {
    return (
      <div className="min-h-screen pb-20 px-4 py-8 max-w-6xl mx-auto">
        <div className="space-y-6">
          <Skeleton className="h-10 w-1/2" />
          <Skeleton className="h-6 w-3/4" />
          <div className="space-y-4">
            {[...Array(5)].map((_, i) => (
              <Skeleton key={i} className="h-32 w-full" />
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen pb-20 px-4 py-8 max-w-6xl mx-auto">
      <div className="space-y-6">
        <div>
          <h1 className="font-serif text-3xl font-bold mb-2">Cultural Glossary</h1>
          <p className="text-muted-foreground">
            Understanding Zeliang terms, traditions, and cultural concepts
          </p>
        </div>
        
        <div className="space-y-8">
          {categories.map((category) => (
            <Card key={category}>
              <CardContent className="p-6 space-y-6">
                <h2 className="font-serif text-2xl font-semibold text-primary">
                  {category}
                </h2>
                
                <div className="space-y-6">
                  {glossaryTerms
                    ?.filter(term => term.category === category)
                    .map((item, index) => (
                      <div 
                        key={index} 
                        className="space-y-2 pb-6 border-b last:border-b-0 last:pb-0"
                        data-testid={`glossary-term-${item.term.toLowerCase().replace(/\s+/g, '-')}`}
                      >
                        <h3 className="font-semibold text-lg text-foreground">
                          {item.term}
                        </h3>
                        <p className="text-muted-foreground leading-relaxed">
                          {item.definition}
                        </p>
                      </div>
                    ))}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
}

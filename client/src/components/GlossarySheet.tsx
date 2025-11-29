import { useQuery } from "@tanstack/react-query";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Skeleton } from "@/components/ui/skeleton";
import { Book } from "lucide-react";
import type { GlossaryTerm } from "@shared/schema";

export default function GlossarySheet() {
  const { data: glossaryTerms, isLoading } = useQuery<GlossaryTerm[]>({
    queryKey: ['/api/glossary'],
  });

  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button variant="outline" className="gap-2" data-testid="button-glossary-open">
          <Book className="h-4 w-4" />
          Cultural Glossary
        </Button>
      </SheetTrigger>
      <SheetContent side="bottom" className="h-[80vh]">
        <SheetHeader className="mb-6">
          <SheetTitle className="font-serif text-2xl">Cultural Glossary</SheetTitle>
          <SheetDescription>
            Understanding Zeliang terms and traditions
          </SheetDescription>
        </SheetHeader>
        <ScrollArea className="h-[calc(80vh-120px)] pr-4">
          {isLoading ? (
            <div className="space-y-6">
              {[...Array(8)].map((_, i) => (
                <div key={i} className="space-y-2">
                  <Skeleton className="h-6 w-1/3" />
                  <Skeleton className="h-16 w-full" />
                </div>
              ))}
            </div>
          ) : (
            <div className="space-y-6">
              {glossaryTerms?.map((item, index) => (
                <div key={index} className="space-y-2" data-testid={`glossary-term-${index}`}>
                  <h4 className="font-semibold text-lg text-foreground">
                    {item.term}
                  </h4>
                  <p className="text-muted-foreground leading-relaxed">
                    {item.definition}
                  </p>
                </div>
              ))}
            </div>
          )}
        </ScrollArea>
      </SheetContent>
    </Sheet>
  );
}

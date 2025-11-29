import { Card, CardContent } from "@/components/ui/card";

interface MorungSectionProps {
  title: string;
  description: string;
  imageSrc: string;
  sections: {
    title: string;
    content: string;
    imageSrc?: string;
  }[];
}

export default function MorungSection({ title, description, imageSrc, sections }: MorungSectionProps) {
  // Encode image URLs to handle spaces and special characters
  const encodeImageUrl = (url: string) => {
    const parts = url.split('/');
    const filename = parts[parts.length - 1];
    const encodedFilename = encodeURIComponent(filename);
    return parts.slice(0, -1).join('/') + '/' + encodedFilename;
  };

  return (
    <div className="space-y-8">
      <div className="aspect-[21/9] w-full overflow-hidden rounded-lg">
        <img 
          src={encodeImageUrl(imageSrc)} 
          alt={title}
          className="h-full w-full object-cover"
        />
      </div>
      
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
                <CardContent className={`p-6 ${section.imageSrc ? 'md:flex md:flex-col md:justify-center' : ''}`}>
                  <h4 className="font-serif text-xl font-semibold mb-3">
                    {section.title}
                  </h4>
                  <p className="text-base leading-relaxed text-muted-foreground">
                    {section.content}
                  </p>
                </CardContent>
              </div>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
}

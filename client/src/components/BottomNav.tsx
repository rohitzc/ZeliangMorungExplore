import { Home, MapIcon, Building2, Calendar, Book } from "lucide-react";

interface NavItem {
  icon: typeof Home;
  label: string;
  id: string;
}

interface BottomNavProps {
  activeTab: string;
  onTabChange: (tabId: string) => void;
}

const navItems: NavItem[] = [
  { icon: Home, label: "Home", id: "home" },
  { icon: MapIcon, label: "Villages", id: "villages" },
  { icon: Building2, label: "Morung", id: "morung" },
  { icon: Calendar, label: "Festivals", id: "festivals" },
  { icon: Book, label: "Glossary", id: "glossary" },
];

export default function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-card border-t border-border">
      <div className="flex items-center justify-around px-2 py-2 max-w-2xl mx-auto">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          
          return (
            <button
              key={item.id}
              onClick={() => onTabChange(item.id)}
              className={`flex flex-col items-center justify-center gap-1 px-3 py-2 rounded-md min-h-14 hover-elevate active-elevate-2 transition-colors ${
                isActive ? "text-primary" : "text-muted-foreground"
              }`}
              data-testid={`button-nav-${item.id}`}
            >
              <Icon className={`h-5 w-5 ${isActive ? "fill-primary/20" : ""}`} />
              <span className="text-xs font-medium">{item.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}

import { useState } from "react";
import { QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "./lib/queryClient";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";

import BottomNav from "@/components/BottomNav";
import Home from "@/pages/Home";
import Villages from "@/pages/Villages";
import Morung from "@/pages/Morung";
import Festivals from "@/pages/Festivals";
import Glossary from "@/pages/Glossary";

function App() {
  const [activeTab, setActiveTab] = useState('home');
  const [selectedVillageId, setSelectedVillageId] = useState<string | null>(null);

  const handleNavigate = (section: string) => {
    setActiveTab(section);
    setSelectedVillageId(null); // Clear selected village when navigating to a new section
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleVillageClick = (villageId: string) => {
    setSelectedVillageId(villageId);
    setActiveTab('villages');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <div className="min-h-screen bg-background">
          {activeTab === 'home' && (
            <Home onNavigate={handleNavigate} onVillageClick={handleVillageClick} />
          )}
          {activeTab === 'villages' && (
            <Villages initialVillageId={selectedVillageId} onVillageDeselect={() => setSelectedVillageId(null)} />
          )}
          {activeTab === 'morung' && <Morung />}
          {activeTab === 'festivals' && <Festivals />}
          {activeTab === 'glossary' && <Glossary />}
          
          <BottomNav activeTab={activeTab} onTabChange={handleNavigate} />
        </div>
        <Toaster />
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;

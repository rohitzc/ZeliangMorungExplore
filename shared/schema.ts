import { z } from "zod";

// Village data structure
export interface Village {
  id: string;
  name: string;
  imageSrc: string;
  distance: string;
  highlights: string[];
  bestSeason?: string;
  description: string;
  attractions: string[];
  additionalImages?: string[]; // Optional array for additional images
}

// Festival data structure
export interface Festival {
  id: string;
  name: string;
  date: string;
  location: string;
  description: string;
  imageSrc?: string;
  highlight?: string;
}

// Morung section data structure
export interface MorungSectionData {
  title: string;
  content: string;
  imageSrc?: string; // Optional image for each section
}

// Glossary term data structure
export interface GlossaryTerm {
  term: string;
  definition: string;
  category: string;
}

// API response types
export type VillagesResponse = Village[];
export type FestivalsResponse = Festival[];
export type MorungResponse = {
  title: string;
  description: string;
  imageSrc: string;
  interiorImageSrc: string;
  additionalImages?: string[];
  sections: MorungSectionData[];
};
export type GlossaryResponse = GlossaryTerm[];

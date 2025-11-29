import { Festival } from "@shared/schema";

export const festivals: Festival[] = [
  {
    id: 'hega',
    name: 'Hega Festival',
    date: 'February 10-14',
    location: 'Peren Village',
    description: 'One of the oldest Zeliang villages celebrates its pompous and vibrant Hega Festival for a full week. The fifth day, which coincidentally falls on modern Valentine\'s Day (February 14), marks the culmination of the festival. Men folk along with young girls dressed in their best traditional attires sing and dance to Kwaksui, creating a spectacular display of cultural heritage and community joy.',
    imageSrc: '/assets/Peren Village during Hega Festival.jpg',
    highlight: 'Main Festival'
  },
  {
    id: 'cosmos',
    name: 'Cosmos Festival',
    date: 'October',
    location: 'Peletkie Village',
    description: 'Celebrating the breathtaking cosmos flower blossoms that paint the entire village in beautiful shades of pink and white. This festival organized by Peletkie village attracts thousands of visitors from far and near who come to witness nature\'s spectacular display and participate in the festivities celebrating this natural beauty.',
    imageSrc: '/assets/cosmos-festival.jpg',
    highlight: 'Annual'
  },
  {
    id: 'milei-ngyi',
    name: 'Milei Ngyi Festival',
    date: 'Seasonal',
    location: 'Various Zeliang Villages',
    description: 'A traditional festival featuring the sacred Milei Teu ritual - the ancient practice of making fire by pulling and rubbing a slice of bamboo against a particular piece of dried wood (Hemei bang). After a large fire is produced, youths take some fire each to their respective homes to light their hearth fires, symbolizing the continuation of tradition and community bonds.',
    imageSrc: '/assets/Peren-Village2.jpg',
    highlight: 'Traditional'
  },
  {
    id: 'salt-making',
    name: 'Traditional Salt Making Ceremony',
    date: 'Year-round',
    location: 'Peletkie Village',
    description: 'An interesting cultural practice unique to Peletkie village where water is fetched from a particular pond area and boiled in large pots until a strong, particular kind of salt is extracted. This traditional procedure has been passed down through generations and continues to be practiced, preserving ancient knowledge and methods.',
    imageSrc: '/assets/traditional salt making2.png',
    highlight: 'Cultural Heritage'
  }
];

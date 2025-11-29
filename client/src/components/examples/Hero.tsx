import Hero from '../Hero';

const heroImage = '/assets/Beneru Village.jpeg';

export default function HeroExample() {
  return (
    <Hero 
      title="Discover Zeliang Heritage"
      subtitle="Explore the rich cultural traditions of the Zeliang tribe and the stunning villages of Peren District, Nagaland"
      imageSrc={heroImage}
      onExplore={() => console.log('Explore clicked')}
    />
  );
}

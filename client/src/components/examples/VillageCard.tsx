import VillageCard from '../VillageCard';

const mountPaunaImage = '/assets/Beneru Village.jpeg';

export default function VillageCardExample() {
  return (
    <div className="p-4">
      <VillageCard 
        name="Benreu Village"
        imageSrc={mountPaunaImage}
        distance="65 KM from Kohima"
        highlights={[
          "Mt. Pauna Tourist Village - established 2003",
          "Third highest mountain peak in Nagaland",
          "Spiritual connection with Siperai and Mireuding spirits"
        ]}
        bestSeason="Oct-Jan for trekking, Mar-Apr for rhododendrons"
        onClick={() => console.log('Benreu village clicked')}
      />
    </div>
  );
}

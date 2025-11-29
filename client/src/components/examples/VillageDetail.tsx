import VillageDetail from '../VillageDetail';

const sheepFarmImage = '/assets/Pliva Village Sheep Farm.jpg';

export default function VillageDetailExample() {
  return (
    <VillageDetail 
      name="Poilwa Village"
      imageSrc={sheepFarmImage}
      distance="52 KM from Kohima via Khonoma-Dzulakie"
      description="Popularly known for its sheep farm, the only sheep farm in Nagaland. An ideal place for picnics with lush greenery, beautiful landscapes and rivers in and around the hamlets of Heunambenam and Helagim."
      attractions={[
        "The only sheep farm in Nagaland",
        "Hausem Khel resort for tourists and visitors",
        "Beautiful landscapes and rivers around Heunambenam hamlet",
        "Lush greenery perfect for picnics and nature walks",
        "Scenic views of Helagim and surrounding areas"
      ]}
      bestTime="Year-round pleasant weather"
      onBack={() => console.log('Back clicked')}
    />
  );
}

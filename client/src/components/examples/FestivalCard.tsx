import FestivalCard from '../FestivalCard';

const festivalImage = '/assets/Peren Village during Hega Festival.jpg';

export default function FestivalCardExample() {
  return (
    <div className="p-4 space-y-4">
      <FestivalCard 
        name="Hega Festival"
        date="February 10-14"
        location="Peren Village"
        description="A week-long vibrant celebration culminating on Valentine's Day (Feb 14). Men folk and young girls dress in their best traditional attires to perform Kwaksui dance, marking the festival's grand finale."
        imageSrc={festivalImage}
        highlight="Main Festival"
      />
      <FestivalCard 
        name="Cosmos Festival"
        date="October"
        location="Peletkie Village"
        description="Celebrating the beautiful cosmos flower blossoms that cover the village in pink and white. This festival attracts thousands of visitors from far and near to witness the stunning natural display."
      />
    </div>
  );
}

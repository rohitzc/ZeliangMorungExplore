import MorungSection from '../MorungSection';

const morungImage = '/assets/A morung in Peren Village.jpg';

export default function MorungSectionExample() {
  const sections = [
    {
      title: "Structure & Architecture",
      content: "Traditional Rehangki roofing is made of thatch with frames of wood and bamboo covering both sides from top to bottom. The entrance is typically a single door, with walls and doors made of carefully selected century-old wood. Spears of the youths are hung at the entrance wall."
    },
    {
      title: "The Sacred Bed",
      content: "The main bed is made from a single piece of wood (15-20 feet long, 5-6 feet wide) from a Bonsum tree (Nga bang), usually centuries old. It was considered taboo for girls to climb, sit or sleep on this bed."
    },
    {
      title: "Social Gatherings",
      content: "Men folk gather in their respective Rehangki during evenings with their best drinks and delicacies. They are often visited by old and wise men of their clans, learning about culture and traditions through socializing and traditional activities."
    },
    {
      title: "Caretakers",
      content: "The caretaker couple were called Hangsiupui (Female) and Hangsiupei (Male). Hangsiupui played the bigger role, responsible for fetching water, providing firewood, serving drinks, and overall care of the Rehangki and men folk."
    }
  ];

  return (
    <div className="p-4">
      <MorungSection 
        title="Rehangki: The Traditional Morung"
        description="Rehangki, also known as the Morung, is a traditional male dormitory that served as a training center and social hub for young men. The word 'Rehang' means male youth and 'Ki' means house - literally a house for the males of a village."
        imageSrc={morungImage}
        sections={sections}
      />
    </div>
  );
}

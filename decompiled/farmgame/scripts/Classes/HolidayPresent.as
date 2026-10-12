package Classes
{
   public class HolidayPresent extends LootableDecoration
   {
      
      public function HolidayPresent(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function getMenuItems() : Array
      {
         return [];
      }
      
      override protected function getCurrentImage() : ItemImage
      {
         return null;
      }
   }
}


package Classes
{
   public class VirtualStorageDecoration extends Decoration
   {
      
      public function VirtualStorageDecoration(itemName:String = null)
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


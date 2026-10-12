package Classes.ZItem
{
   import DataSources.BaseDataSource;
   
   public class EvolutionAnimalItem extends AnimalItem
   {
      
      public function EvolutionAnimalItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override public function get buyableWhileVisiting() : Boolean
      {
         return false;
      }
   }
}


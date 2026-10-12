package Classes
{
   import Classes.ZItem.FarmItem;
   import Managers.MystreeReskinDifficultyLevelsManager;
   
   public class AdventurersCamp extends NutcrackerTheater
   {
      
      public function AdventurersCamp(itemName:String)
      {
         super(itemName);
      }
      
      override public function openMystreeUI() : void
      {
         var featureName:String = null;
         var item:FarmItem = getItem();
         if(item)
         {
            featureName = item.featureName;
            MystreeReskinDifficultyLevelsManager.getInstance(featureName).showMainWindow();
         }
      }
   }
}


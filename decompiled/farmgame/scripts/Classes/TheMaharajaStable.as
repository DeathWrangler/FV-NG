package Classes
{
   import Classes.ZItem.FarmItem;
   import Managers.MystreeReskinDifficultyLevelsManager;
   
   public class TheMaharajaStable extends NutcrackerTheater
   {
      
      public function TheMaharajaStable(itemName:String)
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


package Classes
{
   import Managers.CraftingBasketDifficultyLevelManager;
   import Managers.FeatureMessagingManager;
   
   public class CraftingBasketDifficultyLevelsCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function CraftingBasketDifficultyLevelsCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         var craftingBasketDifficultyLevel:CraftingBasketDifficultyLevelManager = new CraftingBasketDifficultyLevelManager(this.m_featureName);
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,craftingBasketDifficultyLevel.showMainWindow);
      }
   }
}


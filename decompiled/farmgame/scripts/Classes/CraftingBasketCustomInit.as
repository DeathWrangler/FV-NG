package Classes
{
   import Managers.FeatureMessagingManager;
   
   public class CraftingBasketCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_difficultyEnabled:String;
      
      public function CraftingBasketCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         var craftingBasket:CraftingBasket = new CraftingBasket(this.m_featureName);
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,craftingBasket.showMainWindow);
      }
   }
}


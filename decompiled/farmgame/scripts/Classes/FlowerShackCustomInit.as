package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.FlowerShackManager;
   
   public class FlowerShackCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function FlowerShackCustomInit(xml:XML = null)
      {
         super();
         this.m_featureName = "flower_shack";
      }
      
      public function initialize() : void
      {
         if(!FeatureMessagingManager.getInstance().isFeatureInitialized(this.m_featureName))
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,FlowerShackManager.getInstance(this.m_featureName).showFlowerShackAndOpenWindow);
         }
      }
      
      private function openUI() : void
      {
         FlowerShackManager.getInstance(this.m_featureName).showFlowerShackAndOpenWindow();
      }
   }
}


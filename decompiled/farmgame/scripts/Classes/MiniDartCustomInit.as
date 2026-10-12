package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.MiniDartsManager;
   
   public class MiniDartCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function MiniDartCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         var miniDartMananger:MiniDartsManager = MiniDartsManager.getInstance();
         if(miniDartMananger)
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,miniDartMananger.handleHUDClick);
         }
      }
   }
}


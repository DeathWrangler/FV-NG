package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.MystreeReskinManager;
   
   public class MystreeReskinCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function MystreeReskinCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,MystreeReskinManager.getInstance(this.m_featureName).handleHUDClick);
      }
   }
}


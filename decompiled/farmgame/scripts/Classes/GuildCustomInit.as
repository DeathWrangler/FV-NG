package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.GuildManager;
   import flash.events.Event;
   
   public class GuildCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function GuildCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,this.showUI);
      }
      
      public function showUI(event:Event = null) : void
      {
         GuildManager.getInstance().showUI();
      }
   }
}


package Classes
{
   import Display.UI;
   import Managers.FeatureMessagingManager;
   import Widgets.Windows.Charity.DonateWindowFactory;
   import flash.display.DisplayObject;
   
   public class MultiDonateCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function MultiDonateCustomInit(xml:XML)
      {
         super();
         if(xml.hasOwnProperty("@name"))
         {
            this.m_featureName = xml.attribute("name").toString();
         }
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,this.showMainWindow);
      }
      
      private function showMainWindow() : void
      {
         var donateWindow:DisplayObject = DonateWindowFactory.getInstance(null,null,"motd",this.m_featureName);
         if(donateWindow != null)
         {
            UI.displayPopup(donateWindow,false);
         }
      }
   }
}


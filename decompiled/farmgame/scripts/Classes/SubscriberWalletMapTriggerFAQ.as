package Classes
{
   import Display.UI;
   import Widgets.Windows.SubscriberWalletComingSoonWindow;
   import flash.events.Event;
   
   public class SubscriberWalletMapTriggerFAQ extends MapTrigger
   {
      
      public static const STATE_IDLE:String = "built_0";
      
      public static const STATE_COMING_SOON:String = "built_1";
      
      private var m_assetPath:String = null;
      
      public function SubscriberWalletMapTriggerFAQ(itemName:String, stateToSet:String = "built_0")
      {
         super(itemName,stateToSet);
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         if(xmlData.hasOwnProperty("dialogUrl"))
         {
            this.m_assetPath = xmlData.dialogUrl;
         }
         this.updateState();
      }
      
      public function updateState(e:Event = null) : void
      {
         setState(STATE_IDLE);
      }
      
      override public function onClick() : void
      {
         setState(STATE_COMING_SOON);
         UI.displayPopup(new SubscriberWalletComingSoonWindow(this.m_assetPath));
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}


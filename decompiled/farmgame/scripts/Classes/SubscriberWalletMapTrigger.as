package Classes
{
   import Managers.FarmStatsManager;
   import Managers.SubscriberWalletManager;
   import flash.events.Event;
   
   public class SubscriberWalletMapTrigger extends MapTrigger
   {
      
      public static const STATE_IDLE:String = "built_0";
      
      public static const STATE_THIRSTY:String = "built_1";
      
      private var m_className:String = null;
      
      private var m_parameters:XML = null;
      
      public function SubscriberWalletMapTrigger(itemName:String, stateToSet:String = "built_0")
      {
         super(itemName,stateToSet);
      }
      
      public function updateState(e:Event = null) : void
      {
         var currentDate:Date = new Date(GlobalEngine.serverTime);
         if(currentDate.day == 1)
         {
            setState(STATE_THIRSTY);
         }
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         if(xmlData.hasOwnProperty("windowClassName"))
         {
            this.m_className = xmlData.windowClassName;
         }
         xmlData.featureName = name;
         this.m_parameters = xmlData;
         this.updateState();
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.updateState();
      }
      
      override public function onClick() : void
      {
         SubscriberWalletManager.getInstance().showMainUI();
         FarmStatsManager.count("subscriber_wallet","OffboardAsset","click");
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}


package Classes
{
   import Managers.DailyCheckInManager;
   import MyLife.Events.GlobalEventManager;
   import flash.events.Event;
   
   public class DailyCheckInMapTrigger extends MapTrigger
   {
      
      public static const REWARD_TYPE_ITEM:String = "item_grant";
      
      public static const REWARD_TYPE_BONUS_ITEM:String = "bonus_item";
      
      protected const STATE_BUILT_1:String = "built_1";
      
      private var m_goodieUrl:String;
      
      private var m_rewards:Array;
      
      private var m_startDate:String;
      
      private var m_bonusItemCode:String;
      
      private var m_dialogUrl:String;
      
      public function DailyCheckInMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         var dialogUrlXML:XMLList = xmlData.child("dialogUrl");
         this.m_dialogUrl = dialogUrlXML[0].toString();
         this.updateState();
         GlobalEventManager.getInstance().addEventListener(DailyCheckInManager.UPDATE_STATE,this.updateState);
      }
      
      override public function onClick() : void
      {
         if(!DailyCheckInManager.isInitialized())
         {
            DailyCheckInManager.getInstance().init(name,this.m_dialogUrl);
         }
         DailyCheckInManager.getInstance().openDailyCheckInUI();
      }
      
      public function updateState(e:Event = null) : void
      {
         if(DailyCheckInManager.isHarvestable(name))
         {
            setState("built_1");
         }
         else
         {
            setState("built_0");
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         switch(state)
         {
            case STATE_BUILT_0:
            case this.STATE_BUILT_1:
               imageName = state;
         }
         return imageName;
      }
   }
}


package Classes
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.MapTriggerManager;
   import Widgets.Windows.RegionMapTriggerWindow;
   
   public class RegionMapTrigger extends MapTrigger
   {
      
      public static const BILL_BOARD:String = "BillBoard_";
      
      private const STATE_BUILT_1:String = "built_1";
      
      private var m_dialogUrl:String;
      
      private var m_feature_name:String;
      
      public function RegionMapTrigger(itemName:String, stateToSet:String = "built_0")
      {
         super(itemName,stateToSet);
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         var dialogUrlXML:XMLList = xmlData.child("dialogUrl");
         this.m_dialogUrl = dialogUrlXML[0].toString();
      }
      
      override public function loadObject(data:Object) : void
      {
         if(!data)
         {
            data = {
               "position":{
                  "x":0,
                  "y":0,
                  "z":0
               },
               "state":m_stateToSet
            };
         }
         super.loadObject(data);
         if(data.hasOwnProperty("state"))
         {
            setState(data["state"]);
         }
         this.m_feature_name = MapTriggerManager.getInstance().getMapTriggerName();
         if(Global.player.getSeenFlag(BILL_BOARD + this.m_feature_name))
         {
            setState(STATE_BUILT_0);
         }
         this.attach();
      }
      
      override public function onClick() : void
      {
         FarmStatsManager.count("R4Billboard","click");
         if(this.m_feature_name == "regionbillboard5")
         {
            if(FeatureMessagingManager.getInstance().isFeatureInitialized("R4EpicBattle"))
            {
               StatsManager.count(this.m_feature_name,"FOTW_BILLBOARD","click","open_feature_UI");
               FeatureMessagingManager.getInstance().openFeatureUI("R4EpicBattle");
            }
         }
         else
         {
            UI.displayPopup(new RegionMapTriggerWindow(this.m_feature_name,this.m_dialogUrl));
            if(!Global.player.getSeenFlag(BILL_BOARD + this.m_feature_name))
            {
               setState(STATE_BUILT_0);
               Global.player.setSeenFlag(BILL_BOARD + this.m_feature_name);
            }
         }
      }
      
      public function updateState(value:String) : void
      {
         setState(value);
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}


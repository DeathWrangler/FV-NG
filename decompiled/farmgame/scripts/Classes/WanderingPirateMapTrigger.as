package Classes
{
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.WanderingPirateManager;
   import MyLife.Events.GlobalEventManager;
   import Widgets.Windows.WanderingPirateComingSoonWindow;
   import flash.events.Event;
   
   public class WanderingPirateMapTrigger extends MapTrigger
   {
      
      public static const STATE_IDLE:String = "built_0";
      
      public static const STATE_THIRSTY:String = "built_1";
      
      public static const STATE_ECSTATIC:String = "built_1";
      
      private var m_assetPath:String = null;
      
      private var m_cominSoonassetPath:String = null;
      
      private var m_className:String = null;
      
      private var m_parameters:XML = null;
      
      private var m_featureManager:WanderingPirateManager;
      
      private var m_startDate:String = "";
      
      private var m_featureName:String;
      
      public function WanderingPirateMapTrigger(itemName:String, stateToSet:String = "built_0")
      {
         super(itemName,stateToSet);
      }
      
      public function updateState(e:Event = null) : void
      {
         setState(STATE_IDLE);
         if(Boolean(WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME)) && WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).hasUserFinished())
         {
            setState(STATE_ECSTATIC);
         }
      }
      
      public function updateStateToEcstatic(e:Event = null) : void
      {
         setState(STATE_ECSTATIC);
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         if(xmlData.hasOwnProperty("dialogUrl"))
         {
            this.m_assetPath = xmlData.dialogUrl;
         }
         if(xmlData.hasOwnProperty("windowClassName"))
         {
            this.m_className = xmlData.windowClassName;
         }
         xmlData.featureName = name;
         this.m_parameters = xmlData;
         this.updateState();
         GlobalEventManager.getInstance().addEventListener(WanderingPirateManager.UPDATE_STATE,this.updateStateToEcstatic);
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.updateState();
      }
      
      override public function onClick() : void
      {
         var rewardsWindow:WanderingPirateComingSoonWindow = null;
         this.m_featureName = WanderingPirateManager.FEATURE_NAME;
         this.m_featureManager = WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME);
         if(this.m_featureManager)
         {
            this.m_featureManager.showWanderingPirateAndOpenWindow();
            StatsManager.count("NPC","Clicks","Widgets.Windows::WanderingPirateWindow");
         }
         else
         {
            rewardsWindow = new WanderingPirateComingSoonWindow();
            UI.displayPopup(rewardsWindow,false);
         }
         super.onClick();
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}


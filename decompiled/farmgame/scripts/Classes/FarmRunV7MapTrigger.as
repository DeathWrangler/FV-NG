package Classes
{
   import Engine.Managers.StatsManager;
   import Managers.OrderBoard.FarmRunV7Manager;
   import Managers.WanderingPirateManager;
   import MyLife.Events.GlobalEventManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FarmRunV7MapTrigger extends MapTrigger
   {
      
      public static const STATE_IDLE:String = "built_0";
      
      public static const STATE_THIRSTY:String = "built_1";
      
      public static const STATE_ECSTATIC:String = "built_1";
      
      private var m_assetPath:String = null;
      
      private var m_cominSoonassetPath:String = null;
      
      private var m_className:String = null;
      
      private var m_parameters:XML = null;
      
      private var m_featureManager:FarmRunV7Manager;
      
      private var m_startDate:String = "";
      
      private var m_featureName:String;
      
      public function FarmRunV7MapTrigger(itemName:String, stateToSet:String = "built_0")
      {
         super(itemName,stateToSet);
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         m_toolTipOverride = "Farm Run!";
         super.onMouseOver(event);
      }
      
      public function updateState(e:Event = null) : void
      {
      }
      
      public function updateStateToEcstatic(e:Event = null) : void
      {
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
         this.m_featureName = FarmRunV7Manager.FEATURE_NAME;
         this.m_featureManager = FarmRunV7Manager.getInstance(this.m_featureName);
         if(this.m_featureManager)
         {
            this.m_featureManager.showMainUI();
            StatsManager.count("NPC","Clicks","Widgets.Windows::WanderingPirateWindow");
         }
         super.onClick();
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}


package Classes
{
   import Engine.Managers.StatsManager;
   import Managers.AnimalSanctuaryV2Manager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuaryV2MapTrigger extends MapTrigger
   {
      
      public static const STATE_IDLE:String = "built_0";
      
      private var m_featureManager:AnimalSanctuaryV2Manager;
      
      private var m_featureName:String;
      
      public function AnimalSanctuaryV2MapTrigger(itemName:String, stateToSet:String = "built_0")
      {
         super(itemName,stateToSet);
      }
      
      public function updateState(e:Event = null) : void
      {
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         m_toolTipOverride = "Animal Sanctuary";
         super.onMouseOver(event);
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.updateState();
      }
      
      override public function onClick() : void
      {
         this.m_featureName = AnimalSanctuaryV2Manager.FEATURE_NAME;
         this.m_featureManager = AnimalSanctuaryV2Manager.getInstance(this.m_featureName);
         if(this.m_featureManager)
         {
            this.m_featureManager.showMainUI();
            StatsManager.count("Offboard Asset","Clicks","Widgets.Windows::AnimalSanctuaryV2");
         }
         super.onClick();
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}


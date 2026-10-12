package Classes
{
   import Engine.Managers.StatsManager;
   import Managers.AnimalSanctuaryManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuaryMapTrigger extends MapTrigger
   {
      
      public static const STATE_IDLE:String = "built_0";
      
      private var m_featureManager:AnimalSanctuaryManager;
      
      private var m_featureName:String;
      
      public function AnimalSanctuaryMapTrigger(itemName:String, stateToSet:String = "built_0")
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
         this.m_featureName = AnimalSanctuaryManager.FEATURE_NAME;
         this.m_featureManager = AnimalSanctuaryManager.getInstance(this.m_featureName);
         if(this.m_featureManager)
         {
            this.m_featureManager.showMainUI();
            StatsManager.count("Offboard Asset","Clicks","Widgets.Windows::AnimalSanctuary");
         }
         super.onClick();
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}


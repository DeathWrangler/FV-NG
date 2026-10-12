package Classes
{
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.OlyInnovationManager;
   import MyLife.Events.GlobalEventManager;
   import Widgets.Windows.OlyInnovationMapTriggerWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class OlyInnovationMapTrigger extends MapTrigger
   {
      
      protected static const HARVEST_ALL_ANIMALS:String = "harvestallanimals";
      
      private static const WHAT_IS_THIS:String = "whatIsThis";
      
      private var m_dialogUrl:String;
      
      public function OlyInnovationMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
         m_menuItems.push({
            "label":"Harvest all animals",
            "action":HARVEST_ALL_ANIMALS
         });
         m_menuItems.push({
            "label":"What is this?",
            "action":WHAT_IS_THIS
         });
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         super.loadXmlData(xmlData);
         this.updateState(null);
         var dialogUrlXML:XMLList = xmlData.child("dialogUrl");
         this.m_dialogUrl = dialogUrlXML[0].toString();
         GlobalEventManager.getInstance().addEventListener(OlyInnovationManager.UPDATE_STATE,this.updateState);
      }
      
      public function updateState(e:Event) : void
      {
         if(OlyInnovationManager.getInstance().isMapTriggeractive())
         {
            setState("built_1");
         }
         else
         {
            setState("built_0");
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         var timeLeft:String = null;
         if(OlyInnovationManager.getInstance().isMapTriggeractive() == false)
         {
            timeLeft = OlyInnovationManager.getInstance().getTimeLeftForNextHavest();
            m_toolTipOverride = "Heromenes ready to harvest animals in " + timeLeft;
            super.onMouseOver(event);
         }
         else
         {
            m_toolTipOverride = "Heromenes is ready. Click to harvest all animals";
            super.onMouseOver(event);
         }
      }
      
      override public function onClick() : void
      {
         UI.displayMenu(m_menuItems,this.onMenuClick);
         FarmStatsManager.count("olympus_innovation","heromenes","off_board_asset","click");
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var timeLeft:String = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case WHAT_IS_THIS:
                  this.onWhatIsThisClick(event);
                  break;
               case HARVEST_ALL_ANIMALS:
                  timeLeft = OlyInnovationManager.getInstance().getTimeLeftForNextHavest();
                  if(OlyInnovationManager.getInstance().isMapTriggeractive() && parseInt(timeLeft) == 0)
                  {
                     this.harvestAll(null);
                  }
                  else
                  {
                     UI.displayMessage("Heromenes isn’t ready yet. Come back in " + timeLeft + " for his help",GenericPopup.TYPE_OK);
                  }
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      private function harvestAll(e:Event) : void
      {
         OlyInnovationManager.getInstance().harvestAllAnimals();
      }
      
      private function onWhatIsThisClick(event:MouseEvent) : void
      {
         UI.displayPopup(new OlyInnovationMapTriggerWindow(null,this.m_dialogUrl));
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}


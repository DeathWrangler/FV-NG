package Widgets.Windows.MOTD
{
   import Classes.MultiRewardTreasurePayerBundleConstructionBuilding;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Managers.ItemFinderManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MultiRewardTreasurePayerBundleMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      private static const OPEN_UI_DELAY:int = 3200;
      
      private var m_timer:Timer;
      
      private var m_item:Object;
      
      public function MultiRewardTreasurePayerBundleMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var worldType:String = null;
         var percentText:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow") && Boolean(m_window["mainWindow"].hasOwnProperty("percent_tf")))
         {
            worldType = Global.worldManager.currentWorldType;
            percentText = "";
            if(WorldSeasonsManager.getInstance().isEAWeek(worldType))
            {
               percentText = "30%";
            }
            else if(WorldSeasonsManager.getInstance().isGAFirstWeek(worldType))
            {
               percentText = "20%";
            }
            new ZwTextField(m_window.mainWindow.percent_tf,percentText);
         }
         UI.stopPopups(true);
      }
      
      override protected function onClose(event:Event) : void
      {
         UI.stopPopups(false);
         super.onClose(event);
         close();
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         var itemName:String = null;
         var tileArray:Array = null;
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
         if(Boolean(currentMOTD.hasOwnProperty(CUSTOM_ACTION_PARAMS)) && Boolean(currentMOTD[CUSTOM_ACTION_PARAMS].hasOwnProperty("itemList")) && Boolean(currentMOTD[CUSTOM_ACTION_PARAMS]["itemList"].hasOwnProperty("item")))
         {
            for each(itemName in currentMOTD[CUSTOM_ACTION_PARAMS]["itemList"]["item"])
            {
               tileArray = Global.world.getObjectsByName(itemName);
               if(Boolean(tileArray) && tileArray.length > 0)
               {
                  this.m_item = tileArray[0];
                  ItemFinderManager.getInstance().highlightWorldItems(itemName);
                  this.m_timer = new Timer(OPEN_UI_DELAY,1);
                  this.m_timer.addEventListener(TimerEvent.TIMER,this.showUI);
                  this.m_timer.start();
                  InputManager.disableInput();
                  UI.stopPopups(true);
                  break;
               }
            }
         }
      }
      
      private function showUI(event:Event = null) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.showUI);
         }
         InputManager.enableInput();
         UI.stopPopups(false);
         if(this.m_item is MultiRewardTreasurePayerBundleConstructionBuilding)
         {
            (this.m_item as MultiRewardTreasurePayerBundleConstructionBuilding).onClick();
         }
      }
   }
}


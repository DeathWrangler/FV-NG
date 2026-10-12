package Widgets.Windows.MOTD
{
   import Classes.Constants.ZLocConstants;
   import Classes.MultiRewardTreasurePayerLandBundleConstructionBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Managers.ItemFinderManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class LandBundleMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private static const OPEN_UI_DELAY:int = 3200;
      
      public static const KEY_SAVED_FINAL_REWARD_RECEIVED:String = "k11";
      
      private var m_timer:Timer;
      
      private var m_item:Object;
      
      private var m_famepoints_mc:MovieClip;
      
      private var m_worldName:String = "PUMPKIN";
      
      private var m_bundleFirstTile:String = "xpu_rubbletreasure_payer8";
      
      private var endDate:String = "11/13/2020";
      
      public var BUNDLE_TILES_NAME_ARRAY:Array = new Array("xpu_rubbletreasure_payer8","xpu_rubbletreasure_payer9","xpu_rubbletreasure_payer10","xpu_rubbletreasure_payer11");
      
      internal var worldType:String = "pumpkin";
      
      public function LandBundleMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var days:int = 0;
         super.postLoadComplete();
         if(m_window.mainWindow["famepoints_mc"])
         {
            this.m_famepoints_mc = m_window["mainWindow"].famepoints_mc as MovieClip;
         }
         if(m_currentMOTD.motdSeenFlag == "MOTD_LAND_BUNDLE_" + this.m_worldName + "_EXPIRE")
         {
            new ZwTextField(m_window["mainWindow"]["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_body"));
            days = (FarmGameUtil.synchronizedDateToNumber(this.endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_DAY;
            if(days == 0)
            {
               new ZwTextField(m_window["mainWindow"]["body2_tf"],"Hurry! Offer Expires Today!");
            }
            else if(days == 1)
            {
               new ZwTextField(m_window["mainWindow"]["body2_tf"],"Hurry! Offer expires in 1 day!");
            }
            else
            {
               new ZwTextField(m_window["mainWindow"]["body2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_body2",{"dayNum":days.toString()}));
            }
         }
         else
         {
            new ZwTextField(m_window["mainWindow"]["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_body"));
            new ZwTextField(m_window["mainWindow"]["body2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_body2"));
         }
         UI.stopPopups(true);
      }
      
      override protected function onClose(event:Event) : void
      {
         UI.stopPopups(false);
         super.onClose(event);
         close();
      }
      
      public function get lockedTilesArray() : Array
      {
         var tilename:String = null;
         var tileObjects:Array = null;
         var lockedTiles:Array = new Array();
         for each(tilename in this.BUNDLE_TILES_NAME_ARRAY)
         {
            tileObjects = Global.world.getObjectsByName(tilename);
            if(Boolean(tileObjects) && tileObjects.length > 0)
            {
               lockedTiles.push(tilename);
            }
         }
         return lockedTiles;
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
         if(Global.worldManager.currentWorldType != this.worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            ItemFinderManager.getInstance().highlightMultipleWorldItems(this.lockedTilesArray);
            this.m_item = Global.world.getObjectsByName(this.m_bundleFirstTile)[0];
            this.m_timer = new Timer(OPEN_UI_DELAY,1);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.showUI);
            this.m_timer.start();
            InputManager.disableInput();
            UI.stopPopups(true);
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
         if(this.m_item is MultiRewardTreasurePayerLandBundleConstructionBuilding)
         {
            (this.m_item as MultiRewardTreasurePayerLandBundleConstructionBuilding).onClick();
         }
      }
   }
}


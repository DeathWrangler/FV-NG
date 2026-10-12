package Display.HUD
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Events.FarmGameWorldEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class TravelDropDownCell
   {
      
      private static const BUTTON_STATE_NORMAL_FRAME:int = 1;
      
      private static const BUTTON_STATE_OVER_FRAME:int = 2;
      
      private static const BUTTON_STATE_DOWN_FRAME:int = 3;
      
      private static const DEFAULT_LOCATION_ICON_PATH:String = "assets/hud/LocationIcons/icon_home_travelMenu.png";
      
      private var m_worldType:String;
      
      private var m_cellButton:MovieClip;
      
      private var m_travelNameDisplay:TravelNameDisplay;
      
      public function TravelDropDownCell(worldType:String, cellButton:MovieClip, travelNameDisplay:TravelNameDisplay)
      {
         var locationIconPath:String = null;
         var locationIcon:DisplayObject = null;
         var locationBGPath:String = null;
         var locationBG:DisplayObject = null;
         super();
         this.m_worldType = worldType;
         this.m_cellButton = cellButton;
         this.m_cellButton.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.m_cellButton.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.m_cellButton.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.m_cellButton.addEventListener(MouseEvent.CLICK,this.onClicked);
         this.m_cellButton.gotoAndStop(BUTTON_STATE_NORMAL_FRAME);
         this.m_travelNameDisplay = travelNameDisplay;
         if(this.m_cellButton.generic_tf is TextField)
         {
            this.m_cellButton.generic_tf.text = ZLocUtils.t("FarmGame","FarmTravel_" + this.m_worldType);
            this.m_cellButton.generic_tf.mouseEnabled = false;
         }
         var worldConfig:Object = Global.worldSettingsManager.getConfigByWorld(this.m_worldType);
         var hudSkinConfig:HUDSkinConfig = null;
         if(Boolean(worldConfig) && Boolean(worldConfig.hudSkinConfig))
         {
            hudSkinConfig = worldConfig.hudSkinConfig as HUDSkinConfig;
         }
         if(this.m_cellButton.icon_mc is MovieClip)
         {
            if(hudSkinConfig)
            {
               locationIconPath = hudSkinConfig.travelDropDownIconPath;
               if(!locationIconPath)
               {
                  locationIconPath = DEFAULT_LOCATION_ICON_PATH;
               }
               locationIcon = LoadingManager.load(Global.getAssetURL(locationIconPath));
               this.m_cellButton.icon_mc.addChild(locationIcon);
            }
         }
         if(this.m_cellButton.background_mc is MovieClip)
         {
            if(hudSkinConfig)
            {
               locationBGPath = hudSkinConfig.travelDropDownBGPath;
               if(locationBGPath)
               {
                  locationBG = LoadingManager.load(Global.getAssetURL(locationBGPath));
                  this.m_cellButton.background_mc.addChild(locationBG);
               }
            }
         }
      }
      
      private function onMouseOver(event:Event) : void
      {
         this.m_cellButton.gotoAndStop(BUTTON_STATE_OVER_FRAME);
      }
      
      private function onMouseOut(event:Event) : void
      {
         this.m_cellButton.gotoAndStop(BUTTON_STATE_NORMAL_FRAME);
      }
      
      private function onMouseDown(event:Event) : void
      {
         this.m_cellButton.gotoAndStop(BUTTON_STATE_DOWN_FRAME);
      }
      
      private function onClicked(event:Event) : void
      {
         if(Global.worldManager.isWorldSwapStable)
         {
            this.m_cellButton.gotoAndStop(BUTTON_STATE_NORMAL_FRAME);
            Global.worldManager.showTravelConfirmation(this.m_worldType);
         }
      }
      
      private function executeTravel(shouldFreezeFarm:Boolean = true) : void
      {
         if(Global.worldManager.isWorldSwapStable)
         {
            this.m_travelNameDisplay.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.WORLD_SWAP));
            Global.worldManager.swapFarm(this.m_worldType,shouldFreezeFarm);
         }
      }
      
      public function release() : void
      {
         this.m_cellButton.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.m_cellButton.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.m_cellButton.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.m_cellButton.removeEventListener(MouseEvent.CLICK,this.onClicked);
      }
   }
}


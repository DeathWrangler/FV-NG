package Display.HUD
{
   import Classes.Constants.WorldsConstants;
   import Managers.WorldSeasonsManager;
   
   public class HUDSkinConfig
   {
      
      public static const BUTTON_STATE_NORMAL:String = "normal";
      
      public static const BUTTON_STATE_OVER:String = "over";
      
      public static const BUTTON_STATE_DOWN:String = "down";
      
      private var m_worldType:String;
      
      private var m_hudSkinSwfPath:String;
      
      private var m_hudSkinNeighborBGOffsetY:Number = 0;
      
      private var m_instantGrowItemVisual:String = null;
      
      private var m_travelNameDisplaySwfPath:String;
      
      private var m_xpMeterConfig:ScoreMeterConfig = null;
      
      private var m_worldScoreConfig:ScoreMeterConfig = null;
      
      private var m_worldScore2Config:ScoreMeterConfig = null;
      
      private var m_travelDropDownIconPath:String;
      
      private var m_travelDropDownBGPath:String;
      
      private var m_currencyMeterConfig:Object = null;
      
      private var m_travelDropDownListPriority:int = 0;
      
      private var m_worldSpecificMarketClassLock:Array = null;
      
      private var m_friendBarBackground:String;
      
      private var m_singleArrowStates:Object;
      
      private var m_doubleArrowStates:Object;
      
      private var m_arrowLineStates:Object;
      
      private var m_friendSlotStates:Object;
      
      private var m_messageSignButtonStates:Object;
      
      private var m_zoomOutButtonStates:Object;
      
      private var m_zoomInButtonStates:Object;
      
      private var m_cameraButtonStates:Object;
      
      private var m_zcacheButtonStates:Object;
      
      private var m_fullScreenButtonStates:Object;
      
      private var m_optionsBackground:String;
      
      private var m_graphicsButtonStates:Object;
      
      private var m_sfxButtonStates:Object;
      
      private var m_musicButtonStates:Object;
      
      private var m_menus:Array = null;
      
      private var m_singleTravelDestination:String;
      
      public function HUDSkinConfig(worldType:String)
      {
         super();
         this.m_worldType = worldType;
      }
      
      public function get worldType() : String
      {
         return this.m_worldType;
      }
      
      public function loadFromXML(hudConfigXml:XML) : Boolean
      {
         var worldScoreMeters:XMLList = null;
         var menuXML:XML = null;
         var menuName:String = null;
         var currentSeason:int = 0;
         var hudAssetsXml:XML = null;
         var result:Boolean = false;
         if(hudConfigXml)
         {
            if(hudConfigXml.hasOwnProperty("instantGrowItemVisual"))
            {
               this.m_instantGrowItemVisual = hudConfigXml.instantGrowItemVisual.@name;
            }
            if(hudConfigXml.hasOwnProperty("travelNameDisplay"))
            {
               this.m_travelNameDisplaySwfPath = hudConfigXml.travelNameDisplay.@path;
            }
            if(hudConfigXml.hasOwnProperty("travelDropDownIcon"))
            {
               this.m_travelDropDownIconPath = hudConfigXml.travelDropDownIcon.@path;
            }
            if(hudConfigXml.hasOwnProperty("travelDropDownBG"))
            {
               this.m_travelDropDownBGPath = hudConfigXml.travelDropDownBG.@path;
            }
            if(hudConfigXml.hasOwnProperty("listPriority"))
            {
               this.m_travelDropDownListPriority = parseInt(hudConfigXml.listPriority.@value);
            }
            if(hudConfigXml.hasOwnProperty("travelSingleDestination"))
            {
               this.m_singleTravelDestination = hudConfigXml.travelSingleDestination.toString();
            }
            if(hudConfigXml.hasOwnProperty("showOnlyWorldMarketClassLock"))
            {
               this.m_worldSpecificMarketClassLock = this.parseWorldClassLock(hudConfigXml);
            }
            if(hudConfigXml.hasOwnProperty("menus"))
            {
               this.m_menus = new Array();
               for each(menuXML in hudConfigXml.menus.menu)
               {
                  menuName = menuXML.@name;
                  this.m_menus[menuName] = new HUDSkinConfigMenu(menuXML);
               }
            }
            this.m_currencyMeterConfig = {
               "path":"assets/hud/coin_HUD_Meter.swf",
               "x":48,
               "y":9,
               "trackClicks":"false"
            };
            if(hudConfigXml.hasOwnProperty("currencyMeter"))
            {
               if(hudConfigXml.currencyMeter.hasOwnProperty("@path"))
               {
                  this.m_currencyMeterConfig["path"] = hudConfigXml.currencyMeter.@path[0].toString();
               }
               if(hudConfigXml.currencyMeter.hasOwnProperty("@x"))
               {
                  this.m_currencyMeterConfig["x"] = parseInt(hudConfigXml.currencyMeter.@x[0].toString());
               }
               if(hudConfigXml.currencyMeter.hasOwnProperty("@y"))
               {
                  this.m_currencyMeterConfig["y"] = parseInt(hudConfigXml.currencyMeter.@y[0].toString());
               }
               if(hudConfigXml.currencyMeter.hasOwnProperty("@trackClicks"))
               {
                  this.m_currencyMeterConfig["trackClicks"] = hudConfigXml.currencyMeter.@trackClicks[0].toString() == "true" ? true : false;
               }
            }
            if(hudConfigXml.hasOwnProperty("xpMeter"))
            {
               this.m_xpMeterConfig = new ScoreMeterConfig(hudConfigXml["xpMeter"][0]);
            }
            else
            {
               this.m_xpMeterConfig = new ScoreMeterConfig();
            }
            worldScoreMeters = null;
            if(hudConfigXml.hasOwnProperty("worldScoreMeter"))
            {
               worldScoreMeters = hudConfigXml["worldScoreMeter"];
            }
            if(Boolean(worldScoreMeters) && Boolean(worldScoreMeters[0]))
            {
               this.m_worldScoreConfig = new ScoreMeterConfig(worldScoreMeters[0][0]);
            }
            if(Boolean(worldScoreMeters) && Boolean(worldScoreMeters[1]))
            {
               this.m_worldScore2Config = new ScoreMeterConfig(worldScoreMeters[1][0]);
            }
            if(hudConfigXml.hasOwnProperty("hudAssets"))
            {
               currentSeason = WorldSeasonsManager.getInstance().getCurrentSeason(this.m_worldType);
               hudAssetsXml = null;
               if(this.m_worldType == WorldsConstants.WORLD_ID_AVALON && currentSeason == WorldSeasonsManager.SEASON_TWO)
               {
                  hudAssetsXml = hudConfigXml.hudAssets[1];
               }
               else
               {
                  hudAssetsXml = hudConfigXml.hudAssets[0];
               }
               this.m_hudSkinSwfPath = hudAssetsXml.@path;
               if(hudAssetsXml.hasOwnProperty("@neighborBarOffsetY"))
               {
                  this.m_hudSkinNeighborBGOffsetY = Number(hudAssetsXml.@neighborBarOffsetY);
               }
               if(hudAssetsXml.hasOwnProperty("friendBarBackground"))
               {
                  this.m_friendBarBackground = hudAssetsXml.friendBarBackground;
               }
               if(hudAssetsXml.hasOwnProperty("friendBarSingleArrow"))
               {
                  this.m_singleArrowStates = this.parseButtonStates(hudAssetsXml.friendBarSingleArrow[0]);
               }
               if(hudAssetsXml.hasOwnProperty("friendBarDoubleArrow"))
               {
                  this.m_doubleArrowStates = this.parseButtonStates(hudAssetsXml.friendBarDoubleArrow[0]);
               }
               if(hudAssetsXml.hasOwnProperty("friendBarArrowLine"))
               {
                  this.m_arrowLineStates = this.parseButtonStates(hudAssetsXml.friendBarArrowLine[0]);
               }
               if(hudAssetsXml.hasOwnProperty("friendBarSlotBackground"))
               {
                  this.m_friendSlotStates = this.parseNeighborSlotButtonStates(hudAssetsXml.friendBarSlotBackground[0]);
               }
               if(hudAssetsXml.hasOwnProperty("messageSignButton"))
               {
                  this.m_messageSignButtonStates = this.parseButtonStates(hudAssetsXml.messageSignButton[0]);
               }
               if(hudAssetsXml.hasOwnProperty("zoomOutButton"))
               {
                  this.m_zoomOutButtonStates = this.parseButtonStates(hudAssetsXml.zoomOutButton[0]);
               }
               if(hudAssetsXml.hasOwnProperty("zoomInButton"))
               {
                  this.m_zoomInButtonStates = this.parseButtonStates(hudAssetsXml.zoomInButton[0]);
               }
               if(hudAssetsXml.hasOwnProperty("cameraButton"))
               {
                  this.m_cameraButtonStates = this.parseButtonStates(hudAssetsXml.cameraButton[0]);
               }
               if(hudAssetsXml.hasOwnProperty("zCacheButton"))
               {
                  this.m_zcacheButtonStates = this.parseButtonStates(hudAssetsXml.zCacheButton[0]);
               }
               if(hudAssetsXml.hasOwnProperty("fullScreenButton"))
               {
                  this.m_fullScreenButtonStates = this.parseButtonStates(hudAssetsXml.fullScreenButton[0]);
               }
               if(hudAssetsXml.hasOwnProperty("optionsBackground"))
               {
                  this.m_optionsBackground = hudAssetsXml.optionsBackground;
               }
               if(hudAssetsXml.hasOwnProperty("graphicsButton"))
               {
                  this.m_graphicsButtonStates = this.parseButtonStates(hudAssetsXml.graphicsButton[0]);
               }
               if(hudAssetsXml.hasOwnProperty("sfxButton"))
               {
                  this.m_sfxButtonStates = this.parseButtonStates(hudAssetsXml.sfxButton[0]);
               }
               if(hudAssetsXml.hasOwnProperty("musicButton"))
               {
                  this.m_musicButtonStates = this.parseButtonStates(hudAssetsXml.musicButton[0]);
               }
               result = true;
            }
         }
         return result;
      }
      
      private function parseWorldClassLock(hudConfigXml:XML) : Array
      {
         var xML:XML = null;
         var classLockArray:Array = null;
         if(hudConfigXml.hasOwnProperty("showOnlyWorldMarketClassLock"))
         {
            classLockArray = new Array();
            for each(xML in hudConfigXml.showOnlyWorldMarketClassLock.className)
            {
               classLockArray.push(xML.toString());
            }
         }
         return classLockArray;
      }
      
      private function parseButtonStates(buttonXml:XML) : Object
      {
         var result:Object = {};
         if(buttonXml)
         {
            if(buttonXml.hasOwnProperty(BUTTON_STATE_NORMAL))
            {
               result[BUTTON_STATE_NORMAL] = buttonXml[BUTTON_STATE_NORMAL][0].toString();
            }
            if(buttonXml.hasOwnProperty(BUTTON_STATE_OVER))
            {
               result[BUTTON_STATE_OVER] = buttonXml[BUTTON_STATE_OVER][0].toString();
            }
            if(buttonXml.hasOwnProperty(BUTTON_STATE_DOWN))
            {
               result[BUTTON_STATE_DOWN] = buttonXml[BUTTON_STATE_DOWN][0].toString();
            }
         }
         return result;
      }
      
      private function parseNeighborSlotButtonStates(buttonXml:XML) : Object
      {
         var result:Object = this.parseButtonStates(buttonXml);
         if(buttonXml.hasOwnProperty("border"))
         {
            result["border"] = buttonXml["border"][0].toString();
         }
         if(buttonXml.hasOwnProperty("borderOver"))
         {
            result["borderOver"] = buttonXml["borderOver"][0].toString();
         }
         return result;
      }
      
      public function get hudSkinSwfPath() : String
      {
         return this.m_hudSkinSwfPath;
      }
      
      public function get worldSpecificMarketClassLock() : Array
      {
         return this.m_worldSpecificMarketClassLock;
      }
      
      public function get hudSkinNeighborBGOffsetY() : Number
      {
         return this.m_hudSkinNeighborBGOffsetY;
      }
      
      public function get instantGrowItemVisual() : String
      {
         return this.m_instantGrowItemVisual;
      }
      
      public function get travelNameDisplaySwfPath() : String
      {
         return this.m_travelNameDisplaySwfPath;
      }
      
      public function get travelDropDownIconPath() : String
      {
         return this.m_travelDropDownIconPath;
      }
      
      public function get travelDropDownBGPath() : String
      {
         return this.m_travelDropDownBGPath;
      }
      
      public function get currencyMeterConfig() : Object
      {
         return this.m_currencyMeterConfig;
      }
      
      public function get travelDropDownListPriority() : int
      {
         return this.m_travelDropDownListPriority;
      }
      
      public function get friendBarBackground() : String
      {
         return this.m_friendBarBackground;
      }
      
      public function get singleArrowStates() : Object
      {
         return this.m_singleArrowStates;
      }
      
      public function get doubleArrowStates() : Object
      {
         return this.m_doubleArrowStates;
      }
      
      public function get arrowLineStates() : Object
      {
         return this.m_arrowLineStates;
      }
      
      public function get friendSlotStates() : Object
      {
         return this.m_friendSlotStates;
      }
      
      public function get messageSignButtonStates() : Object
      {
         return this.m_messageSignButtonStates;
      }
      
      public function get zoomOutButtonStates() : Object
      {
         return this.m_zoomOutButtonStates;
      }
      
      public function get zoomInButtonStates() : Object
      {
         return this.m_zoomInButtonStates;
      }
      
      public function get cameraButtonStates() : Object
      {
         return this.m_cameraButtonStates;
      }
      
      public function get zCacheButtonStates() : Object
      {
         return this.m_zcacheButtonStates;
      }
      
      public function get fullScreenButtonStates() : Object
      {
         return this.m_fullScreenButtonStates;
      }
      
      public function get optionsBackground() : String
      {
         return this.m_optionsBackground;
      }
      
      public function get graphicsButtonStates() : Object
      {
         return this.m_graphicsButtonStates;
      }
      
      public function get sfxButtonStates() : Object
      {
         return this.m_sfxButtonStates;
      }
      
      public function get musicButtonStates() : Object
      {
         return this.m_musicButtonStates;
      }
      
      public function getMenuByName(name:String) : HUDSkinConfigMenu
      {
         var result:HUDSkinConfigMenu = null;
         if(Boolean(this.m_menus) && this.m_menus.hasOwnProperty(name))
         {
            result = this.m_menus[name];
         }
         return result;
      }
      
      public function get worldScoreConfig() : ScoreMeterConfig
      {
         return this.m_worldScoreConfig;
      }
      
      public function get worldScore2Config() : ScoreMeterConfig
      {
         return this.m_worldScore2Config;
      }
      
      public function get xpBarConfig() : ScoreMeterConfig
      {
         return this.m_xpMeterConfig;
      }
      
      public function get singleTravelDestination() : String
      {
         return this.m_singleTravelDestination;
      }
   }
}


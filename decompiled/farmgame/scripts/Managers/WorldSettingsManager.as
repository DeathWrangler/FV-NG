package Managers
{
   import Classes.Constants.WorldsConstants;
   import Display.HUD.HUDSkinConfig;
   import Engine.Classes.Viewport;
   import Engine.Helpers.Vector2;
   import flash.geom.Point;
   
   public class WorldSettingsManager
   {
      
      private static const ONLOADDEFAULTS_KEY:String = "onLoadDefaults";
      
      private static const ONLOADDEFAULTS_DEFAULT_KEY:String = "default";
      
      private static const highlightItems:Object = {
         "2":["xjp_bigbuildable","xjp_craftingcottage","xjp_elitehorses"],
         "3":[],
         "4":[]
      };
      
      private var m_rawXml:XML;
      
      private var m_isXmlParsed:Boolean = false;
      
      private var m_worlds:Object;
      
      public function WorldSettingsManager()
      {
         super();
      }
      
      public function set settingsXml(newSettingsXml:XML) : void
      {
         this.m_rawXml = newSettingsXml;
         this.m_isXmlParsed = false;
      }
      
      public function getConfigByWorld(worldType:String) : Object
      {
         this.parseConfig();
         return this.m_worlds[worldType];
      }
      
      public function getWorldSpecificAvatarPositionBySeason(seasonNumber:int = 0) : Point
      {
         var avatarPosition:Point = null;
         var worldConfig:Object = Global.worldSettingsManager.getConfigByWorld(Global.worldManager.currentWorldType);
         if(Boolean(seasonNumber && worldConfig != null) && Boolean(worldConfig.avatarPositions != null) && worldConfig.avatarPositions[seasonNumber - 1] != null)
         {
            avatarPosition = new Point();
            avatarPosition.x = worldConfig.avatarPositions[seasonNumber - 1].x;
            avatarPosition.y = worldConfig.avatarPositions[seasonNumber - 1].y;
         }
         else if(seasonNumber == 0 && worldConfig != null && worldConfig.avatarPositions != null && worldConfig.avatarPositions[0] != null)
         {
            avatarPosition = new Point();
            avatarPosition.x = worldConfig.avatarPositions[0].x;
            avatarPosition.y = worldConfig.avatarPositions[0].y;
         }
         return avatarPosition;
      }
      
      public function getWorldSpecificOutsideImageDimensions() : Point
      {
         var outsideImageDimensions:Point = new Point();
         var worldConfig:Object = Global.worldSettingsManager.getConfigByWorld(Global.worldManager.currentWorldType);
         if(worldConfig != null && worldConfig.outsideImageVisibleDimensions != null)
         {
            outsideImageDimensions.x = worldConfig.outsideImageVisibleDimensions.width;
            outsideImageDimensions.y = worldConfig.outsideImageVisibleDimensions.height;
         }
         return outsideImageDimensions;
      }
      
      public function getWorldSpecificPlaneItemName(worldType:String, failoverDefault:String = null) : String
      {
         var airplaneName:String = failoverDefault;
         var worldConfig:Object = Global.worldSettingsManager.getConfigByWorld(worldType);
         if(worldConfig != null && worldConfig.hudSkinConfig != null && worldConfig.hudSkinConfig.instantGrowItemVisual != null)
         {
            airplaneName = worldConfig.hudSkinConfig.instantGrowItemVisual;
         }
         return airplaneName;
      }
      
      public function getOnLoadDefaultsZoom(worldType:String, squares:String) : Number
      {
         var onDefaultsSquares:Object = null;
         this.parseConfig();
         var onDefaultSettings:Object = this.m_worlds[worldType][ONLOADDEFAULTS_KEY];
         var result:Number = Number(onDefaultSettings[ONLOADDEFAULTS_DEFAULT_KEY].zoom);
         if(squares in onDefaultSettings)
         {
            onDefaultsSquares = onDefaultSettings[squares];
            if("zoom" in onDefaultsSquares)
            {
               result = Number(onDefaultSettings[squares].zoom);
            }
         }
         return result;
      }
      
      public function zoomCenterViewportPostWorldLoad() : void
      {
         var gridWidth:String = Global.world.getGridWidth().toString();
         var viewport:Viewport = GlobalEngine.viewport;
         viewport.setZoom(this.getOnLoadDefaultsZoom(Global.worldManager.currentWorldType,gridWidth));
         viewport.centerViewport();
         var defaultScrollPos:Vector2 = this.getOnLoadDefaultsScrollOffset(Global.worldManager.currentWorldType,gridWidth);
         var curScrollPos:Vector2 = viewport.getScrollPosition();
         curScrollPos.x += defaultScrollPos.x;
         curScrollPos.y += defaultScrollPos.y;
         viewport.setScrollPosition(curScrollPos);
         this.highlightItemForJapan(WorldSeasonsManager.getInstance().getCurrentSeason(Global.worldManager.currentWorldType));
         if(Global.selectedAvatar)
         {
            Global.selectedAvatar.centerOn();
         }
      }
      
      public function highlightItemForJapan(currentSeason:int) : void
      {
         var currentWorld:String = Global.worldManager.currentWorldType;
         if(currentWorld == WorldsConstants.WORLD_ID_JAPAN && WorldSeasonsManager.getInstance().nextSeasonUnlock)
         {
            if(highlightItems[currentSeason])
            {
               ItemFinderManager.getInstance().highlightMultipleWorldItems(highlightItems[currentSeason],false);
            }
            WorldSeasonsManager.getInstance().nextSeasonUnlock = false;
         }
      }
      
      public function getOnLoadDefaultsScrollOffset(worldType:String, squares:String) : Vector2
      {
         var onDefaultsSquares:Object = null;
         this.parseConfig();
         var onDefaultSettings:Object = this.m_worlds[worldType][ONLOADDEFAULTS_KEY];
         var xOffset:Number = Number(onDefaultSettings[ONLOADDEFAULTS_DEFAULT_KEY].xScrollOffset);
         var yOffset:Number = Number(onDefaultSettings[ONLOADDEFAULTS_DEFAULT_KEY].yScrollOffset);
         if(squares in onDefaultSettings)
         {
            onDefaultsSquares = onDefaultSettings[squares];
            if("xScrollOffset" in onDefaultsSquares)
            {
               xOffset = Number(onDefaultsSquares.xScrollOffset);
            }
            if("yScrollOffset" in onDefaultsSquares)
            {
               yOffset = Number(onDefaultsSquares.yScrollOffset);
            }
         }
         return new Vector2(xOffset,yOffset);
      }
      
      private function parseConfig() : void
      {
         var allWorldsXmlList:XMLList = null;
         var worldXml:XML = null;
         var worldType:String = null;
         var hudSkinConfig:HUDSkinConfig = null;
         var hudSkinConfigXml:XML = null;
         var loadSuccess:Boolean = false;
         var actionMenuXML:XMLList = null;
         var defaultZoom:Number = NaN;
         var defaultXScrollOffset:Number = NaN;
         var defaultYScrollOffset:Number = NaN;
         var uniqeBackground:String = null;
         var uniqeBackground2:String = null;
         var outsideDim:XML = null;
         var tempObject:XML = null;
         var i:int = 0;
         var superBuildingsXml:XMLList = null;
         var buildingXml:XML = null;
         var buildingName:String = null;
         var max:int = 0;
         var title:String = null;
         var defaultTag:XML = null;
         var tmpObj:Object = null;
         var squaresSaveKey:String = null;
         var attr:XML = null;
         var tmpName:String = null;
         var tmpValue:String = null;
         if(!this.m_isXmlParsed && Boolean(this.m_rawXml))
         {
            this.m_worlds = new Object();
            allWorldsXmlList = this.m_rawXml.world;
            for each(worldXml in allWorldsXmlList)
            {
               worldType = worldXml.@name;
               if(worldType)
               {
                  this.m_worlds[worldType] = new Object();
                  hudSkinConfig = new HUDSkinConfig(worldType);
                  hudSkinConfigXml = worldXml.hudSkinConfig[0];
                  loadSuccess = hudSkinConfig.loadFromXML(hudSkinConfigXml);
                  if(loadSuccess)
                  {
                     this.m_worlds[worldType].hudSkinConfig = hudSkinConfig;
                  }
                  if(worldXml.hasOwnProperty("outsideImageVisibleDimensions"))
                  {
                     outsideDim = worldXml.outsideImageVisibleDimensions[0];
                     if(outsideDim.hasOwnProperty("@width") && outsideDim.hasOwnProperty("@height"))
                     {
                        this.m_worlds[worldType].outsideImageVisibleDimensions = new Object();
                        this.m_worlds[worldType].outsideImageVisibleDimensions.width = outsideDim.@width;
                        this.m_worlds[worldType].outsideImageVisibleDimensions.height = outsideDim.@height;
                     }
                  }
                  if(worldXml.hasOwnProperty("avatarPositions"))
                  {
                     if((worldXml.avatarPositions as XMLList).length() > 0)
                     {
                        tempObject = worldXml.avatarPositions[0] as XML;
                        this.m_worlds[worldType].avatarPositions = new Object();
                        for(i = 0; i < (tempObject as XML).children().length(); i++)
                        {
                           this.m_worlds[worldType].avatarPositions[i] = new Object();
                           this.m_worlds[worldType].avatarPositions[i].x = (tempObject.children()[i] as XML).@x;
                           this.m_worlds[worldType].avatarPositions[i].y = (tempObject.children()[i] as XML).@y;
                        }
                     }
                  }
                  if(worldXml.hasOwnProperty("superBuildings"))
                  {
                     if((worldXml.superBuildings as XMLList).length() > 0)
                     {
                        superBuildingsXml = worldXml.superBuildings[0].building;
                        this.m_worlds[worldType].superBuildings = new Object();
                        for each(buildingXml in superBuildingsXml)
                        {
                           buildingName = buildingXml.@name;
                           max = int(buildingXml.@max);
                           title = buildingXml.toString();
                           this.m_worlds[worldType].superBuildings[buildingName] = new Object();
                           this.m_worlds[worldType].superBuildings[buildingName].title = title;
                           this.m_worlds[worldType].superBuildings[buildingName].max = max;
                        }
                     }
                  }
                  actionMenuXML = worldXml.actionMenuConfig as XMLList;
                  if(Boolean(actionMenuXML) && actionMenuXML.length() > 0)
                  {
                     this.m_worlds[worldType].actionMenuConfig = worldXml.actionMenuConfig;
                  }
                  defaultZoom = Global.farmGameSettingsManager.getNumber("defaultZoom");
                  defaultXScrollOffset = 0;
                  defaultYScrollOffset = 0;
                  this.m_worlds[worldType].onLoadDefaults = new Array();
                  if(worldXml.hasOwnProperty("onLoadDefaults"))
                  {
                     if(worldXml.onLoadDefaults.hasOwnProperty("@zoom"))
                     {
                        defaultZoom = parseFloat(worldXml.onLoadDefaults.@zoom);
                     }
                     if(worldXml.onLoadDefaults.hasOwnProperty("@xScrollOffset"))
                     {
                        defaultXScrollOffset = parseFloat(worldXml.onLoadDefaults.@xScrollOffset);
                     }
                     if(worldXml.onLoadDefaults.hasOwnProperty("@yScrollOffset"))
                     {
                        defaultXScrollOffset = parseFloat(worldXml.onLoadDefaults.@yScrollOffset);
                     }
                     for each(defaultTag in worldXml.onLoadDefaults.§default§)
                     {
                        tmpObj = new Object();
                        squaresSaveKey = null;
                        for each(attr in defaultTag.attributes())
                        {
                           tmpName = attr.name();
                           tmpValue = attr.valueOf();
                           tmpObj[tmpName] = tmpValue;
                           if(tmpName == "squares")
                           {
                              squaresSaveKey = tmpValue;
                           }
                        }
                        if(squaresSaveKey)
                        {
                           this.m_worlds[worldType][ONLOADDEFAULTS_KEY][squaresSaveKey] = tmpObj;
                        }
                        else
                        {
                           GlobalEngine.log("WorldSettingsManager","Error parsing <onLoadDefaults>, <default> tag missing squares= attribute.");
                        }
                     }
                  }
                  this.m_worlds[worldType][ONLOADDEFAULTS_KEY][ONLOADDEFAULTS_DEFAULT_KEY] = {
                     "zoom":defaultZoom,
                     "xScrollOffset":defaultXScrollOffset,
                     "yScrollOffset":defaultYScrollOffset
                  };
                  if((worldXml.travelOptionsDialog as XMLList).length() > 0)
                  {
                     this.m_worlds[worldType].travelOptionsDialog = worldXml.travelOptionsDialog[0];
                  }
                  uniqeBackground = worldXml.@marketCardUniqueBackground;
                  if(uniqeBackground)
                  {
                     this.m_worlds[worldType].marketCardUniqueBackground = uniqeBackground;
                  }
                  uniqeBackground2 = worldXml.@marketCardUniqueBackground2;
                  if(uniqeBackground2)
                  {
                     this.m_worlds[worldType].marketCardUniqueBackground2 = uniqeBackground2;
                  }
                  if((worldXml.slotBGImagePath as XMLList).length() > 0)
                  {
                     this.m_worlds[worldType].slotBGImagePath = worldXml.slotBGImagePath[0];
                  }
               }
            }
            this.m_isXmlParsed = true;
         }
      }
      
      public function getSlotBGImagePath(slotType:String, worldType:String = "") : String
      {
         var slotBGImagePath:String = null;
         if(worldType == "")
         {
            worldType = Global.worldManager.currentWorldType;
         }
         if(Boolean(this.m_worlds[worldType].slotBGImagePath) && Boolean(this.m_worlds[worldType].slotBGImagePath[slotType]))
         {
            slotBGImagePath = this.m_worlds[worldType].slotBGImagePath[slotType];
         }
         return slotBGImagePath;
      }
      
      public function getWorldNameByMarketCard(desc:String) : String
      {
         var worlds:XML = null;
         this.parseConfig();
         for each(worlds in this.m_rawXml.world)
         {
            if(worlds.@marketCardUniqueBackground == desc)
            {
               return worlds.@name;
            }
         }
         return null;
      }
   }
}


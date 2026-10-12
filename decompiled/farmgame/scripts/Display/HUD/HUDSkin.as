package Display.HUD
{
   import Classes.Constants.Experiments;
   import Classes.EmbeddedArt;
   import Classes.Friend;
   import Display.FriendBar.FriendBarNav;
   import Display.FriendBar.FriendBarSlot;
   import Display.SpriteButton;
   import Engine.Managers.LoadingManager;
   import Managers.FriendManager;
   import Managers.WorldSeasonsManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class HUDSkin
   {
      
      private static const NEIGHBOR_BAR_SLOT_BACKGROUND_PREFIX:String = "slotBackgroundVariant";
      
      private var m_worldType:String;
      
      private var m_hudSkinConfig:HUDSkinConfig;
      
      private var m_loader:Loader;
      
      public function HUDSkin(worldType:String, hudSkinConfig:HUDSkinConfig)
      {
         super();
         this.m_worldType = worldType;
         this.m_hudSkinConfig = hudSkinConfig;
      }
      
      public function apply() : void
      {
         var seasonNum:int = WorldSeasonsManager.getInstance().getCurrentSeason(this.m_worldType);
         var skinType:String = this.m_worldType + seasonNum;
         if(Global.hud.hudSkinType != skinType && Boolean(this.m_hudSkinConfig.hudSkinSwfPath))
         {
            LoadingManager.load(Global.getAssetURL(this.m_hudSkinConfig.hudSkinSwfPath),this.onHudSwfLoaded,LoadingManager.PRIORITY_HIGH);
         }
      }
      
      private function onHudSwfLoaded(event:Event) : void
      {
         var seasonNum:int = 0;
         this.m_loader = event.target.loader as Loader;
         if(this.m_loader)
         {
            this.applyNeighborBackground();
            this.applyNeighborNavButtons(Global.ui.friendBarLeftNav);
            this.applyNeighborNavButtons(Global.ui.friendBarRightNav);
            this.applyNeighborSlotBackground();
            this.applyCurrencyMeter();
            this.applyXpMeter();
            this.applyWorldScoreMeter();
            this.applyWorldScore2Meter();
            this.applyTravelNameDisplay();
            this.applyMessageSignButton();
            this.applyZoomOutButton();
            this.applyZoomInButton();
            this.applyCameraButton();
            this.applyFullScreenButton();
            this.applyOptionsBackground();
            this.applyGraphicsOptionsButton();
            this.applySfxOptionsButton();
            this.applyMusicOptionsButton();
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TOGGLE_ANIMATION) == Experiments.VARIANT_TOGGLE_ANIMATION)
            {
               LoadingManager.load(Global.getAssetURL("assets/hud/animation_toggle.swf"),this.applyToggleAnimationButton);
            }
            seasonNum = WorldSeasonsManager.getInstance().getCurrentSeason(this.m_worldType);
            Global.hud.hudSkinType = this.m_worldType + seasonNum;
         }
      }
      
      private function applyNeighborBackground() : void
      {
         var neighborBackground:Bitmap = this.generateBitmap(this.m_hudSkinConfig.friendBarBackground);
         if(neighborBackground)
         {
            Global.ui.neighborBackground = neighborBackground;
            Global.ui.setNeighborBackgroundOffsetY(this.m_hudSkinConfig.hudSkinNeighborBGOffsetY);
         }
      }
      
      private function applyNeighborNavButtons(friendBarNav:FriendBarNav) : void
      {
         var singleStepButton:SpriteButton = null;
         var multiStepButton:SpriteButton = null;
         var skipEndButton:SpriteButton = null;
         if(friendBarNav)
         {
            singleStepButton = this.generateSpriteButton(this.m_hudSkinConfig.singleArrowStates);
            if(singleStepButton)
            {
               friendBarNav.singleStepButton = singleStepButton;
            }
            multiStepButton = this.generateSpriteButton(this.m_hudSkinConfig.doubleArrowStates);
            if(multiStepButton)
            {
               friendBarNav.multiStepButton = multiStepButton;
            }
            skipEndButton = this.generateSpriteButton(this.m_hudSkinConfig.arrowLineStates);
            if(skipEndButton)
            {
               friendBarNav.skipEndButton = skipEndButton;
            }
         }
      }
      
      private function applyNeighborSlotBackground() : void
      {
         var slotNormalImageData:BitmapData = null;
         var slotOverImageData:BitmapData = null;
         var slotBorderedNormalImageData:BitmapData = null;
         var slotBorderedOverImageData:BitmapData = null;
         var friendBarSlot:FriendBarSlot = null;
         var friend:Friend = null;
         var imageClass:Class = null;
         var borderedNormal:Bitmap = null;
         var borderedOver:Bitmap = null;
         var noBorderNormal:Bitmap = null;
         var noBorderOver:Bitmap = null;
         var neighborSlotBackgroundStates:Object = this.m_hudSkinConfig.friendSlotStates;
         if(neighborSlotBackgroundStates.hasOwnProperty(HUDSkinConfig.BUTTON_STATE_NORMAL) && neighborSlotBackgroundStates.hasOwnProperty(HUDSkinConfig.BUTTON_STATE_OVER))
         {
            slotNormalImageData = this.generateBitmapData(neighborSlotBackgroundStates[HUDSkinConfig.BUTTON_STATE_NORMAL]);
            slotOverImageData = this.generateBitmapData(neighborSlotBackgroundStates[HUDSkinConfig.BUTTON_STATE_OVER]);
         }
         if(neighborSlotBackgroundStates.hasOwnProperty("border") && neighborSlotBackgroundStates.hasOwnProperty("borderOver"))
         {
            slotBorderedNormalImageData = this.generateBitmapData(neighborSlotBackgroundStates["border"]);
            slotBorderedOverImageData = this.generateBitmapData(neighborSlotBackgroundStates["borderOver"]);
         }
         var neighborBarInactivesVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_NEIGHBORS_BAR_INACTIVE);
         var imageBackground:String = "";
         var friendBarSlots:Array = Global.ui.m_friendBar.slots;
         for each(friendBarSlot in friendBarSlots)
         {
            friend = friendBarSlot.friend as Friend;
            imageClass = EmbeddedArt[imageBackground];
            if(Boolean(neighborBarInactivesVariant == 4) && Boolean(friend) && Boolean(friend.inInactiveExp))
            {
               imageBackground = NEIGHBOR_BAR_SLOT_BACKGROUND_PREFIX + FriendManager.NEIGHBOR_BCKGND_ZZZ;
               imageClass = EmbeddedArt[imageBackground];
               if(imageClass)
               {
                  friendBarSlot.isSpecialFriendSlot = true;
                  friendBarSlot.backgroundNormal = new imageClass() as Bitmap;
               }
            }
            else if(Boolean(friend) && Boolean(friend.isCommunityNeighbor))
            {
               imageBackground = NEIGHBOR_BAR_SLOT_BACKGROUND_PREFIX + "_community";
               imageClass = EmbeddedArt[imageBackground];
               if(imageClass)
               {
                  friendBarSlot.isSpecialFriendSlot = true;
                  friendBarSlot.backgroundNormal = new imageClass() as Bitmap;
               }
            }
            else
            {
               friendBarSlot.isSpecialFriendSlot = false;
               if(Boolean(slotNormalImageData) && Boolean(slotOverImageData))
               {
                  borderedNormal = new Bitmap(slotBorderedNormalImageData);
                  borderedOver = new Bitmap(slotBorderedOverImageData);
                  noBorderNormal = new Bitmap(slotNormalImageData);
                  noBorderOver = new Bitmap(slotOverImageData);
                  friendBarSlot.backgroundNormal = noBorderNormal;
                  friendBarSlot.noBorderBackgroundNormal = noBorderNormal;
                  friendBarSlot.backgroundOver = noBorderOver;
                  friendBarSlot.noBorderBackgroundOver = noBorderOver;
                  friendBarSlot.borderBackgroundNormal = borderedNormal;
                  friendBarSlot.borderBackgroundOver = borderedOver;
               }
               friendBarSlot.refresh();
            }
         }
      }
      
      private function applyTravelNameDisplay() : void
      {
         var travelNameDisplay:TravelNameDisplay = new TravelNameDisplay(this.m_hudSkinConfig.travelNameDisplaySwfPath,this.m_hudSkinConfig.singleTravelDestination);
         if(travelNameDisplay)
         {
            Global.hud.travelNameDisplay = travelNameDisplay;
         }
      }
      
      private function applyCurrencyMeter() : void
      {
         var currencyMeter:CurrencyMeter = null;
         if(this.m_hudSkinConfig.currencyMeterConfig)
         {
            currencyMeter = new CurrencyMeter(this.m_hudSkinConfig.currencyMeterConfig);
            if(currencyMeter)
            {
               Global.hud.currencyMeter = currencyMeter;
            }
         }
      }
      
      private function applyXpMeter() : void
      {
         Global.hud.xpMeterConfig = this.m_hudSkinConfig.xpBarConfig;
      }
      
      private function applyWorldScoreMeter() : void
      {
         var worldScoreMeter:ScoreMeter = null;
         if(Boolean(Global.worldManager.currentWorldScoreId) && Boolean(this.m_hudSkinConfig.worldScoreConfig))
         {
            worldScoreMeter = new ScoreMeter();
            worldScoreMeter.init(this.m_hudSkinConfig.worldScoreConfig);
            worldScoreMeter.scoreUnit = Global.worldManager.currentWorldScoreId;
         }
         Global.hud.worldScoreMeter = worldScoreMeter;
      }
      
      private function applyWorldScore2Meter() : void
      {
         var worldScoreMeter:ScoreMeter = null;
         var hasUnlockedSeason2:Boolean = WorldSeasonsManager.getInstance().getCurrentSeason(Global.worldManager.currentWorldType) == WorldSeasonsManager.SEASON_TWO;
         if(Boolean(hasUnlockedSeason2) && Boolean(Global.worldManager.currentWorldScore2Id) && Boolean(this.m_hudSkinConfig.worldScore2Config))
         {
            worldScoreMeter = new ScoreMeter();
            worldScoreMeter.init(this.m_hudSkinConfig.worldScore2Config);
            worldScoreMeter.scoreUnit = Global.worldManager.currentWorldScore2Id;
         }
         Global.hud.worldScore2Meter = worldScoreMeter;
      }
      
      private function applyMessageSignButton() : void
      {
         var messageSignButtonStates:Object = this.m_hudSkinConfig.messageSignButtonStates;
         var normalImageClass:Class = this.retreiveExportClass(messageSignButtonStates[HUDSkinConfig.BUTTON_STATE_NORMAL]);
         var overImageClass:Class = this.retreiveExportClass(messageSignButtonStates[HUDSkinConfig.BUTTON_STATE_OVER]);
         var downImageClass:Class = this.retreiveExportClass(messageSignButtonStates[HUDSkinConfig.BUTTON_STATE_DOWN]);
         if(Boolean(normalImageClass) && Boolean(overImageClass) && Boolean(downImageClass))
         {
            Global.hud.messageSignButton = new MessageSignButton(normalImageClass,overImageClass,downImageClass);
         }
      }
      
      private function applyZoomOutButton() : void
      {
         var zoomOutButton:SpriteButton = this.generateSpriteButton(this.m_hudSkinConfig.zoomOutButtonStates);
         if(zoomOutButton)
         {
            Global.ui.zoomOutButton = zoomOutButton;
         }
      }
      
      private function applyZoomInButton() : void
      {
         var zoomInButton:SpriteButton = this.generateSpriteButton(this.m_hudSkinConfig.zoomInButtonStates);
         if(zoomInButton)
         {
            Global.ui.zoomInButton = zoomInButton;
         }
      }
      
      private function applyCameraButton() : void
      {
         var cameraButton:SpriteButton = this.generateSpriteButton(this.m_hudSkinConfig.cameraButtonStates);
         if(cameraButton)
         {
            Global.ui.cameraButton = cameraButton;
         }
      }
      
      private function applyZCacheButton() : void
      {
         var zCacheButton:SpriteButton = this.generateSpriteButton(this.m_hudSkinConfig.zCacheButtonStates);
         if(zCacheButton)
         {
            Global.ui.zCacheButton = zCacheButton;
         }
      }
      
      private function applyFullScreenButton() : void
      {
         var fullScreenButton:SpriteButton = this.generateSpriteButton(this.m_hudSkinConfig.fullScreenButtonStates);
         if(fullScreenButton)
         {
            Global.ui.fullScreenButton = fullScreenButton;
         }
      }
      
      private function applyOptionsBackground() : void
      {
         var optionBackground:Bitmap = this.generateBitmap(this.m_hudSkinConfig.optionsBackground);
         if(optionBackground)
         {
            Global.hud.optionsMenu.background = optionBackground;
         }
      }
      
      private function applyGraphicsOptionsButton() : void
      {
         var graphicsButton:OptionButton = this.generateOptionButton(this.m_hudSkinConfig.graphicsButtonStates);
         if(graphicsButton)
         {
            Global.hud.optionsMenu.graphicsButton = graphicsButton;
         }
      }
      
      private function applySfxOptionsButton() : void
      {
         var sfxButton:OptionButton = this.generateOptionButton(this.m_hudSkinConfig.sfxButtonStates);
         if(sfxButton)
         {
            Global.hud.optionsMenu.sfxButton = sfxButton;
         }
      }
      
      private function applyMusicOptionsButton() : void
      {
         var musicButton:OptionButton = this.generateOptionButton(this.m_hudSkinConfig.musicButtonStates);
         if(musicButton)
         {
            Global.hud.optionsMenu.musicButton = musicButton;
         }
      }
      
      private function applyToggleAnimationButton(event:Event) : void
      {
         var loader:Loader = event.target.loader;
         var toggleAnimMc:MovieClip = loader.content as MovieClip;
         if(toggleAnimMc.hasOwnProperty("animation_bt"))
         {
            Global.hud.optionsMenu.animationButton = toggleAnimMc.animation_bt;
         }
      }
      
      private function generateBitmap(bitmapDataName:String) : Bitmap
      {
         var result:Bitmap = null;
         var bitmapData:BitmapData = this.generateBitmapData(bitmapDataName);
         if(bitmapData)
         {
            result = new Bitmap(bitmapData);
         }
         return result;
      }
      
      private function generateBitmapData(bitmapDataName:String) : BitmapData
      {
         var result:BitmapData = null;
         var bitmapDataClass:Class = this.retreiveExportClass(bitmapDataName);
         if(bitmapDataClass)
         {
            result = new bitmapDataClass() as BitmapData;
         }
         return result;
      }
      
      private function generateSpriteButton(buttonStates:Object) : SpriteButton
      {
         var normalImage:Class = null;
         var overImage:Class = null;
         var downImage:Class = null;
         var result:SpriteButton = null;
         if(buttonStates.hasOwnProperty(HUDSkinConfig.BUTTON_STATE_NORMAL) && buttonStates.hasOwnProperty(HUDSkinConfig.BUTTON_STATE_OVER) && buttonStates.hasOwnProperty(HUDSkinConfig.BUTTON_STATE_DOWN))
         {
            normalImage = this.retreiveExportClass(buttonStates[HUDSkinConfig.BUTTON_STATE_NORMAL]);
            overImage = this.retreiveExportClass(buttonStates[HUDSkinConfig.BUTTON_STATE_OVER]);
            downImage = this.retreiveExportClass(buttonStates[HUDSkinConfig.BUTTON_STATE_DOWN]);
            if(Boolean(normalImage) && Boolean(overImage) && Boolean(downImage))
            {
               result = new SpriteButton(normalImage,overImage,downImage);
            }
         }
         return result;
      }
      
      private function generateOptionButton(buttonStates:Object) : OptionButton
      {
         var normalImage:Bitmap = null;
         var overImage:Bitmap = null;
         var downImage:Bitmap = null;
         var result:OptionButton = null;
         if(buttonStates.hasOwnProperty(HUDSkinConfig.BUTTON_STATE_NORMAL) && buttonStates.hasOwnProperty(HUDSkinConfig.BUTTON_STATE_OVER) && buttonStates.hasOwnProperty(HUDSkinConfig.BUTTON_STATE_DOWN))
         {
            normalImage = this.generateBitmap(buttonStates[HUDSkinConfig.BUTTON_STATE_NORMAL]);
            overImage = this.generateBitmap(buttonStates[HUDSkinConfig.BUTTON_STATE_OVER]);
            downImage = this.generateBitmap(buttonStates[HUDSkinConfig.BUTTON_STATE_DOWN]);
            if(Boolean(normalImage) && Boolean(overImage) && Boolean(downImage))
            {
               result = new OptionButton(normalImage,overImage,downImage);
            }
         }
         return result;
      }
      
      private function retreiveExportClass(classExportName:String) : Class
      {
         var result:Class = null;
         if(Boolean(this.m_loader) && this.m_loader.contentLoaderInfo.applicationDomain.hasDefinition(classExportName))
         {
            result = this.m_loader.contentLoaderInfo.applicationDomain.getDefinition(classExportName) as Class;
         }
         return result;
      }
   }
}


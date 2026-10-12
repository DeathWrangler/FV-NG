package GameMode
{
   import Classes.BuildingItemUseMediator;
   import Classes.LootableDecoration;
   import Classes.StorageBuilding;
   import Classes.WorldObjectTypes;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.IconCursor;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Managers.SoundManager;
   import Managers.ToasterManager;
   import Widgets.Windows.IconToasterWindow;
   import flash.events.MouseEvent;
   
   public class GMBuildingPart extends GMDefault
   {
      
      protected static var m_lastClickTime:int;
      
      private static const ASSET_FIRST_TIME:String = "assets/dialogs/4d_elements/buildableFlow/BuildableCursor_onBoarding.png";
      
      private static const DEFAULT_SOUND_ID:String = "use_building_part";
      
      private static const DEFAULT_SOUND_URL:String = "assets/sounds/actions/sfx_use_building_part.mp3";
      
      private static const SOUND_ID_PREFIX:String = "use_";
      
      private static const SEEN_FLAG:String = "BPMPopup";
      
      private static const CLICK_THROTTLE_DURATION:int = 400;
      
      protected var m_buildingPart:LootableDecoration;
      
      protected var m_acceptableBuildings:Array;
      
      protected var m_targetObject:StorageBuilding;
      
      protected var m_cursor:IconCursor;
      
      protected var m_cursorLoaded:Boolean;
      
      protected var m_soundId:String;
      
      protected var m_soundAssetURL:String;
      
      protected var m_suppressGiftRepop:Boolean;
      
      public function GMBuildingPart(buildingPart:LootableDecoration, acceptableBuildings:Array, isGift:Boolean = true, suppressGiftRepop:Boolean = false)
      {
         super(isGift,false);
         this.m_buildingPart = buildingPart;
         this.m_acceptableBuildings = acceptableBuildings;
         this.m_suppressGiftRepop = suppressGiftRepop;
         this.initCursor();
         this.initSound();
         this.showFirstTimePopup();
      }
      
      public function get buildingPart() : LootableDecoration
      {
         return this.m_buildingPart;
      }
      
      override public function enableMode() : void
      {
         var building:StorageBuilding = null;
         var item:FarmItem = null;
         super.enableMode();
         var hasSelectableBuilding:Boolean = false;
         if(this.m_acceptableBuildings)
         {
            for each(building in this.m_acceptableBuildings)
            {
               if(this.isObjectSelectable(building))
               {
                  hasSelectableBuilding = true;
                  if(building == this.m_targetObject)
                  {
                     selectObject(this.m_targetObject);
                  }
                  else
                  {
                     building.showHighlight(true,Constants.COLOR_HIGHLIGHT_BLUE);
                  }
               }
            }
         }
         this.m_targetObject = null;
         if(hasSelectableBuilding)
         {
            this.refresh();
         }
         else
         {
            this.exit();
            if(m_isGift)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(this.m_buildingPart.itemName);
               if(Global.player.hasGiftItem(item.code))
               {
                  ToasterManager.getInstance().add(new IconToasterWindow(item.getImageByName("icon"),this.getAllFullToasterText()));
               }
            }
         }
      }
      
      protected function getAllFullToasterText() : String
      {
         return ZLocUtils.t("Dialogs","ConstructionBuilding_AllFull");
      }
      
      override public function disableMode() : void
      {
         var building:StorageBuilding = null;
         super.disableMode();
         if(this.m_acceptableBuildings)
         {
            for each(building in this.m_acceptableBuildings)
            {
               building.showHighlight(false);
            }
         }
      }
      
      override protected function updateCursor() : void
      {
      }
      
      override protected function deselectObject() : void
      {
         var building:StorageBuilding = m_highlightedObject as StorageBuilding;
         super.deselectObject();
         if(Boolean(building) && this.isObjectSelectable(building))
         {
            building.showHighlight(true,Constants.COLOR_HIGHLIGHT_BLUE);
         }
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         var result:Boolean = false;
         if(object is StorageBuilding)
         {
            result = BuildingItemUseMediator.canAddToBuilding(object as StorageBuilding,this.m_buildingPart);
         }
         return result;
      }
      
      override protected function getSelectableTypes() : int
      {
         return WorldObjectTypes.BUILDING;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         if(!m_dragging && Boolean(m_highlightedObject))
         {
            if(GlobalEngine.currentTime > m_lastClickTime + this.clickThrottleTime)
            {
               m_lastClickTime = GlobalEngine.currentTime;
               this.m_targetObject = m_highlightedObject as StorageBuilding;
               if(Boolean(this.m_buildingPart) && this.isObjectSelectable(this.m_targetObject))
               {
                  BuildingItemUseMediator.getInstance().mediate(this.m_buildingPart.itemName,m_isGift,this.m_targetObject,true,false);
                  SoundManager.playSound(this.m_soundId);
                  if(!m_isGift)
                  {
                     this.exit();
                  }
               }
               else if(this.m_targetObject.getId() == 0)
               {
                  this.m_targetObject.showObjectBusy();
               }
            }
         }
      }
      
      protected function get clickThrottleTime() : Number
      {
         return CLICK_THROTTLE_DURATION;
      }
      
      private function initCursor() : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_buildingPart.itemName);
         if(item)
         {
            this.m_cursor = new IconCursor(item.getImageByName("icon"),this.onCursorLoaded,"");
         }
      }
      
      private function onCursorLoaded() : void
      {
         if(Global.world.getActiveGameModes().indexOf(this) != -1)
         {
            this.m_cursorLoaded = true;
            this.refresh();
         }
      }
      
      private function initSound() : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_buildingPart.itemName);
         var sounds:Array = item.sounds;
         if(sounds.length > 0)
         {
            this.m_soundAssetURL = sounds[0];
            this.m_soundId = SOUND_ID_PREFIX + item.name;
         }
         else
         {
            this.m_soundAssetURL = DEFAULT_SOUND_URL;
            this.m_soundId = DEFAULT_SOUND_ID;
         }
         if(!SoundManager.getSoundById(this.m_soundId))
         {
            SoundManager.addSound(this.m_soundId,Global.getAssetURL(this.m_soundAssetURL),false);
         }
      }
      
      protected function exit() : void
      {
         Global.world.removeGameMode(this);
         Global.world.setDefaultGameMode();
      }
      
      override protected function shouldScaleCursor() : Boolean
      {
         return false;
      }
      
      protected function refresh() : void
      {
         var itemCount:int = 0;
         if(this.m_cursorLoaded)
         {
            if(m_isGift)
            {
               itemCount = Global.player.getGiftCountForItem(this.m_buildingPart.itemName);
               if(itemCount > 0)
               {
                  if(m_cursorId)
                  {
                     UI.removeCursor(m_cursorId);
                  }
                  this.m_cursor.text = "x" + itemCount;
                  m_cursorImage = this.m_cursor.cursorImage;
                  m_cursorId = UI.setCursor(m_cursorImage,false,this.shouldScaleCursor());
               }
               else
               {
                  this.exit();
                  if(!this.m_suppressGiftRepop)
                  {
                     UI.displayGiftBoxWindow();
                  }
               }
            }
            else
            {
               if(m_cursorId)
               {
                  UI.removeCursor(m_cursorId);
               }
               m_cursorImage = this.m_cursor.cursorImage;
               m_cursorId = UI.setCursor(m_cursorImage,false,this.shouldScaleCursor());
            }
         }
      }
      
      protected function showFirstTimePopup() : void
      {
         var message:String = null;
         var title:String = null;
         if(!Global.player.getSeenFlag(SEEN_FLAG))
         {
            message = ZLocUtils.t("Dialogs","BuildingPartModeFirstUseMessage");
            title = ZLocUtils.t("Dialogs","BuildingPartModeFirstUseTitle");
            UI.showMessage(message,UI.BUTTON_LAYOUT_OK,title,Global.getAssetURL(ASSET_FIRST_TIME),false);
            Global.player.setSeenFlag(SEEN_FLAG);
         }
      }
   }
}


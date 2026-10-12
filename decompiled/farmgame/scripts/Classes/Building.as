package Classes
{
   import Classes.Avatar.FarmAvatar;
   import Classes.NeighborActions.TrickNeighborAction;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Events.GenericPopupEvent;
   import GameMode.GMObjectMove;
   import Managers.AltGraphicUtility;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.TrickOrTreatManager;
   import Transactions.TBuildingPlace;
   import Transactions.TSetOverlay;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   
   public class Building extends SimpleHarvestableResource implements IRotatable
   {
      
      protected const BUILD_TIME:Number = 2000;
      
      protected const SFX_BUILD_ID:String = "building_built_sfx_id";
      
      protected const SFX_BUILD_PATH:String = "assets/sounds/built.mp3";
      
      public const STATE_PREVIEW:String = "preview";
      
      public const STATE_STARTED:String = "started";
      
      public const STATE_ROTATED:String = "built_rotatable";
      
      public const STATE_BUILT:String = "built";
      
      public const STATE_INHABITED:String = "inhabited";
      
      public const STATE_BUSY:String = "busy";
      
      protected const REMOVE_OVERLAY:String = "removeOverlay";
      
      protected const APPLY_WEB_OVERLAY:String = "applyWebOverlay";
      
      private const BUILDING:String = "building";
      
      protected var m_buildTime:Number;
      
      protected var m_overlayApplier:String = "";
      
      protected var m_player:FarmAvatar;
      
      protected var m_gift:Boolean = false;
      
      protected var m_inventory:int = 0;
      
      private var m_isRotatable:Boolean;
      
      private var m_currentGameMode:GMObjectMove;
      
      protected var m_giftMetadataIndex:Number = -1;
      
      protected var m_alreadyOffboard:Boolean = false;
      
      public function Building(itemName:String = null)
      {
         super(itemName);
         m_objectType = WorldObjectTypes.BUILDING;
         setState(this.STATE_PREVIEW);
         m_typeName = this.BUILDING;
         this.loadSounds();
      }
      
      override protected function getSellPrice() : int
      {
         return m_item.sellPrice;
      }
      
      override public function isUsingPerPixelPick() : Boolean
      {
         return true;
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         switch(state)
         {
            case this.STATE_PREVIEW:
            case this.STATE_BUILT:
               imageName = "built";
               break;
            case this.STATE_ROTATED:
               imageName = "built_rotatable";
               break;
            default:
               imageName = super.getCurrentImageName();
         }
         return imageName;
      }
      
      public function set gift(value:Boolean) : void
      {
         this.m_gift = value;
      }
      
      private function loadSounds() : void
      {
         SoundManager.addSound(this.SFX_BUILD_ID,Global.getAssetURL(this.SFX_BUILD_PATH),false);
      }
      
      public function set inventory(value:int) : void
      {
         this.m_inventory = value;
      }
      
      public function get gift() : Boolean
      {
         return this.m_gift;
      }
      
      public function get inventory() : int
      {
         return this.m_inventory;
      }
      
      public function startBuilding() : void
      {
         setState(this.STATE_STARTED);
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         obj.buildTime = this.m_buildTime;
         return obj;
      }
      
      override public function loadObject(data:Object) : void
      {
         var overlay:String = null;
         data = this.sanitizeData(data);
         super.loadObject(data);
         this.m_buildTime = data.buildTime;
         if(Boolean(data.overlayData) && data.overlayData != null)
         {
            var _loc3_:int = 0;
            var _loc4_:* = data.overlayData;
            for(overlay in _loc4_)
            {
               m_overlayXML = Global.farmGameSettingsManager.getOverlayByName(overlay);
               this.m_overlayApplier = data.overlayData[overlay];
            }
         }
         if(data.state != null)
         {
            if(data.state == "built_rotatable")
            {
               setState(this.STATE_ROTATED);
               m_isRotated = true;
               setSize(m_item.sizeY,m_item.sizeX);
            }
            else if(data.state == "built")
            {
               setState(this.STATE_BUILT);
               m_isRotated = false;
               setSize(m_item.sizeX,m_item.sizeY);
            }
         }
      }
      
      protected function sanitizeData(data:Object) : Object
      {
         return data;
      }
      
      override public function conditionallyRedraw(force:Boolean = false) : void
      {
         super.conditionallyRedraw(force);
         conditionallyAttachOverlay();
      }
      
      override public function onClick() : void
      {
         if(Global.selectedAvatar)
         {
            if(Global.worldManager.isVisiting())
            {
               this.onVisitClick();
            }
            else if(this.isBuilt())
            {
               m_menuItems = [];
               this.showMenu();
            }
         }
         setHighlighted(false);
         setToolTip(null);
      }
      
      protected function onVisitClick() : void
      {
         super.onClick();
      }
      
      override public function showMenu() : void
      {
         if(canShowMoveMenuItem() && isMovable())
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
         }
         if(this.canRotate())
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Rotate"),
               "action":ROTATE_OBJECT
            });
         }
         if(getItem().allowDelete && canShowSellMenuItem())
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Sell"),
               "action":SELL_OBJECT
            });
         }
         if(m_overlay)
         {
            if(AltGraphicUtility.isOverlayNameDefined(m_overlayXML.@name,TrickNeighborAction.validOverlays))
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","HideAltGraphic"),
                  "action":this.REMOVE_OVERLAY
               });
               if(FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).isFeatureVisible())
               {
                  m_menuItems.push({
                     "label":ZLocUtils.t("FarmGame","HideAllAltGraphics"),
                     "action":HIDE_ALL_ALT_GRAPHIC,
                     "params":{"graphic":m_altGraphic}
                  });
               }
            }
            else
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Clean"),
                  "action":this.REMOVE_OVERLAY
               });
            }
         }
         else if(isValidOverlayTarget("webOverlay") && (Global.player.numAltGraphicCredits("web") > 0 || Global.player.hasUnlimitedCredits("web")))
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","ShowOverlay_web"),
               "action":this.APPLY_WEB_OVERLAY
            });
         }
         super.showMenu();
      }
      
      override public function isHarvestable() : Boolean
      {
         return false;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MOVE_OBJECT:
                  this.move();
                  break;
               case ROTATE_OBJECT:
                  this.rotate(false);
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               case this.REMOVE_OVERLAY:
                  if(AltGraphicUtility.isOverlayNameDefined(m_overlayXML.@name,TrickNeighborAction.validOverlays))
                  {
                     this.m_overlayApplier = null;
                     this.removeOverlay(true);
                  }
                  else
                  {
                     this.promptRemoveOverlay();
                  }
                  break;
               case HIDE_ALL_ALT_GRAPHIC:
                  TrickOrTreatManager.instance.clearAllAltGraphics();
                  break;
               case this.APPLY_WEB_OVERLAY:
                  if(this is StorageBuilding)
                  {
                     this.applyOverlay("webOverlay",(this as StorageBuilding).storageLevel - 1);
                  }
                  else
                  {
                     this.applyOverlay("webOverlay");
                  }
                  addTransaction(new TSetOverlay(this,"webOverlay"));
                  Global.player.decAltGraphicCredits(m_overlayXML.@altGraphicCredits);
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      protected function promptRemoveOverlay() : void
      {
         var userName:String = Global.friendManager.getFriendName(this.m_overlayApplier);
         var userGender:String = Global.friendManager.getFriendGender(this.m_overlayApplier);
         UI.displayMessage(ZLocUtils.t("Dialogs","RemoveOverlayPrompt_" + m_overlayXML.@name,{"user":ZLocUtils.tn(userName,ZLocUtils.tg(userGender))}),GenericPopup.TYPE_YESNO,this.onRemoveOverlay);
      }
      
      protected function onRemoveOverlay(event:GenericPopupEvent) : void
      {
         var userName:String = null;
         var userGender:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            this.m_overlayApplier = null;
            this.removeOverlay(true);
            if(m_overlayXML.@hasClearFeed == "true")
            {
               userName = Global.friendManager.getFriendName(this.m_overlayApplier);
               userGender = Global.friendManager.getFriendGender(this.m_overlayApplier);
               UI.displayMessage(ZLocUtils.t("Dialogs","ToiletPaperedPrompt",{"user":ZLocUtils.tn(userName,ZLocUtils.tg(userGender))}),GenericPopup.TYPE_SHARECANCEL,this.onPostOverlayRemove);
            }
            m_overlayXML = null;
         }
      }
      
      protected function onPostOverlayRemove(event:GenericPopupEvent) : void
      {
         var params:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            params = {
               "actor":Global.friendManager.getFriendName(this.m_overlayApplier,true),
               "images":[{
                  "src":getItem().getImageByName("icon"),
                  "href":Config.SN_APP_URL
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("feed_aprilfools_was_tped",params,[],false);
            FarmStatsManager.count("ToiletPaper","Cleaned","click_share");
         }
         else
         {
            FarmStatsManager.count("ToiletPaper","Cleaned","click_cancel");
         }
      }
      
      public function getBuildPercentage() : Number
      {
         var alpha:Number = NaN;
         if(this.m_buildTime > 0)
         {
            alpha = (GlobalEngine.serverTime - this.m_buildTime) / this.BUILD_TIME;
            return Math.min(Math.floor(alpha * 100),100);
         }
         return 0;
      }
      
      public function isBuilt() : Boolean
      {
         var stateBool:Boolean = false;
         if(state == this.STATE_BUILT || state == this.STATE_ROTATED)
         {
            stateBool = true;
         }
         return stateBool;
      }
      
      override public function applyOverlay(name:String, overlayVersion:int = 0) : void
      {
         super.applyOverlay(name,overlayVersion);
         setState(this.STATE_BUILT);
         this.m_overlayApplier = Global.player.uid;
      }
      
      public function isBuilding() : Boolean
      {
         return state == this.STATE_STARTED;
      }
      
      public function isStorage() : Boolean
      {
         return false;
      }
      
      public function isInhabitable() : Boolean
      {
         return state == this.STATE_BUILT && this.m_player == null;
      }
      
      override public function onDelete() : void
      {
         super.onDelete();
         this.sellWithOutAsking();
      }
      
      final public function build(currency:String = "") : void
      {
         var expansionLevel:int = 0;
         if(state != this.STATE_BUILT)
         {
            setState(this.STATE_BUILT);
            if(this.gift == false && this.inventory == 0 && Global.player.tryBuy(this,this.gift,null,0,"",currency))
            {
            }
            expansionLevel = 1;
            if(this.hasOwnProperty("storageLevel"))
            {
               expansionLevel = (this as StorageBuilding).storageLevel;
            }
            SoundManager.playSound(this.SFX_BUILD_ID);
            addTransaction(new TBuildingPlace(this,this.gift,this.inventory,expansionLevel,this.m_giftMetadataIndex,currency));
            this.m_buildTime = Global.worldTime;
            this.reloadImage();
            this.onBuilt();
         }
      }
      
      protected function onBuilt() : void
      {
      }
      
      public function onBuildComplete(result:Object) : void
      {
      }
      
      public function rotate(fromMoveTool:Boolean = true) : void
      {
         if(fromMoveTool)
         {
            Global.world.lockGameMode();
         }
         switch(state)
         {
            case this.STATE_BUILT:
               super.setSize(m_item.sizeY,m_item.sizeX);
               super.setState(this.STATE_ROTATED);
               m_isRotated = true;
               break;
            case this.STATE_ROTATED:
               super.setSize(m_item.sizeX,m_item.sizeY);
               super.setState(this.STATE_BUILT);
               m_isRotated = false;
         }
         if(!fromMoveTool)
         {
            Global.world.addGameMode(new GMObjectMove(this,state),false);
         }
         else
         {
            Global.world.unlockGameMode();
         }
      }
      
      public function canRotate() : Boolean
      {
         var canRotate:Boolean = false;
         var obj:ItemInstance = this as ItemInstance;
         var farmItem:FarmItem = obj.getItem();
         return farmItem.canRotate();
      }
      
      public function syncRotationChange() : void
      {
      }
      
      public function getActionText() : String
      {
         return "";
      }
      
      public function showFeedGlow(show:Boolean) : void
      {
         if(m_displayObject)
         {
            if(show)
            {
               m_filters = [new GlowFilter(65484,1,8,8,20)];
            }
            else
            {
               m_filters = [];
            }
            m_displayObject.filters = m_filters;
         }
      }
   }
}


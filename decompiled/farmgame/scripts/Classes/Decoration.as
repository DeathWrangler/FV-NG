package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.CustomizeRing;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Managers.WorldSeasonsManager;
   import Managers.ZapPromoManager;
   import Transactions.TCustomizeUnwitherRing;
   import Transactions.TGetUnwitherRingData;
   import Transactions.TGrantDowngradeCoins;
   import Transactions.TWitherOn;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class Decoration extends CompositeMapResource
   {
      
      protected const STATE_STATIC:String = "static";
      
      private const DECORATION:String = "decoration";
      
      protected var m_placed:Boolean = true;
      
      protected var m_isNew:Boolean = false;
      
      protected var m_hasPlayedAnimation:Boolean = false;
      
      public function Decoration(itemName:String = null)
      {
         super(itemName);
         m_objectType = WorldObjectTypes.DECORATION;
         setState(this.STATE_STATIC);
         m_typeName = this.DECORATION;
         if(Global.farmGameSettingsManager.getItemNameFromMasterySign(itemName) != null)
         {
            m_surfacingKeyword = FeatureBuildingSurfacingManager.MASTERYBILLBOARD_SURFACING_KEYWORD;
         }
         else if(Boolean(m_item) && Global.craftConfigSettings.getRecipeByMasterySign(m_item.code) != null)
         {
            m_surfacingKeyword = FeatureBuildingSurfacingManager.MASTERYBILLBOARD_SURFACING_KEYWORD;
         }
         m_originalItemName = itemName;
      }
      
      public static function ringCustomizationPopupClose(event:Event) : void
      {
         var extraItemData:Object = null;
         var item:FarmItem = null;
         var ringID:Number = NaN;
         var customizeRingPopup:CustomizeRing = event.target as CustomizeRing;
         if(customizeRingPopup)
         {
            customizeRingPopup.removeEventListener(CloseEvent.CLOSE,ringCustomizationPopupClose);
            extraItemData = customizeRingPopup.getCustomRingData();
            if(null != extraItemData)
            {
               item = customizeRingPopup.getCustomItem();
               ringID = customizeRingPopup.getRingID();
               TransactionManager.addTransaction(new TCustomizeUnwitherRing(extraItemData,ringID),true);
            }
         }
      }
      
      public function get isNew() : Boolean
      {
         return this.m_isNew;
      }
      
      public function set isNew(status:Boolean) : void
      {
         this.m_isNew = status;
      }
      
      override protected function getSellPrice() : int
      {
         return m_item.sellPrice;
      }
      
      override public function isUsingPerPixelPick() : Boolean
      {
         return true;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(Boolean(!m_surfacingKeyword) && Boolean(m_item) && Global.craftConfigSettings.getRecipeByMasterySign(m_item.code) != null)
         {
            m_surfacingKeyword = FeatureBuildingSurfacingManager.MASTERYBILLBOARD_SURFACING_KEYWORD;
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         switch(state)
         {
            case this.STATE_STATIC:
               imageName = "static";
         }
         return imageName;
      }
      
      override public function onClick() : void
      {
         var identifier:String = null;
         var itemDowngradeSeenFlag:String = null;
         var txt:String = null;
         if(Global.worldManager.isVisiting())
         {
            super.onClick();
         }
         else
         {
            if(m_item.isBrandedItem && m_item.brandPromoData.isBrandPromoExpired)
            {
               identifier = m_item.brandPromoData.brandPromoName + "_" + m_item.name;
               itemDowngradeSeenFlag = "zap_downgrade_dialog_" + identifier;
               if(!Global.player.getSeenFlag(itemDowngradeSeenFlag))
               {
                  txt = ZLocUtils.t("Dialogs",m_item.name + "_DowngradeMsg");
                  UI.showMessage(txt,UI.BUTTON_LAYOUT_OK,null,null,false);
                  TransactionManager.addTransaction(new TGrantDowngradeCoins(m_item.brandPromoData.brandPromoName,m_item.name),false);
                  ZapPromoManager.countEvent(m_item.brandPromoData.brandPromoName,"downgradeFirstUse",m_item.name);
                  Global.player.setSeenFlag(itemDowngradeSeenFlag);
                  return;
               }
            }
            this.showMenu();
            setHighlighted(false);
            setToolTip(null);
         }
      }
      
      override public function showMenu() : void
      {
         m_menuItems = this.getMenuItems();
         super.showMenu();
         if(this is Airplane)
         {
            FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_open","biplane","","","User opens context menu from biplane");
         }
      }
      
      protected function getMenuItems() : Array
      {
         var terrainCode:Array = null;
         var currentCode:int = 0;
         var item:FarmItem = this.getItem();
         var worldType:String = Global.worldManager.currentWorldType;
         var worldHasMoreThanOneSeason:Boolean = WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldType) > 1 ? true : false;
         var menuItems:Array = new Array();
         if(item.specialValentinesItem)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Details"),
               "action":VIEW_DETAILS
            });
            if(worldHasMoreThanOneSeason)
            {
               terrainCode = item.getTerrainSetCodes();
               currentCode = 0;
               if(terrainCode.length > 0)
               {
                  currentCode = int(terrainCode[0]);
               }
               if(Global.getCurrentWitherStatusArray(currentCode))
               {
                  menuItems.push({
                     "label":ZLocUtils.t("FarmGame","TurnOffWither"),
                     "action":TURN_OFF_WITHER
                  });
               }
               else
               {
                  menuItems.push({
                     "label":ZLocUtils.t("FarmGame","TurnOnWither"),
                     "action":TURN_ON_WITHER
                  });
               }
            }
            else if(Global.getCurrentWitherStatus())
            {
               menuItems.push({
                  "label":ZLocUtils.t("FarmGame","TurnOffWither"),
                  "action":TURN_OFF_WITHER
               });
            }
            else
            {
               menuItems.push({
                  "label":ZLocUtils.t("FarmGame","TurnOnWither"),
                  "action":TURN_ON_WITHER
               });
            }
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
         }
         else
         {
            if(item.allowMove)
            {
               menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Move"),
                  "action":MOVE_OBJECT
               });
            }
            if(item.allowDelete && this.canShowSellMenuItem())
            {
               menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Sell"),
                  "action":SELL_OBJECT
               });
            }
         }
         return menuItems;
      }
      
      override protected function canShowSellMenuItem() : Boolean
      {
         return Global.player.level >= Global.farmGameSettingsManager.getInt("sellLockLevel");
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
               case SELL_OBJECT:
                  this.sell();
                  break;
               case TURN_OFF_WITHER:
                  this.toggleWither();
                  FarmStatsManager.count("Recipient","WitherOn");
                  break;
               case TURN_ON_WITHER:
                  this.toggleWither();
                  FarmStatsManager.count("Recipient","WitherOff");
                  break;
               case VIEW_DETAILS:
                  this.getUnwitherRingDetails();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      public function toggleWither() : void
      {
         TransactionManager.addTransaction(new TWitherOn(getId(),getItem()),true);
         reloadImage();
      }
      
      protected function getUnwitherRingDetails() : void
      {
         TransactionManager.addTransaction(new TGetUnwitherRingData(this,getItem()),true);
      }
      
      public function onPlacedFirstTime() : void
      {
      }
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         var item:FarmItem = this.getItem();
         return item.allowStore;
      }
      
      public function setPlaced(placed:Boolean) : void
      {
         this.m_placed = placed;
      }
      
      override public function detach() : void
      {
         if(Boolean(m_item) && m_item.limit > 0)
         {
            Global.player.removeLimitedItem(this.m_item.name);
         }
         super.detach();
      }
      
      public function isPlaced() : Boolean
      {
         return this.m_placed;
      }
      
      override protected function get shouldTrackAnimation() : Boolean
      {
         var value:Boolean = false;
         if(Global.worldManager.isVisitingNPCOfType(NPCConfigData.TYPE_NORMAL))
         {
            value = false;
         }
         else
         {
            value = super.shouldTrackAnimation;
         }
         return value;
      }
      
      override protected function resetAnimation() : void
      {
         if(!Global.worldManager.isVisitingNPCOfType(NPCConfigData.TYPE_NORMAL))
         {
            super.resetAnimation();
         }
      }
      
      override public function stop() : void
      {
         if(!Global.worldManager.isVisitingNPCOfType(NPCConfigData.TYPE_NORMAL))
         {
            super.stop();
         }
      }
      
      override public function play(ignoreCanPlay:Boolean = false) : Boolean
      {
         var result:Boolean = false;
         if(!this.m_hasPlayedAnimation || !Global.worldManager.isVisitingNPCOfType(NPCConfigData.TYPE_NORMAL))
         {
            this.m_hasPlayedAnimation = true;
            result = super.play();
         }
         return result;
      }
      
      override protected function canSetToolTip(toolTip:String) : Boolean
      {
         var result:Boolean = false;
         if(m_aoeBonusShowing)
         {
            result = true;
         }
         else
         {
            result = super.canSetToolTip(toolTip);
         }
         return result;
      }
   }
}


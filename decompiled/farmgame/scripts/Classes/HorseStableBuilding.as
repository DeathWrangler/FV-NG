package Classes
{
   import Classes.Constants.ToasterIconPaths;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.HUD.StatsDropDown;
   import Display.HorseStableWithdrawal;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TDeprecateItem;
   import Transactions.TGiftGive;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.ArrowIndicatorWindow;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class HorseStableBuilding extends AnimalStorageBuilding
   {
      
      public static const HORSE_STABLE_COUNTER:String = "horsestable";
      
      private static const HORSESTABLE_ARROW_FREQUENCY_KEY:String = "horseStableArrowFreqKey";
      
      private static const ARROW_ICON_URL:String = "assets/animals/horse_andalusian_brown_icon.png";
      
      private static const REPLACEMENT_BUILDING_ICON_URL:String = "assets/buildings/bldg_breedinghorsepaddock_built_0_icon.png";
      
      private static const REPLACEMENT_BUILDING_NAMES:Array = ["animal_breeding_horsepaddock","animal_breeding_horsepaddock_finished"];
      
      private static const ARROW_DEFAULT_DAYS:int = 7;
      
      public static const EXPAND_IMAGE_ICON_URL:String = "assets/buildings/building_horsestable_icon.png";
      
      private static const EXPAND_COMPLETE_ICON_URL:String = "assets/buildings/building_horsestable_icon.png";
      
      private static const DEFAULT_PAINT_COLOR:String = "white";
      
      private static const REWARD_HORSE_NAME:String = "horse_andalusianbrown";
      
      private static const REWARD_HORSES:int = 1;
      
      private static const REWARD_FEED:int = 5;
      
      private static var m_hasWanderingStallion:Boolean = false;
      
      private static var m_hasWanderingStallionIsSet:Boolean = false;
      
      protected var m_bundleData:Object = null;
      
      protected var m_feedAction:String = "";
      
      protected var m_callbackFunction:Function = null;
      
      protected var m_coinBonus:int;
      
      protected const HARVEST_POPUP_ICON:String = "assets/buildings/building_horsestable_icon.png";
      
      protected var m_harvestResult:Object = null;
      
      private var m_showingArrow:Boolean = false;
      
      private var m_deprecating:Boolean = false;
      
      private var m_shouldCheckArrow:Boolean = false;
      
      private var m_lastClickedTimeStamp:Number = 0;
      
      public function HorseStableBuilding(buildingType:String)
      {
         super(buildingType);
         m_isFullyBuilt = false;
         this.m_coinBonus = Global.farmGameSettingsManager.getInt("defaulStallionCoinBonus",101);
      }
      
      public static function checkForWanderingStallion() : Boolean
      {
         if(!m_hasWanderingStallionIsSet && Global.player.actionCountsLoaded())
         {
            m_hasWanderingStallion = Global.player.getActionCount("hasWanderingStallion") == 1;
            m_hasWanderingStallionIsSet = true;
         }
         return m_hasWanderingStallion;
      }
      
      public static function onClickStableExpansionPromo() : void
      {
         var building:HorseStableBuilding = null;
         var stables:Array = Global.world.getObjectsByClass(HorseStableBuilding);
         var builtStable:HorseStableBuilding = null;
         for each(building in stables)
         {
            if(building.isFullyBuilt())
            {
               builtStable = building;
               break;
            }
         }
         if(builtStable)
         {
            builtStable.displayStorageDialog();
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","HorseStableIconNotComplete"));
         }
      }
      
      override public function createDisplayObject() : DisplayObject
      {
         var result:DisplayObject = super.createDisplayObject();
         m_displayObject.addEventListener(Event.ADDED_TO_STAGE,this.onAddToStage);
         return result;
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new HorseStableWithdrawal(this,m_isFullyBuilt));
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var key:String = null;
         var success:Boolean = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
         if(!isFullyBuilt() && m_count < getMaterialsNeeded())
         {
            setState(STATE_CONSTRUCTION);
         }
         else if(!isFullyBuilt() && m_count >= getMaterialsNeeded())
         {
            m_isFullyBuilt = true;
            for(key in m_contents)
            {
               setAmount(key,0);
            }
            setState(STATE_BUILT);
         }
         return success;
      }
      
      override protected function onBuilt() : void
      {
         super.onBuilt();
         if(state != STATE_CONSTRUCTION)
         {
            setState(STATE_CONSTRUCTION);
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTipString:String = null;
         super.updateToolTipText();
         var toolTipText:TextField = getToolTipText();
         if(Boolean(toolTipText) && checkForWanderingStallion())
         {
            toolTipString = toolTipText.text + "\n" + ZLocUtils.t("FarmGame","HorseStableBuilding_hasStallion");
            setToolTip(toolTipString);
            updateToolTipPosition();
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         var iconURL:String = null;
         var message:GenericIconPopup = null;
         super.onBuildComplete(result);
         if(!m_isFullyBuilt)
         {
            if(result.rewardLink)
            {
               this.m_feedAction = "HorseStableBeginBuilding";
               this.m_callbackFunction = this.displayStorageDialog;
               iconURL = this.getItem().getImageByName("icon");
               this.m_bundleData = {
                  "reward_link":result.rewardLink,
                  "images":[{
                     "href":"{SN_APP_URL}" + result.rewardLink,
                     "src":iconURL
                  }]
               };
               message = new GenericIconPopup(ZLocUtils.t("Dialogs","HorseStableBeginBuilding"),GenericPopup.TYPE_SHARE,this.onConfirmShareFeed,iconURL);
               message.setTrackerKey("Feed_share_stable_started");
               UI.displayPopup(message);
               Global.player.updatePlayerStat(StatsDropDown.INDEX_BUILDINGS,0);
            }
         }
      }
      
      protected function onConfirmShareFeed(event:GenericPopupEvent) : void
      {
         var emailDataItem:Object = null;
         var emailDataFoal:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            GlobalEngine.socialNetwork.publishFeedStory(this.m_feedAction,this.m_bundleData,[],false,this.m_callbackFunction);
            if(this.m_bundleData["item_name"] != null)
            {
               emailDataItem = {
                  "item_name":this.m_bundleData["item_name"],
                  "reward_link":this.m_bundleData["reward_link"]
               };
               TransactionManager.addTransaction(new TGiftGive(this.m_feedAction,emailDataItem,[]));
            }
            else if(this.m_bundleData["foal_type"] != null)
            {
               emailDataFoal = {
                  "item_name":this.m_bundleData["foal_type"],
                  "reward_link":this.m_bundleData["reward_link"]
               };
               TransactionManager.addTransaction(new TGiftGive(this.m_feedAction,emailDataFoal,[]));
            }
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_bundleData["reward_link"]]));
            if(this.m_callbackFunction != null)
            {
               this.m_callbackFunction();
            }
         }
         this.m_callbackFunction = null;
      }
      
      override public function onStoreComplete(result:Object) : void
      {
         var message:GenericIconPopup = null;
         super.onStoreComplete(result);
         var messageType:String = "";
         var iconURL:String = this.getItem().getImageByName("icon");
         if(Boolean(result.rewardLink) && !isFullyBuilt())
         {
            this.m_feedAction = "HorseStableHalfBuilt";
            this.m_bundleData = {
               "reward_link":result.rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + result.rewardLink,
                  "src":iconURL
               }]
            };
            messageType = "HorseStableHalfBuilt";
         }
         else if(Boolean(result.rewardLink) && Boolean(isFullyBuilt()) && Boolean(result.gift))
         {
            this.m_feedAction = "HorseStableFullyBuilt";
            this.m_bundleData = {
               "reward_link":result.rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + result.rewardLink,
                  "src":iconURL
               }]
            };
            messageType = "HorseStableFullyBuilt";
            if(result.gift)
            {
               Global.player.addGift(result.gift);
            }
         }
         if(messageType != "")
         {
            message = new GenericIconPopup(ZLocUtils.t("Dialogs",messageType),GenericPopup.TYPE_SHARE,this.onConfirmShareFeed,iconURL);
            message.setTrackerKey("Feed_share" + messageType);
            UI.displayPopup(message);
         }
         stopOverlay();
      }
      
      override public function buildStatusMessage(messageData:Array) : String
      {
         if(messageData.length < 2)
         {
            return " ";
         }
         return ZLocUtils.t("FarmGame","Status_AddPart",{
            "quantity":messageData[0],
            "item":ZLocUtils.tk_pk(messageData[1])
         });
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var item:FarmItem = null;
         var itemFriendlyName:String = null;
         var iconURL:String = null;
         var titleMsg:String = null;
         var msg:String = null;
         var message:GenericIconPopup = null;
         if(Boolean(result.foalBorn) && Boolean(result.foalRewardLink) && Boolean(result.foalCode))
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(result.foalCode);
            itemFriendlyName = item.friendlyName;
            iconURL = item.getImageByName("icon");
            this.m_feedAction = "FoalReward";
            this.m_bundleData = {
               "foal_type":itemFriendlyName,
               "reward_link":result.foalRewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + result.foalRewardLink,
                  "src":iconURL
               }]
            };
            message = new GenericIconPopup(ZLocUtils.t("Dialogs","HorseStableHarvested_Foal",{"item":ZLocUtils.tk_pk(itemFriendlyName)}),GenericPopup.TYPE_SHARE,this.onConfirmShareFeed,iconURL);
            message.setTrackerKey("lonely_cow-foal");
         }
         else if(Boolean(result.lootItemName) && Boolean(result.data) && Boolean(result.data.rewardLink))
         {
            Global.player.addGift(result.lootItemName);
            item = Global.farmGameSettingsManager.getFarmItemByName(result.lootItemName);
            itemFriendlyName = item.friendlyName;
            this.m_feedAction = "HorseStableHarvestedConsumable";
            iconURL = item.getImageByName("icon");
            this.m_bundleData = {
               "item_name":itemFriendlyName,
               "reward_link":result.data.rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + result.data.rewardLink,
                  "src":iconURL
               }]
            };
            message = new GenericIconPopup(ZLocUtils.t("Dialogs","HorseStableHarvested_Consumable",{"item":ZLocUtils.tk_pk(itemFriendlyName)}),GenericPopup.TYPE_SHARE,this.onConfirmShareFeed,iconURL);
            message.setTrackerKey("Feed_share_stable_consumable");
         }
         else if(result.coinBonus)
         {
            this.m_coinBonus = int(result.coinBonus);
            iconURL = Global.getAssetURL(this.HARVEST_POPUP_ICON);
            m_hasWanderingStallion = false;
            this.updateToolTipText();
            stopOverlay();
            titleMsg = ZLocUtils.t("Dialogs","HorseStableHarvested_Coins_Title",{"coinQuantity":result.coinBonus});
            msg = ZLocUtils.t("Dialogs","HorseStableHarvested_Coins_" + result.stallion,{"coinQuantity":result.coinBonus});
            ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,ToasterIconPaths.CONSUMECOIN_ICON,iconURL,ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8),null,null));
            Global.player.updateWorldCurrency(Currency.COINS,this.m_coinBonus,true);
         }
         else
         {
            m_hasWanderingStallion = false;
            this.updateToolTipText();
            stopOverlay();
            iconURL = Global.getAssetURL(this.HARVEST_POPUP_ICON);
            titleMsg = ZLocUtils.t("Dialogs","HorseStableHarvested_Coins_Title",{"coinQuantity":result.coinYield});
            msg = ZLocUtils.t("Dialogs","HorseStableHarvested_Coins_" + result.stallion,{"coinQuantity":result.coinYield});
            ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,ToasterIconPaths.CONSUMECOIN_ICON,iconURL,ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8),null,null));
         }
         if(message != null)
         {
            m_hasWanderingStallion = false;
            this.updateToolTipText();
            stopOverlay();
            UI.displayPopup(message);
         }
      }
      
      override public function postProcessImageName(name:String) : String
      {
         var buildingItem:BuildingItem = null;
         if(isFullyBuilt() && !m_paintColor)
         {
            buildingItem = this.getItem() as BuildingItem;
            if(Boolean(buildingItem) && buildingItem.paintable)
            {
               m_paintColor = DEFAULT_PAINT_COLOR;
            }
         }
         return super.postProcessImageName(name);
      }
      
      private function onAddToStage(event:Event) : void
      {
         if(m_isFullyBuilt && checkForWanderingStallion())
         {
            startOverlay(FarmGameObject.SPARKLE_URL);
         }
         drawDisplayObject();
      }
      
      override protected function onCompleteExpansion(rewardLink:String, itemName:String) : void
      {
         this.m_feedAction = "HorseStableExpandComplete";
         var iconURL:String = this.getItem().getImageByName("icon");
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":iconURL
            }]
         };
         var itemFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyName;
         var message:String = ZLocUtils.t("Dialogs","horsestableExpandComplete",{"item":ZLocUtils.tk_pk(itemFriendlyName)});
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,iconURL);
         dialog.setTrackerKey("feed_share_stable_expansion_complete");
         UI.displayPopup(dialog,false);
      }
      
      override protected function onCompleteExpansionPart(rewardLink:String, itemName:String) : void
      {
         this.m_feedAction = "HorseStableExpandCompletePart";
         var itemFriendlyName:String = Global.farmGameSettingsManager.getFarmItemByName(itemName).friendlyName;
         var iconURL:String = this.getItem().getImageByName("icon");
         this.m_bundleData = {
            "item":itemFriendlyName,
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":iconURL
            }]
         };
         var message:String = ZLocUtils.t("Dialogs","horsestableExpandPartComplete",{"item":ZLocUtils.tk_pk(itemFriendlyName)});
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,iconURL);
         dialog.setTrackerKey("feed_share_stable_expansion_complete_part");
         UI.displayPopup(dialog,false);
      }
      
      override protected function onCompleteHalfExpansion(rewardLink:String) : void
      {
         this.m_feedAction = "HorseStableExpandHalfComplete";
         var iconURL:String = this.getItem().getImageByName("icon");
         this.m_bundleData = {
            "reward_link":rewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":iconURL
            }]
         };
         var message:String = ZLocUtils.t("Dialogs","horsestableExpandHalfComplete");
         var dialog:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShareExpansionReward,iconURL);
         dialog.setTrackerKey("feed_share_stable_expansion_halfway");
         UI.displayPopup(dialog,false);
      }
      
      private function onShareExpansionReward(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            GlobalEngine.socialNetwork.publishFeedStory(this.m_feedAction,this.m_bundleData,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_bundleData["reward_link"]]));
         }
      }
      
      override public function getBuildingIcon(finished:Boolean = true) : String
      {
         return HorseStableBuilding.EXPAND_IMAGE_ICON_URL;
      }
      
      override protected function updatePlantTimeOnStore(itemCount:int, resource:MapResource) : void
      {
         if(resource is HarvestableResource)
         {
            plantTime = (resource as HarvestableResource).plantTime;
            setState(STATE_BARE);
         }
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(this.m_shouldCheckArrow)
         {
            this.checkShowArrow();
         }
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         this.checkShowArrow();
         this.m_shouldCheckArrow = true;
      }
      
      private function checkShowArrow() : void
      {
      }
      
      private function generateArrowIndicator() : void
      {
         var sprite:Sprite = null;
         var iconPath:String = null;
         var title:String = null;
         var text:String = null;
         sprite = m_displayObject as Sprite;
         if(m_arrow == null && sprite.numChildren > 0)
         {
            this.m_hideArrow = false;
            iconPath = Global.getAssetURL(ARROW_ICON_URL);
            title = ZLocUtils.t("Dialogs","HorseStable_Arrow_Title");
            text = ZLocUtils.t("Dialogs","HorseStable_Arrow_Text");
            m_arrow = new ArrowIndicatorWindow(iconPath,title,text);
            if(m_arrow != null)
            {
               m_arrow.visible = true;
               this.m_showingArrow = true;
               sprite.addChild(m_arrow);
               this.setArrowPosition();
            }
         }
      }
      
      override public function hideArrowDisplay() : void
      {
         if(Boolean(m_arrow) && Boolean(this.m_showingArrow) && m_arrow.parent != null)
         {
            m_arrow.visible = false;
            this.m_showingArrow = false;
            m_arrow.parent.removeChild(m_arrow);
            m_arrow = null;
            conditionallyRedraw(true);
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
      }
      
      override public function onClick() : void
      {
         super.onClick();
      }
      
      public function getExpansionLevel() : int
      {
         return (this.maxPotentialCapacity - 20) / 5 + 1;
      }
      
      public function onTradeinDialogClosed(event:GenericPopupEvent) : void
      {
         var buildings:Array = null;
         var building:HorseStableBuilding = null;
         var localizedText:String = null;
         var iconPath:String = null;
         var message:GenericIconPopup = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count(HORSE_STABLE_COUNTER,"deprecation","tradein_accept");
            buildings = Global.world.getObjectsByClass(HorseStableBuilding);
            for each(building in buildings)
            {
               building.startDeprecation();
            }
            localizedText = ZLocUtils.t("Dialogs","HorseStable_DeprecationComplete");
            iconPath = Global.getAssetURL(REPLACEMENT_BUILDING_ICON_URL);
            message = new GenericIconPopup(localizedText,GenericPopup.TYPE_OK,this.onBuyFromMarket,iconPath,false,false);
            message.setAcceptTextName("Market");
            UI.displayPopup(message,true);
         }
         else
         {
            this.m_lastClickedTimeStamp = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            Global.player.setFeatureLastShown(HORSESTABLE_ARROW_FREQUENCY_KEY,this.m_lastClickedTimeStamp,true);
            FarmStatsManager.count(HORSE_STABLE_COUNTER,"deprecation","tradein_cancel");
         }
      }
      
      private function onBuyFromMarket(event:GenericPopupEvent) : void
      {
         UI.displayMiniMarketDialog(REPLACEMENT_BUILDING_NAMES,UI.MARKET_CONTEXT_UNKNOWN,"building",null,true);
      }
      
      public function startDeprecation() : void
      {
         this.m_deprecating = true;
         TransactionManager.addTransaction(new TDeprecateItem(this));
         FarmStatsManager.count(HORSE_STABLE_COUNTER,"deprecation","deprecate",m_itemName);
      }
      
      override protected function setArrowPosition() : void
      {
         var point:Point = null;
         var spr:Sprite = null;
         if(Boolean(m_arrow) && Boolean(m_displayObject))
         {
            point = new Point();
            spr = m_displayObject as Sprite;
            m_arrow.scaleX = ARROW_SCALE / m_displayObject.scaleX;
            m_arrow.scaleY = ARROW_SCALE / m_displayObject.scaleY;
            if(spr.getChildAt(0))
            {
               point.y = -1 * Math.min(m_arrow.height,DEFAULT_ARROW_SIZE_Y);
               point.x = (spr.getChildAt(0).width - Math.min(m_arrow.width,DEFAULT_ARROW_SIZE_X) * spr.scaleX) / 2;
               m_arrow.y = point.y - 100;
               m_arrow.x = point.x - 30;
            }
         }
      }
   }
}


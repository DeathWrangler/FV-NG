package Classes
{
   import AvatarMode.AMHarvest;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.MFSRequestManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TGiftGive;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.Beehives.BeehiveWindow;
   import Widgets.Windows.HolidayBasketWindows.RewardCreditsWindow;
   
   public class BeehiveBuilding extends RewardCreditsBuilding
   {
      
      public static const DIALOG_SIDE_ICON:String = "assets/buildings/bldg_beehive_icon.png";
      
      public static const BEEHIVE_FEATURE:String = "beehive";
      
      public static const BEEHIVE_QUEEN:String = "beehive_queen";
      
      public static const BEEHIVE_BEE:String = "beehive_bee";
      
      public static const BEEHIVE_BEE_5:String = "beehive_bee_5";
      
      private const INTERVAL_FEED_ICON:String = "assets/buildings/bldg_beehive_icon.png";
      
      private const SUBCREDITS_TRADE_ICON:String = "assets/buildings/bldg_beehive_icon.png";
      
      private const LOCALE_PREFIX:String = "Beehive_";
      
      private const BUNDLE_PREFIX:String = "Beehive";
      
      private const COIN_YIELD_PER_BEE:uint = 3;
      
      private const NEIGHBOR_PASS_FEED_FLAG_NAME:String = "beehivePassNeighbor";
      
      protected var m_bundleData:Object = null;
      
      protected var m_feedAction:String = "";
      
      protected var m_callbackFunction:Function = null;
      
      public function BeehiveBuilding(buildingType:String = null)
      {
         super(buildingType,"beehive");
      }
      
      public static function conditionallyDisplayBeesFlyAwayPopUp(result:Object) : void
      {
         if(null != result.beesLost && null != result.numDays)
         {
            displayBeesFlyAwayPopUp(result.beesLost,result.numDays);
         }
      }
      
      protected static function displayBeesFlyAwayPopUp(beesLost:int, numDays:int) : void
      {
         Global.player.useFeatureCredits(BeehiveBuilding.BEEHIVE_FEATURE,beesLost);
         Global.player.removeFeatureCreditsReceived(BeehiveBuilding.BEEHIVE_FEATURE,beesLost);
         var message:String = ZLocUtils.t("Dialogs","BeesFlyAway",{
            "quantity":numDays,
            "quantityBees":beesLost
         });
         UI.displayPopup(new GenericPopup(message,GenericPopup.TYPE_SHARECANCEL,onAskForBees),false);
      }
      
      protected static function onAskForBees(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            askForBees();
         }
      }
      
      public static function askForBees() : void
      {
         MFSRequestManager.getInstance().makeAskCreditsRequest(BeehiveBuilding.BEEHIVE_FEATURE,MFSConstants.SOURCE_UI,BeehiveBuilding.BEEHIVE_FEATURE,"AskForCredits","accept",BeehiveBuilding.BEEHIVE_BEE);
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayPopup(new BeehiveWindow(this));
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
      }
      
      override public function getLocKeyPrefix() : String
      {
         return this.LOCALE_PREFIX;
      }
      
      override public function getBundlePrefix() : String
      {
         return this.BUNDLE_PREFIX;
      }
      
      override public function getDialogSideIconUrl() : String
      {
         return DIALOG_SIDE_ICON;
      }
      
      override public function getLevelIconUrl() : String
      {
         return "assets/newsfeed/beehive_" + (getCurrentSuffix() + 1) + ".png";
      }
      
      override public function getTotalCreditsReceived(creditType:String = null) : uint
      {
         var friend:Friend = null;
         var result:uint = super.getTotalCreditsReceived(creditType);
         if(Global.worldManager.isVisiting())
         {
            friend = Global.friendManager.getFriendData(Global.worldManager.getVisiting());
            if(friend)
            {
               result = uint(friend.getFeatureCreditsReceived(m_creditsFeatureName));
            }
         }
         return result;
      }
      
      override public function getIntervalFeedIconUrl() : String
      {
         return this.INTERVAL_FEED_ICON;
      }
      
      override public function getSubcreditsTradeFeedUrl() : String
      {
         return this.SUBCREDITS_TRADE_ICON;
      }
      
      override public function isSubcreditsTradePossible() : Boolean
      {
         return false;
      }
      
      override public function isFull() : Boolean
      {
         return getCurrentCredits() >= m_capacity;
      }
      
      public function isAlmostFull() : Boolean
      {
         return getCurrentCredits() > m_capacity - 5;
      }
      
      public function hasQueenBee() : Boolean
      {
         return getCurrentSubcredits(BEEHIVE_QUEEN) > 0;
      }
      
      override public function canTakeItem(item:MapResource, isMouseOver:Boolean = true) : Boolean
      {
         var result:Boolean = super.canTakeItem(item,isMouseOver);
         if(item.getItem().className == "BeehiveItem")
         {
            switch(item.getItem().name)
            {
               case BEEHIVE_QUEEN:
                  if(this.hasQueenBee())
                  {
                     result = false;
                     UI.displayMessage(ZLocUtils.t("Dialogs","BeehiveBuilding_ExrtaQueen"));
                  }
                  break;
               case BEEHIVE_BEE_5:
                  if(!this.hasQueenBee())
                  {
                     result = false;
                     UI.displayMessage(ZLocUtils.t("Dialogs","BeehiveBuilding_NoQueen"));
                  }
                  if(this.isAlmostFull())
                  {
                     result = false;
                     UI.displayMessage(ZLocUtils.t("Dialogs","BeehiveBuilding_AlmostFullBuilding"));
                  }
                  break;
               case BEEHIVE_BEE:
                  if(!this.hasQueenBee())
                  {
                     result = false;
                     UI.displayMessage(ZLocUtils.t("Dialogs","BeehiveBuilding_NoQueen"));
                  }
                  if(this.isFull())
                  {
                     result = false;
                     UI.displayMessage(ZLocUtils.t("Dialogs","BeehiveBuilding_FullBuilding"));
                  }
            }
         }
         return result;
      }
      
      override public function loadObject(data:Object) : void
      {
         var currentState:String = data.state;
         super.loadObject(data);
         setState(currentState);
      }
      
      override public function addCreditsFromItem(item:FarmItem, itemCount:int = 1) : void
      {
         if(getCurrentCredits() == 0)
         {
            plantTime = Global.worldTime;
            setState(STATE_BARE);
         }
         super.addCreditsFromItem(item,itemCount);
      }
      
      override public function addCredits(creditAmount:uint, creditType:String = null, window:RewardCreditsWindow = null) : void
      {
         if(getCurrentCredits() == 0)
         {
            plantTime = Global.worldTime;
            setState(STATE_BARE);
         }
         super.addCredits(creditAmount,creditType,window);
      }
      
      override public function isBuilt() : Boolean
      {
         return state == STATE_BUILT || state == STATE_RIPE || state == STATE_BARE;
      }
      
      override public function doHarvestDropOff(avatar:FarmAvatar, showStatus:Boolean = true) : Object
      {
         var result:Object = new Object();
         result.coinYield = this.getHarvestAmount();
         Global.player.updateWorldCurrency(Currency.GOLD,int(result.coinYield),true);
         if(showStatus)
         {
            avatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestPlot",{"coinNum":result.coinYield}));
         }
         super.doHarvestDropOff(avatar);
         m_isInHarvestQueue = false;
         return result;
      }
      
      override public function isHarvestable() : Boolean
      {
         var harvestable:Boolean = false;
         if(getCurrentCredits() > 0)
         {
            if(getGrowPercentage() == 100 || state == STATE_RIPE)
            {
               harvestable = true;
            }
         }
         return harvestable;
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var item:FarmItem = null;
         var itemFriendlyName:String = null;
         var iconURL:String = null;
         var message:GenericIconPopup = null;
         if(Boolean(result.lootItemName) && Boolean(result.data) && Boolean(result.data.rewardLink))
         {
            Global.player.addGift(result.lootItemName);
            item = Global.farmGameSettingsManager.getFarmItemByName(result.lootItemName);
            itemFriendlyName = item.friendlyName;
            this.m_feedAction = "BeehiveHarvestedConsumable";
            iconURL = item.getImageByName("icon");
            this.m_bundleData = {
               "item_name":itemFriendlyName,
               "reward_link":result.data.rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + result.data.rewardLink,
                  "src":iconURL
               }]
            };
            message = new GenericIconPopup(ZLocUtils.t("Dialogs","BeehiveHarvested_Consumable",{"item":ZLocUtils.tk_pk(itemFriendlyName)}),GenericPopup.TYPE_SHARE,this.onConfirmShareFeed,iconURL);
            message.setTrackerKey("feed_beehive_share_fertilize_all");
            UI.displayPopup(message);
         }
      }
      
      protected function onConfirmShareFeed(event:GenericPopupEvent) : void
      {
         var emailDataItem:Object = null;
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
      
      override public function showMenu() : void
      {
         var state:AMHarvest = null;
         if(!inQueue())
         {
            if(state == STATE_RIPE && Global.selectedAvatar != null && !Global.worldManager.isVisiting())
            {
               state = Global.selectedAvatar.getStateMachine().getState() as AMHarvest;
               if(state != null && state.getResource() != this || state == null)
               {
                  Global.selectedAvatar.getStateMachine().addState(new AMHarvest(Global.selectedAvatar,this),true);
                  m_isInHarvestQueue = true;
               }
            }
            else
            {
               super.showMenu();
            }
         }
         else
         {
            displayStatus(ZLocUtils.t("FarmGame","Harvesting"));
         }
      }
      
      override public function buildStatusMessage(messageData:Array) : String
      {
         var quantity:int = 0;
         var addPartKey:String = null;
         if(messageData.length < 2)
         {
            return " ";
         }
         quantity = int(messageData[0]);
         addPartKey = "Status_AddPart";
         if(quantity > 1)
         {
            addPartKey = "Status_AddParts";
         }
         return ZLocUtils.t("FarmGame",addPartKey,{
            "quantity":quantity,
            "item":ZLocUtils.tk_pk(messageData[1])
         });
      }
      
      override protected function getNeighborPassFeedFlagName() : String
      {
         return this.NEIGHBOR_PASS_FEED_FLAG_NAME;
      }
      
      override protected function getCreditsRewardInterval() : int
      {
         return RewardCreditsBuilding.CREDITS_REWARD_INTERVAL_INVALID;
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTip:String = null;
         if(isHighlighted() && Global.worldManager.isVisiting() == false)
         {
            toolTip = this.getOwnerToolTipText();
         }
         else if(isHighlighted() && Global.worldManager.isVisiting() == true)
         {
            toolTip = m_item.friendlyTitle;
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override protected function getOwnerToolTipText() : String
      {
         var growPercentage:int = 0;
         var toolTip:String = "";
         var currentCredits:uint = getCurrentCredits();
         var currentCreditsText:String = ZLocUtils.t("Items",m_item.name + "_capacity",{"quantity":currentCredits});
         if(getCurrentCredits() == 0 && state != STATE_BUILT)
         {
            plantTime = 0;
            setState(STATE_BUILT);
         }
         switch(state)
         {
            case STATE_RIPE:
               toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_ready",{
                  "item":ZLocUtils.tk_pk(m_item.friendlyName),
                  "capacityStr":currentCreditsText
               });
               break;
            case STATE_BARE:
               growPercentage = getGrowPercentage();
               toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_toolTip",{
                  "item":ZLocUtils.tk_pk(m_item.friendlyName),
                  "quantity":growPercentage,
                  "capacityStr":currentCreditsText
               });
               break;
            case STATE_BUILT:
               toolTip = ZLocUtils.t("FarmGame","AnimalBuilding_capacity",{
                  "item":ZLocUtils.tk_pk(m_item.friendlyName),
                  "capacityStr":currentCreditsText
               });
               break;
            default:
               toolTip = m_item.friendlyTitle;
         }
         return toolTip;
      }
      
      override protected function hasStartFeed() : Boolean
      {
         return true;
      }
      
      protected function getHarvestAmount() : int
      {
         return getCurrentCredits() * this.COIN_YIELD_PER_BEE;
      }
   }
}


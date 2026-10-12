package Classes
{
   import AvatarMode.AMFillFeedTrough;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TDeprecateItem;
   import Transactions.TGetAskForAnimalFeedFriendReward;
   import Widgets.Windows.ArrowIndicatorWindow;
   import Widgets.Windows.FeedTrough.FeedTroughWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class FeedTroughBuilding extends CyclingCreditsBuilding
   {
      
      public static const ANIMAL_FEED_TROUGH_COUNTER:String = "animal_feed_trough";
      
      private static const ANIMAL_FEED_TROUGH_KINGDOM:String = "frontend_animal_event";
      
      private static const ARROW_FREQUENCY_KEY:String = "feedTroughArrowFreqKey";
      
      private static const ANIMAL_FEED_NAME:String = "animalfeedtrough_feed";
      
      private static const ANIMAL_REINDEER_NAME:String = "reindeer";
      
      private static const REPLACEMENT_BUILDING_NAMES:Array = ["animal_breeding_wildlife","animal_breeding_wildlife_finished","animal_breeding_petrun","animal_breeding_petrun_finished","animal_breeding_zoo","animal_breeding_zoo_finished","animal_breeding_aviary","animal_breeding_aviary_finished","animal_breeding_livestock","animal_breeding_livestock_finished"];
      
      public static const TYPE_ANIMAL_NOT_PRESENT:int = 0;
      
      public static const TYPE_ANIMAL_SUCCESS:int = 1;
      
      public static const TYPE_ANIMAL_FAILURE:int = 2;
      
      private static const READY_SUFIX:int = 3;
      
      private static var m_waitingDialog:GenericPopup = null;
      
      public static const MINI_MARKET_ITEMS:Array = new Array(ANIMAL_FEED_NAME);
      
      private var m_adoptableAnimals:Array = null;
      
      private var m_hasAnimalInside:Boolean = false;
      
      private var m_rewardLink:String = null;
      
      private var m_claimState:int = 0;
      
      private var m_lastUsedFeedTimeStamp:Number = 0;
      
      private var m_isHarvesting:Boolean = false;
      
      public function FeedTroughBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      public function get rewardLink() : String
      {
         return this.m_rewardLink;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data["m_hasAnimal"] != null)
         {
            this.m_hasAnimalInside = data["m_hasAnimal"];
         }
         if(data["m_adoptableAnimals"] != null)
         {
            this.m_adoptableAnimals = data["m_adoptableAnimals"];
         }
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(this.m_lastUsedFeedTimeStamp == 0)
         {
            this.m_lastUsedFeedTimeStamp = Global.player.getFeatureLastShown(ARROW_FREQUENCY_KEY) > 0 ? Global.player.getFeatureLastShown(ARROW_FREQUENCY_KEY) : Number.MAX_VALUE;
         }
         this.checkArrowIndicator();
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         this.checkArrowIndicator();
      }
      
      override protected function checkArrowIndicator() : void
      {
         var shouldShowArrow:Boolean = false;
         var spr:Sprite = m_displayObject as Sprite;
         if(!Global.worldManager.isVisiting())
         {
            if(m_arrow == null && spr.numChildren > 0)
            {
               this.m_hideArrow = false;
               m_arrow = this.generateArrowIndicator();
               if(m_arrow != null)
               {
                  m_arrow.visible = true;
                  (m_displayObject as Sprite).addChild(m_arrow);
                  setArrowPosition();
                  m_showingArrow = true;
                  FarmStatsManager.count(ANIMAL_FEED_TROUGH_COUNTER,"trade_in","arrow_impressions");
               }
            }
         }
         else if(!m_showingArrow && !m_usingLoadingGraphic && !UI.isShowingPopup())
         {
            shouldShowArrow = GlobalEngine.serverTime / 1000 - this.m_lastUsedFeedTimeStamp >= FarmGameUtil.NUM_SECS_IN_DAY * Global.farmGameSettingsManager.getInt("animalFeedTroughInactivePromptDays",2);
            if(!this.isHarvestable() && shouldShowArrow && !Global.worldManager.isVisiting() && getCurrentCredits() < m_capacity)
            {
               if(m_arrow == null && spr.numChildren > 0)
               {
                  this.m_hideArrow = false;
                  m_arrow = this.generateArrowIndicator();
                  if(m_arrow != null)
                  {
                     m_arrow.visible = true;
                     (m_displayObject as Sprite).addChild(m_arrow);
                     setArrowPosition();
                     m_showingArrow = true;
                     FarmStatsManager.count(ANIMAL_FEED_TROUGH_COUNTER,"trough_idle","arrow_impressions");
                  }
               }
            }
         }
      }
      
      private function generateArrowIndicator() : DisplayObject
      {
         var iconPath:String = "";
         var title:String = "";
         var text:String = "";
         iconPath = Global.farmGameSettingsManager.getFarmItemByName(ANIMAL_REINDEER_NAME).icon;
         title = ZLocUtils.t("Dialogs","FeedTroughDeprecateTitle");
         text = ZLocUtils.t("Dialogs","FeedTroughDeprecateText");
         return new ArrowIndicatorWindow(iconPath,title,text);
      }
      
      override public function hideArrowDisplay() : void
      {
         if(Boolean(m_arrow) && Boolean(m_arrow.visible) && m_arrow.parent != null)
         {
            m_arrow.visible = false;
            m_arrow.parent.removeChild(m_arrow);
            m_arrow = null;
            conditionallyRedraw(true);
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         switch(state)
         {
            case STATE_BUILT:
               imageName = "built_" + this.getCurrentSuffix();
               if(!m_showingArrow)
               {
                  m_arrow = null;
               }
               break;
            case STATE_RIPE:
               imageName = "built_" + this.getCurrentSuffix();
               if(m_arrow == null)
               {
                  m_arrow = generateHarvestArrow();
               }
         }
         return imageName;
      }
      
      override public function getCurrentSuffix() : int
      {
         var result:int = 0;
         if(this.isHarvestable() == true)
         {
            result = READY_SUFIX;
         }
         else
         {
            result = super.getCurrentSuffix();
         }
         return result;
      }
      
      override public function getLocKeyPrefix() : String
      {
         var result:String = "FeedTroughBuildingHalf";
         if(isFull() == true)
         {
            result = "FeedTroughBuildingFull";
         }
         return result;
      }
      
      override protected function getLocalizedStateChangeDialogText() : String
      {
         return ZLocUtils.t("Dialogs",this.getLocKeyPrefix() + RewardCreditsBuilding.TOKEN_STATE_CHANGE);
      }
      
      override public function getDialogSideIconUrl() : String
      {
         var result:String = null;
         if(this.isFull() == true)
         {
            result = "assets/buildings/bldg_animalfeedtrough_2_icon.png";
         }
         else
         {
            result = "assets/buildings/bldg_animalfeedtrough_1_icon.png";
         }
         return result;
      }
      
      override public function getLevelIconUrl() : String
      {
         var result:String = null;
         if(this.isFull() == true)
         {
            result = "assets/newsfeed/feedtrough_full.png";
         }
         else
         {
            result = "assets/newsfeed/feedtrough_half.png";
         }
         return result;
      }
      
      override public function showMenu() : void
      {
      }
      
      override public function getBundlePrefix() : String
      {
         var result:String = null;
         if(this.isFull() == true)
         {
            result = "FeedTroughBuildingFull";
         }
         else
         {
            result = "FeedTroughBuildingHalf";
         }
         return result;
      }
      
      override public function onClick() : void
      {
         var localizedText:String = null;
         var farmItem:FarmItem = null;
         var message:GenericIconPopup = null;
         FarmStatsManager.count(ANIMAL_FEED_TROUGH_COUNTER,"building_clicked");
         if(m_showingArrow)
         {
            m_showingArrow = false;
            this.hideArrowDisplay();
            localizedText = ZLocUtils.t("Dialogs","FeedTroughDeprecateOne",{"quantity":getCurrentCredits() + 5});
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(ANIMAL_REINDEER_NAME);
            message = new GenericIconPopup(localizedText,GenericPopup.TYPE_OK,this.onClickOK,farmItem.icon);
            UI.displayPopup(message,true);
            TransactionManager.addTransaction(new TDeprecateItem(this),true);
         }
      }
      
      override public function isClearable() : Boolean
      {
         return true;
      }
      
      private function onCloseSharePrompt(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.askForAnimalFeed();
            FarmStatsManager.count(ANIMAL_FEED_TROUGH_COUNTER,"trough_idle","dialog_share_confirm");
         }
      }
      
      override protected function doPastNeighborAction(passNeighborUid:String) : void
      {
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         if(this.m_adoptableAnimals != null)
         {
            UI.displayPopup(new FeedTroughWindow(this),true,"",true);
         }
         else
         {
            this.displayOpeningDialog();
         }
      }
      
      override protected function getOwnerToolTipText() : String
      {
         var currentCredits:uint = 0;
         var result:String = null;
         if(this.isHarvestable() == false)
         {
            currentCredits = getCurrentCredits();
            result = ZLocUtils.t("Items",m_item.name + "_capacity",{
               "quantity":currentCredits,
               "maximum":m_capacity
            });
         }
         else
         {
            result = ZLocUtils.t("Dialogs","FeedTroughReady");
         }
         return result;
      }
      
      override protected function determineState(delta:Number) : void
      {
         if(this.isHarvestable() && (state == STATE_BARE || state == STATE_RIPE || state == STATE_BUILT))
         {
            setState(STATE_RIPE);
         }
      }
      
      override public function isHarvestable() : Boolean
      {
         return this.isFull() && this.m_hasAnimalInside == true;
      }
      
      override public function onSell() : void
      {
         super.onSell();
         this.reset();
      }
      
      override public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         this.m_isHarvesting = true;
         this.displayOpeningDialog();
         return super.harvest(energySource,energy,showNoEnergyMessage,updateBackend,neighborId);
      }
      
      private function displayOpeningDialog() : void
      {
         var message:String = null;
         if(m_waitingDialog == null)
         {
            message = ZLocUtils.t("Dialogs","FeedTroughBuilding_Opening");
            m_waitingDialog = new GenericPopup(message,GenericPopup.TYPE_MODAL,null);
         }
         UI.displayPopup(m_waitingDialog,false);
      }
      
      private function closeOpeningDialog() : void
      {
         if(m_waitingDialog != null)
         {
            m_waitingDialog.close();
         }
      }
      
      public function askForAnimalFeed() : void
      {
         TransactionManager.addTransaction(new TGetAskForAnimalFeedFriendReward(this),true);
      }
      
      public function displayAskForMoreFeed(data:Object) : void
      {
         var params:Object = null;
         var message:String = null;
         if(data != null && data.rewardUrl != null && data.rewardUrl != "")
         {
            params = {};
            params.images = [{
               "src":Global.getAssetURL(data.feedImg),
               "href":"{SN_APP_URL}" + data.rewardUrl
            }];
            params.reward_link = data.rewardUrl;
            GlobalEngine.socialNetwork.publishFeedStory(data.bundle,params,[],false);
         }
         else
         {
            message = ZLocUtils.t("Dialogs","FeedTroughBuilding_NoFriendReward");
            UI.displayPopup(new GenericPopup(message,GenericPopup.TYPE_OK),false);
         }
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         if(result["adoptableAnimals"] != null)
         {
            this.m_adoptableAnimals = result["adoptableAnimals"];
         }
         this.closeOpeningDialog();
         var message:String = ZLocUtils.t("Dialogs","FeedTroughBuilding_Place");
         var genericIconPopup:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onPlaceFeedPromptClose,Global.getAssetURL("assets/buildings/bldg_animalfeedtrough_0_icon.png"));
         UI.displayPopup(genericIconPopup);
      }
      
      private function onPlaceFeedPromptClose(event:GenericPopupEvent) : void
      {
         var feedTroughWindow:FeedTroughWindow = new FeedTroughWindow(this);
         UI.displayPopup(feedTroughWindow,false,"",true);
         feedTroughWindow.displayWhatIsThis();
         if(event.button == GenericPopup.ACCEPT)
         {
            this.askForAnimalFeed();
         }
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         this.m_isHarvesting = false;
         this.closeOpeningDialog();
         if(result["claimState"] != null)
         {
            this.m_claimState = parseInt(result["claimState"]);
         }
         var animal:FarmItem = null;
         if(result["animalName"] != null)
         {
            animal = Global.farmGameSettingsManager.getFarmItemByName(result["animalName"]);
            if(animal != null)
            {
               Global.player.addGift(animal.name);
               Global.player.addAdoptedAnimal(animal.code);
               if(this.m_claimState == TYPE_ANIMAL_SUCCESS)
               {
                  FarmStatsManager.count(ANIMAL_FEED_TROUGH_COUNTER,ANIMAL_FEED_TROUGH_KINGDOM,"claimed",animal.name);
               }
               else if(this.m_claimState == TYPE_ANIMAL_FAILURE)
               {
                  FarmStatsManager.count(ANIMAL_FEED_TROUGH_COUNTER,ANIMAL_FEED_TROUGH_KINGDOM,"missed",animal.name);
               }
            }
         }
         if(result["rewardLink"] != null)
         {
            this.m_rewardLink = result["rewardLink"];
         }
         this.reset();
         var feedTroughWindow:FeedTroughWindow = new FeedTroughWindow(this,this.m_claimState,animal);
         UI.displayPopup(feedTroughWindow,false,"",true);
      }
      
      public function getAdoptableAnimals() : Array
      {
         return this.m_adoptableAnimals;
      }
      
      override protected function reset() : void
      {
         var penalty:int = 0;
         this.m_hasAnimalInside = false;
         if(this.m_claimState == TYPE_ANIMAL_FAILURE)
         {
            penalty = Global.farmGameSettingsManager.getInt("animalFeedTroughPenalty",2);
            Global.player.addFeatureCredits(m_creditsFeatureName,penalty * -1);
            setState(STATE_BUILT);
         }
         else if(this.m_claimState == TYPE_ANIMAL_SUCCESS)
         {
            FarmStatsManager.count(ANIMAL_FEED_TROUGH_COUNTER,ANIMAL_FEED_TROUGH_KINGDOM,"state_change","emptied");
            super.reset();
         }
      }
      
      override public function canUpdateCursorOnVisit() : Boolean
      {
         return this.canBeClickedOnVisit();
      }
      
      override public function getCursor() : Class
      {
         var cursor:Class = null;
         if(Global.worldManager.isVisiting())
         {
            if(this.canBeClickedOnVisit())
            {
               cursor = EmbeddedArt.cursor_animal_trough_fill;
            }
         }
         else
         {
            cursor = super.getCursor();
         }
         return cursor;
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return false;
      }
      
      override protected function onVisitClick() : void
      {
         if(this.canBeClickedOnVisit() == true)
         {
            VisitorManager.getInstance().queueActionType(this,NeighborActionConstants.LIMIT_TYPE_SEND_ANIMAL_FEED);
            Global.selectedAvatar.getStateMachine().addState(new AMFillFeedTrough(Global.selectedAvatar,this),true);
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         this.updateArrowIndicator();
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.updateArrowIndicator();
      }
      
      private function updateArrowIndicator() : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Global.selectedAvatar)
         {
            arrowIndicatorWindow = m_arrow as ArrowIndicatorWindow;
            if(arrowIndicatorWindow)
            {
               arrowIndicatorWindow.showRolloverText(isHighlighted());
            }
         }
      }
      
      private function onClickOK(event:GenericPopupEvent) : void
      {
         var localizedText:String = ZLocUtils.t("Dialogs","FeedTroughDeprecateTwo");
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(ANIMAL_FEED_NAME);
         var message:GenericIconPopup = new GenericIconPopup(localizedText,GenericPopup.OK,this.onBuyFromMarket,farmItem.icon);
         UI.displayPopup(message,true);
      }
      
      private function onBuyFromMarket(event:GenericPopupEvent) : void
      {
         UI.displayMiniMarketDialog(REPLACEMENT_BUILDING_NAMES,UI.MARKET_CONTEXT_UNKNOWN,"building",null,true);
      }
   }
}


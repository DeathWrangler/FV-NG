package Widgets.Windows.Mastery
{
   import Classes.Animal;
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.MapResource;
   import Classes.Mastery;
   import Classes.Plot;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.Quest.FarmTask;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Managers.SmartPopupManager;
   import Managers.WorldScoreSettingsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import ZQuest.Init.QuestSettingsInit;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MasteryLevelupWindow extends FarmWindow
   {
      
      private static const ASSET_PATH_CHECKBOX:String = "assets/dialogs/FV_MasteryDialog_checkbox.swf";
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_MasteryDialog.swf";
      
      private static const ASSET_PATH_BRANDED:String = "assets/dialogs/FV_ZapMasteryDialog.swf";
      
      private static const GET_MASTERY_FEED_ACTION:String = "GetMastery_new";
      
      private static const GET_ANIMAL_MASTERY_FEED_ACTION:String = "GetAnimalMastery";
      
      private static const DOUBLE_GET_MASTERY_FEED_ACTION:String = "DoubleGetMastery";
      
      private static const ITEM_BOX_WIDTH:Number = 100;
      
      private static const ITEM_BOX_HEIGHT:Number = 100;
      
      private static const PRIZE_BOX_WIDTH:Number = 50;
      
      private static const PRIZE_BOX_HEIGHT:Number = 50;
      
      private static const MASTERY_LEVEL_BRONZE:int = 0;
      
      private static const MASTERY_LEVEL_SILVER:int = 1;
      
      private static const MASTERY_LEVEL_GOLD:int = 2;
      
      private static const MASTERY_LEVELUP_SOUND:String = "masteryLevelUp";
      
      private static const OPENED_MASTERY_WINDOW_FLAG:String = "openedMasteryWindow";
      
      private var m_masteryType:String;
      
      private var m_masteryItem:FarmItem;
      
      private var m_masteryCurrentLevel:int;
      
      private var m_masteryCode:String;
      
      private var m_masteryXp:int;
      
      private var m_masteryGold:int;
      
      private var m_checkMark:MovieClip = null;
      
      private var m_checkBox:FarmAnimatedButton = null;
      
      private var m_selected:Boolean = true;
      
      private var m_masteryGift:String;
      
      private var m_masteryHasAllMasteries:Boolean;
      
      private var m_masteryStatsCounter:String;
      
      private var m_masteryName:String;
      
      private var m_masteryGetCurrentCount:int;
      
      private var m_masteryExtraMasteryWeekendEnabled:Boolean;
      
      private var m_masteryFriendlyName:String;
      
      private var m_masteryCurrentStar:String;
      
      private var m_feedCheckboxFlow:Number = 0;
      
      private var m_link:String;
      
      private var m_trackerKey:String;
      
      private var m_giveReward:Boolean = false;
      
      private var m_returnReward:Boolean = false;
      
      private var m_fireworkMovieClip:MovieClip = null;
      
      private var m_decrementDialogCounterCallback:Function = null;
      
      private var m_surfaceBuildingItem:FarmItem;
      
      private var m_worldScoreOverride:int = 0;
      
      private var m_worldScoreOverrideType:String;
      
      public function MasteryLevelupWindow(mastery:Mastery, link:String, difficulty:int, giveReward:Boolean = true, decrementDialogCounterCallback:Function = null)
      {
         var assetPath:String = null;
         var masteryTask:FarmTask = null;
         var billboardSharePlace:Number = NaN;
         var rewards:Vector.<Object> = null;
         var reward:Object = null;
         SoundManager.addSound("masteryLevelUp",Global.getAssetURL("assets/sounds/sfx_crop_mastery_02.mp3"),false);
         this.SetMasteryData(mastery);
         this.m_giveReward = giveReward;
         this.m_link = link;
         this.m_decrementDialogCounterCallback = decrementDialogCounterCallback;
         this.m_trackerKey = "feed-" + this.m_masteryType + "_mastery";
         if(Global.hud.isVisualEffectsLocked())
         {
            this.m_returnReward = true;
            Global.player.xp -= this.m_masteryXp;
            Global.player.gold -= this.m_masteryGold;
         }
         if(Boolean(this.m_masteryItem) && this.m_masteryItem.isBrandedItem)
         {
            assetPath = ASSET_PATH_BRANDED;
         }
         else
         {
            this.m_feedCheckboxFlow = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FEED_CHECKBOX_FLOW);
            billboardSharePlace = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BLOOMBILLBOARD_SHAREPLACE);
            if(billboardSharePlace != 0 || this.m_feedCheckboxFlow <= 1)
            {
               assetPath = ASSET_PATH;
            }
            else
            {
               assetPath = ASSET_PATH_CHECKBOX;
            }
         }
         var masteryByCategoryTasks:Vector.<FarmTask> = Global.worldScoreSettingsManager.getTasksOfAction(Global.worldManager.currentWorldScoreId,[QuestConstants.TASK_GET_MASTERY_LEVEL_BY_CATEGORY]);
         masteryByCategoryTasks = masteryByCategoryTasks.concat(Global.worldScoreSettingsManager.getTasksOfAction(Global.worldManager.currentWorldScore2Id,[QuestConstants.TASK_GET_MASTERY_LEVEL_BY_CATEGORY]));
         masteryByCategoryTasks = masteryByCategoryTasks.concat(Global.worldScoreSettingsManager.getTasksOfAction(WorldScoreSettingsManager.KEY_GLOBAL,[QuestConstants.TASK_GET_MASTERY_LEVEL_BY_CATEGORY]));
         for each(masteryTask in masteryByCategoryTasks)
         {
            if((QuestSettingsInit.getInstance() as FarmQuestSettingsInit).isItemCodeInCategory(mastery.code,masteryTask.type))
            {
               rewards = masteryTask.rewards;
               for each(reward in rewards)
               {
                  if(reward.type == QuestConstants.REWARD_WORLD_SCORE && masteryTask.extraData["level"] == this.m_masteryCurrentLevel + 1)
                  {
                     this.m_worldScoreOverride = reward.value;
                     this.m_worldScoreOverrideType = reward.unit;
                     break;
                  }
               }
               if(this.m_worldScoreOverride > 0)
               {
                  break;
               }
            }
         }
         super(assetPath);
      }
      
      private function SetMasteryData(mastery:Mastery) : void
      {
         this.m_masteryType = mastery.type;
         this.m_masteryItem = Global.farmGameSettingsManager.getFarmItemByCode(mastery.code);
         this.m_masteryCurrentLevel = mastery.currentLevel;
         this.m_masteryCode = mastery.code;
         this.m_masteryXp = mastery.xp;
         this.m_masteryGold = mastery.gold;
         this.m_masteryHasAllMasteries = mastery.hasAllMasteries();
         this.m_masteryStatsCounter = mastery.statsCounter;
         this.m_masteryName = mastery.name;
         this.m_masteryGetCurrentCount = mastery.getCurrentCount();
         this.m_masteryExtraMasteryWeekendEnabled = mastery.extraMasteryWeekendEnabled(this.m_masteryType);
         this.m_masteryFriendlyName = mastery.friendlyName;
         this.m_masteryCurrentStar = mastery.currentStar;
         this.m_masteryGift = mastery.gift;
      }
      
      override protected function postLoadComplete() : void
      {
         var xpIcon:FarmIcon = null;
         var xpAmount:int = 0;
         var shareButton:FarmAnimatedTextButton = null;
         var mapResourceItem:MapResource = null;
         var masteryIcon:FarmIcon = null;
         var itemDisplayObject:ObjectPreviewFrame = null;
         var buttonText:String = null;
         var items:Array = null;
         var worldItem:MapResource = null;
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.goldTitle_tf,ZLocUtils.t("Dialogs","Congratulations")));
         addWidget(new ZwTextField(m_window.master_1_tf,ZLocUtils.t("Dialogs","MasteryTitle",{"quantity":this.m_masteryCurrentLevel + 1})));
         addWidget(new ZwTextField(m_window.master_2_tf,ZLocUtils.t("Dialogs","MasterySubTitle",{"item":ZLocUtils.tk("Items",this.m_masteryName + "_friendlyName")})));
         if(this.m_masteryGift != "" && this.m_giveReward == true && Global.player.masterySignEnabled())
         {
            Global.player.addGift(this.m_masteryGift);
         }
         var masteryRewardShare:String = ZLocUtils.t("Dialogs","MasteryRewardShare");
         var masteryRewardCheckboxText:String = ZLocUtils.t("Dialogs","MasteryRewardCheckboxText");
         if(this.m_masteryHasAllMasteries == true)
         {
            masteryRewardShare = ZLocUtils.t("Dialogs","MasteryRewardShareSign") + " " + masteryRewardShare;
         }
         if(Boolean(this.m_masteryItem) && Boolean(this.m_masteryItem.isBrandedItem) && Global.player.masterySignEnabled())
         {
            masteryRewardShare = ZLocUtils.t("Dialogs","MasteryRewardShare") + "\n\n" + ZLocUtils.t("Dialogs",this.m_masteryItem.name + "_FirstPlacementBottomMsg");
            addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Dialogs","FBVisit"),this.onVisitClick));
         }
         if(m_window.hasOwnProperty("master_3_tf") && Global.player.masterySignEnabled())
         {
            addWidget(new ZwTextField(m_window.master_3_tf,masteryRewardShare));
         }
         if(m_window.hasOwnProperty("checkbox_tf"))
         {
            if(Global.player.masterySignEnabled())
            {
               addWidget(new ZwTextField(m_window.checkbox_tf,masteryRewardCheckboxText));
               this.m_checkMark = m_window.checkMark_mc as MovieClip;
               this.m_checkMark.mouseEnabled = true;
               this.m_checkMark.visible = this.m_selected = true;
               this.m_checkMark.addEventListener(MouseEvent.CLICK,this.onClick);
               this.m_checkBox = addWidget(new FarmAnimatedButton(m_window.checkBox_mc,this.onClick)) as FarmAnimatedButton;
            }
            else
            {
               addWidget(new ZwTextField(m_window.checkbox_tf,ZLocUtils.t("Dialogs","MasteryRewardCheckboxText_New")));
            }
         }
         var itemState:String = "";
         switch(this.m_masteryType)
         {
            case MasteryWindow.TYPE_SEED:
               itemState = Plot.STATE_GROWN;
               break;
            case MasteryWindow.TYPE_TREE:
               itemState = SimpleHarvestableResource.STATE_RIPE;
               break;
            case MasteryWindow.TYPE_ANIMAL:
               itemState = Animal.STATE_FRONT_IDLE;
         }
         switch(this.m_masteryCurrentLevel)
         {
            case MASTERY_LEVEL_BRONZE:
               this.m_fireworkMovieClip = m_window.bronze_mc;
               break;
            case MASTERY_LEVEL_SILVER:
               this.m_fireworkMovieClip = m_window.silver_mc;
               break;
            case MASTERY_LEVEL_GOLD:
               this.m_fireworkMovieClip = m_window.gold_mc;
               if(this.m_masteryGift != "" && this.m_giveReward == true && Global.player.masterySignEnabled())
               {
                  mapResourceItem = new MapResource(this.m_masteryGift);
                  this.m_surfaceBuildingItem = FeatureBuildingSurfacingManager.getInstance().conditionallyGetBuildingToSurface(mapResourceItem,FeatureBuildingSurfacingManager.MASTERYBILLBOARD_SURFACING_KEYWORD);
               }
         }
         if(this.m_fireworkMovieClip != null)
         {
            this.m_fireworkMovieClip.gotoAndStop(1);
            addWidget(new ZwFrame(this.m_fireworkMovieClip));
         }
         var masteryItemIconUrl:String = this.m_masteryItem.masteryIconUrl();
         if(masteryItemIconUrl)
         {
            masteryIcon = new FarmIcon(m_window.icon_mc,masteryItemIconUrl);
            addWidget(masteryIcon);
         }
         else
         {
            itemDisplayObject = new ObjectPreviewFrame(m_window.icon_mc,this.m_masteryItem,null,null,[ITEM_BOX_WIDTH],itemState);
            itemDisplayObject.y += ITEM_BOX_HEIGHT / 2;
            addWidget(itemDisplayObject);
         }
         var coinIcon:FarmIcon = new FarmIcon(m_window.icon1_mc,"assets/decorations/fv_coin_icon.png");
         coinIcon.setIconWidth(PRIZE_BOX_WIDTH);
         coinIcon.setIconHeight(PRIZE_BOX_HEIGHT);
         addWidget(coinIcon);
         addWidget(new ZwTextField(m_window.prize1_tf,ZLocUtils.t("Dialogs","MasteryRewardPrize",{"quantity":this.m_masteryGold})));
         if(this.m_worldScoreOverride > 0)
         {
            xpIcon = new FarmIcon(m_window.icon2_mc,"assets/decorations/fv_zp_icon.png");
            xpAmount = this.m_worldScoreOverride;
         }
         else
         {
            xpIcon = new FarmIcon(m_window.icon2_mc,"assets/decorations/fv_xp_icon.png");
            xpAmount = this.m_masteryXp;
         }
         xpIcon.setIconWidth(PRIZE_BOX_WIDTH);
         xpIcon.setIconHeight(PRIZE_BOX_HEIGHT);
         addWidget(xpIcon);
         addWidget(new ZwTextField(m_window.prize2_tf,ZLocUtils.t("Dialogs","MasteryRewardPrize",{"quantity":xpAmount})));
         var starsFrame:ZwFrame = new ZwFrame(m_window.stars_mc);
         addWidget(starsFrame);
         (m_window.stars_mc as MovieClip).gotoAndStop(this.m_masteryCurrentLevel + 1);
         starsFrame.visible = true;
         if(this.m_surfaceBuildingItem != null && m_window.sharePlace_bt != null)
         {
            shareButton = new FarmAnimatedTextButton(m_window.sharePlace_bt,ZLocUtils.t("Dialogs","ShareAndPlace"),this.onShareClick);
            m_window.share_bt.visible = false;
            m_window.sharePlace_bt.visible = true;
         }
         else
         {
            buttonText = null;
            if(this.m_feedCheckboxFlow > 1)
            {
               buttonText = ZLocUtils.t("Dialogs","Continue");
            }
            else
            {
               buttonText = ZLocUtils.t("Dialogs","Share");
            }
            shareButton = new FarmAnimatedTextButton(m_window.share_bt,buttonText,this.onShareClick);
            m_window.share_bt.visible = true;
            if(m_window.sharePlace_bt != null)
            {
               m_window.sharePlace_bt.visible = false;
            }
         }
         addWidget(shareButton);
         if(Boolean(this.m_masteryItem) && Boolean(this.m_masteryItem.isVipItem()) && Global.player.masterySignEnabled())
         {
            items = Global.world.getObjectsByName(this.m_masteryItem.name);
            for each(worldItem in items)
            {
               worldItem.reloadImage();
            }
         }
         var counterMasteryLevel:int = this.m_masteryCurrentLevel + 1;
         FarmStatsManager.count(this.m_masteryType + "_mastery",this.m_masteryItem.subsubtype,this.m_masteryItem.name,counterMasteryLevel.toString() + "star");
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(this.m_feedCheckboxFlow > 2)
         {
            if(m_window.hasOwnProperty("close_bt") && Boolean(m_closeButton))
            {
               m_closeButton.visible = false;
            }
         }
      }
      
      public function onClick(event:MouseEvent) : void
      {
         this.m_checkMark.visible = this.m_selected = !this.m_selected;
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         SmartPopupManager.getInstance().popupAccepted(this.m_trackerKey,"view");
         SoundManager.playSound(MASTERY_LEVELUP_SOUND);
         if(this.m_fireworkMovieClip != null)
         {
            this.m_fireworkMovieClip.play();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(this.m_masteryStatsCounter,"click_cancel",this.m_masteryCode,this.m_masteryCurrentLevel.toString(),this.m_masteryName);
         SmartPopupManager.getInstance().popupAccepted(this.m_trackerKey,"Cancel");
         super.onClose(event);
         this.conditionallyOpenMasteryWindow();
         if(this.m_surfaceBuildingItem != null && Global.player.masterySignEnabled())
         {
            FeatureBuildingSurfacingManager.getInstance().surfaceFeatureBuildingCancel(this.m_surfaceBuildingItem);
         }
      }
      
      private function getFeedImage() : String
      {
         var starImage:String = "";
         switch(this.m_masteryCurrentStar)
         {
            case "None":
            case "OneStar":
               starImage = "crop_mastery01_cb.png";
               break;
            case "TwoStars":
               starImage = "crop_mastery02_cb.png";
               break;
            case "ThreeStars":
               starImage = "crop_mastery03_cb.png";
         }
         return starImage;
      }
      
      public function onVisitClick(event:MouseEvent) : void
      {
         var masteryItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_masteryCode);
         if(masteryItem.isBrandedItem && masteryItem.brandPromoData.brandUrl != "")
         {
            FarmGameUtil.launchURL(masteryItem.brandPromoData.brandUrl,"_blank",null,true);
         }
      }
      
      public function onShareClick(event:MouseEvent) : void
      {
         var feedImage:String = null;
         if(!this.selected)
         {
            this.onClose(null);
            return;
         }
         if(!Global.player.masterySignEnabled())
         {
            this.onClose(null);
            return;
         }
         FarmStatsManager.count(this.m_masteryStatsCounter,"Click_share_wealth",this.m_masteryCode,this.m_masteryCurrentLevel.toString(),this.m_masteryName);
         SmartPopupManager.getInstance().popupAccepted(this.m_trackerKey,"Share");
         var level:int = this.m_masteryCurrentLevel + 1;
         var cur_count:int = this.m_masteryGetCurrentCount;
         var levelSubcategory:String = "Level_" + level.toString();
         var masteryItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_masteryCode);
         if(Boolean(masteryItem) && Boolean(masteryItem.masteryIconUrl(false,level)))
         {
            feedImage = masteryItem.masteryIconUrl(false,level);
         }
         else if(Boolean(masteryItem) && Boolean(masteryItem.iconUrl))
         {
            feedImage = masteryItem.iconRelativeUrl;
         }
         else
         {
            feedImage = "assets/newsfeed/" + this.getFeedImage();
         }
         var images:Array = [{
            "src":Global.getAssetURL(feedImage),
            "href":"{SN_APP_URL}" + this.m_link
         }];
         var resourceString:String = "Mastery_Farm_Trivia_" + this.m_masteryName;
         var masteryText:String = "";
         if(ZLocUtils.hasString("Notifications",resourceString))
         {
            masteryText = "Notifications:" + resourceString;
         }
         var feedAction:String = GET_MASTERY_FEED_ACTION;
         if(this.m_masteryType == MasteryWindow.TYPE_ANIMAL)
         {
            feedAction = GET_ANIMAL_MASTERY_FEED_ACTION;
         }
         else if(this.m_masteryExtraMasteryWeekendEnabled)
         {
            feedAction = DOUBLE_GET_MASTERY_FEED_ACTION;
         }
         var masteryFeedObject:Object = {
            "subCategory":levelSubcategory,
            "mastery_level":level,
            "masteryLevel":level,
            "mastery_name":this.m_masteryFriendlyName,
            "masteryName":this.m_masteryFriendlyName,
            "images":images,
            "reward_link":this.m_link,
            "first_name":Global.player.firstName,
            "mastery_count":cur_count
         };
         if(this.m_masteryType == MasteryWindow.TYPE_TREE)
         {
            masteryFeedObject["treeName"] = this.m_masteryFriendlyName;
            masteryFeedObject["mastery_trivia"] = masteryText;
            masteryFeedObject["mastery_bodytext"] = "Notifications:Mastery_FeedBodyTextTree";
         }
         else if(this.m_masteryType == MasteryWindow.TYPE_ANIMAL)
         {
            masteryFeedObject["animalName"] = this.m_masteryFriendlyName;
            masteryFeedObject["mastery_bodytext"] = "Notifications:Mastery_FeedBodyTextAnimal";
         }
         else
         {
            masteryFeedObject["mastery_trivia"] = masteryText;
            masteryFeedObject["mastery_bodytext"] = "Notifications:Mastery_FeedBodyText";
         }
         var customBodyTextResource:String = "Mastery_FeedBodyText_" + this.m_masteryName;
         if(ZLocUtils.hasString("Notifications",customBodyTextResource))
         {
            masteryFeedObject["mastery_bodytext"] = "Notifications:" + customBodyTextResource;
         }
         GlobalEngine.socialNetwork.publishFeedStory(feedAction,masteryFeedObject,[],false);
         event.stopPropagation();
         this.close();
         if(this.m_surfaceBuildingItem != null && Global.player.masterySignEnabled())
         {
            FeatureBuildingSurfacingManager.getInstance().surfaceFeatureBuildingFrame(this.m_surfaceBuildingItem);
            FeatureBuildingSurfacingManager.getInstance().surfaceFeatureBuildingCancel(this.m_surfaceBuildingItem);
         }
         else
         {
            this.conditionallyOpenMasteryWindow();
         }
      }
      
      override public function close() : void
      {
         var decrementCounter:Boolean = false;
         if(this.m_giveReward || this.m_returnReward)
         {
            Global.hud.unlockVisualEffects();
            Global.player.xp += this.m_masteryXp;
            Global.player.updateWorldCurrency(Currency.COINS,this.m_masteryGold,true);
         }
         super.close();
         if(this.m_decrementDialogCounterCallback != null)
         {
            decrementCounter = this.m_masteryHasAllMasteries == false;
            this.m_decrementDialogCounterCallback(decrementCounter);
         }
      }
      
      private function conditionallyOpenMasteryWindow() : void
      {
         if(!Global.player.getSeenSessionFlag(OPENED_MASTERY_WINDOW_FLAG) && this.m_masteryHasAllMasteries && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_AUTO_POP_LEVELUP_MASTERY_OPTOUT) == 0)
         {
            UI.displayPopup(new MasteryWindow(this.m_masteryType,Global.farmGameSettingsManager.getFarmItemByCode(this.m_masteryCode)));
            Global.player.setSeenSessionFlag(OPENED_MASTERY_WINDOW_FLAG);
         }
      }
   }
}


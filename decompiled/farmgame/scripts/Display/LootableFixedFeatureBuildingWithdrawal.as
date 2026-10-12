package Display
{
   import Cache.Classes.ZCacheUtil;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.ImageLoader;
   import Classes.StorageBuilding;
   import Classes.ZItem.LootItem;
   import Classes.util.MovieClipAnimation;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Engine.ArrayUtil;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Events.MovieClipEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.JMInnovationManager;
   import Managers.TemplateUIUtility;
   import Managers.WorldSeasonsManager;
   import Transactions.TFetchLoot;
   import Widgets.Buttons.FarmAnimatedMultiTextButton;
   import Widgets.Windows.FarmWindowWithTutorial;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class LootableFixedFeatureBuildingWithdrawal extends FeatureBuildingWithdrawal
   {
      
      private static const m_regionTimerTxt:String = "region1_timer_txt";
      
      private static const ICON_IMAGE_NAME:String = "icon";
      
      private static const DEFAULT_TEASER_PRIZE_ANIM_DELAY_MSEC:int = 3000;
      
      private static var s_potentialLoot:Array = null;
      
      private static var s_lootItemIcons:Dictionary = new Dictionary();
      
      public static const TUTORIAL_FLAG_SUFFIX:String = "_Tutorial";
      
      private const SLOT_V_PREFIX:String = "mc_Slot_V_";
      
      private var m_lastLootIndex:int;
      
      private var m_cart:MovieClipAnimation;
      
      private var m_cartTimer:Timer;
      
      private var m_iconLoader:Loader;
      
      private var m_lootItem:LootItem = null;
      
      private var m_isAtMaxExpansionLevel:Boolean;
      
      private var m_dialogConfig:Object = null;
      
      private var m_bgLoader:ImageLoader;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_slotbgIcon:DisplayObject = null;
      
      public function LootableFixedFeatureBuildingWithdrawal(storage:StorageBuilding)
      {
         this.m_dialogConfig = storage.getItem().getDialogConfig("storage");
         super(this.getDialogAssetPath(),storage.getItemName() + "_withdrawal",storage.getItemName() + "_withdrawal",storage);
         this.m_isAtMaxExpansionLevel = m_building.hasReachedMaxExpansionLevel();
         this.m_cartTimer = new Timer(this.getTeaserPrizeAnimationDelayMilSec(),1);
         this.m_cartTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onCartTimerComplete,false,0,true);
         if(this.getBackgroundAssetPath())
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.getBackgroundAssetPath()));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         this.initPotentialLoot();
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      private function onSlotURLLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotbgIcon = dispObj;
      }
      
      private function getDialogConfigParam(param:String, required:Boolean = true) : String
      {
         var result:String = null;
         if(Boolean(this.m_dialogConfig) && this.m_dialogConfig.hasOwnProperty(param))
         {
            result = this.m_dialogConfig[param];
         }
         else if(required)
         {
            ErrorManager.addError("LootableFixedFeatureBuildingWithdrawal:getDialogConfigParam() failed to find required \"" + param + "\" attribute in data");
         }
         return result;
      }
      
      private function getDialogAssetPath() : String
      {
         return this.getDialogConfigParam("path");
      }
      
      private function getBackgroundAssetPath() : String
      {
         return this.getDialogConfigParam("bgPath",false);
      }
      
      private function getWhatIsThisImagePrefix() : String
      {
         return this.getDialogConfigParam("whatIsThisImagePrefix");
      }
      
      private function getLootKey() : String
      {
         return this.getDialogConfigParam("harvestLootKey");
      }
      
      private function getTeaserPrizeAnimationDelayMilSec() : int
      {
         var result:int = DEFAULT_TEASER_PRIZE_ANIM_DELAY_MSEC;
         var delay:String = this.getDialogConfigParam("teaserPrizeAnimationDelaySeconds",false);
         if(delay)
         {
            result = Number(delay) * 1000;
         }
         return result;
      }
      
      private function triggerJapanTutorial() : void
      {
         if(this.m_building.getItemName() == "xjp_bigbuildable" && !Global.player.getSeenFlag(this.m_building.getItemName() + TUTORIAL_FLAG_SUFFIX))
         {
            UI.stopPopups(true);
            this.displayTutorial();
         }
      }
      
      private function displayTutorial(e:Event = null) : void
      {
         UI.displayPopup(new FarmWindowWithTutorial(this.m_building.getItemName(),"assets/dialogs/Japan/FV_xjp_Japan_Buildable_FTUE.swf",4,true,false,true,true),false);
      }
      
      private function conditionallyDisplayJungleInnovationCard() : void
      {
         if(m_window.main_mc.innovation_mc)
         {
            m_window.main_mc.innovation_mc.visible = false;
            if(JMInnovationManager.getInstance().isActive())
            {
               m_window.main_mc.innovation_mc.visible = true;
            }
         }
      }
      
      override protected function onLoadComplete() : void
      {
         var levelStartingAtZero:int = 0;
         super.onLoadComplete();
         this.conditionallyDisplayJungleInnovationCard();
         m_window.main_mc.description_tf.text = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",m_storage.getItemName() + m_storage.storageLevel.toString() + "_DialogDescription"),new ZLocFailoverEntry("Dialogs",m_storage.getItemName() + "_DialogDescription")]);
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_window.main_mc.description_tf);
         }
         if(Boolean(m_window.main_mc.mc_AnimalFrame_big) && Boolean(this.m_bgIcon))
         {
            m_window.main_mc.addChildAt(this.m_bgIcon,m_window.main_mc.getChildIndex(m_window.main_mc.mc_AnimalFrame_big));
         }
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.main_mc.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.main_mc.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.main_mc.title_tf);
         }
         if(m_window.main_mc.stageNumber_tf)
         {
            levelStartingAtZero = m_storage.storageLevel - 1;
            m_window.main_mc.stageNumber_tf.text = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",m_storage.getItemName() + m_storage.storageLevel.toString() + "_DialogStageNumber"),new ZLocFailoverEntry("Dialogs",m_storage.getItemName() + "_DialogStageNumber")],{"level_num":levelStartingAtZero.toString()});
         }
         var textArray:Array = new Array();
         textArray["generic_tf"] = ZLocUtils.t("Dialogs",m_storage.getItemName() + "_DialogSpeedUpButton");
         textArray["cash_tf"] = String(Global.farmGameSettingsManager.getNumber(m_storage.getItemName() + "HarvestReadyNowCashPrice",-1));
         new FarmAnimatedMultiTextButton(m_window.main_mc.buy_bt,textArray,this.frictionlessHarvestReadyNow);
         var levelIndex:int = 0;
         while(m_window.main_mc.hasOwnProperty("stage_" + levelIndex + "_mc"))
         {
            m_window.main_mc["stage_" + levelIndex + "_mc"].generic_tf.text = levelIndex + 1;
            levelIndex++;
         }
         var slot100BGPath:String = Global.worldSettingsManager.getSlotBGImagePath("V100");
         var slot80BGPath:String = Global.worldSettingsManager.getSlotBGImagePath("V80");
         var slotIndex:int = 0;
         while(m_window.main_mc.hasOwnProperty("mc_Slot_V_" + slotIndex))
         {
            if(Boolean(slot100BGPath) && Boolean(slot80BGPath))
            {
               if(slotIndex < 2)
               {
                  ImageLoader.getInstance(Global.getAssetURL(slot100BGPath)).getContent(this.onSlotURLLoaded);
                  if(this.m_slotbgIcon)
                  {
                     m_window.main_mc[this.SLOT_V_PREFIX + slotIndex].addChildAt(this.m_slotbgIcon,1);
                     m_window.main_mc[this.SLOT_V_PREFIX + slotIndex].removeChildAt(0);
                  }
               }
               else
               {
                  ImageLoader.getInstance(Global.getAssetURL(slot80BGPath)).getContent(this.onSlotURLLoaded);
                  if(this.m_slotbgIcon)
                  {
                     m_window.main_mc[this.SLOT_V_PREFIX + slotIndex].addChildAt(this.m_slotbgIcon,1);
                     m_window.main_mc[this.SLOT_V_PREFIX + slotIndex].removeChildAt(0);
                  }
               }
            }
            slotIndex++;
         }
         var prizeCart:MovieClip = m_window.main_mc.prizeCart_mc as MovieClip;
         if(prizeCart)
         {
            this.m_cart = new MovieClipAnimation(prizeCart,1,false,false);
            this.m_cart.addEventListener(MovieClipEvent.LOOP_COMPLETE,this.onCartLoopComplete);
            setVisibility(prizeCart,"cart_mc",false);
         }
         refreshProgressMeter();
         this.triggerJapanTutorial();
         if(m_window.main_mc.ftue_mc)
         {
            m_whatIsThisBtn = new GenericButton(m_window.main_mc.ftue_mc,this.displayTutorial);
            m_whatIsThisBtn.m_overlay.name = "WhatIsThisBtn";
            m_whatIsThisBtn.text = ZLocUtils.t("Dialogs","WhatIsThis");
         }
      }
      
      override protected function pushNewData() : void
      {
         var maxBuilidingExpansionData:BuildingExpansionData = null;
         var maxExpansionData:BaseDataSource = null;
         var maxExpansion:XML = null;
         if(StorageBuilding.isDynamicPartsExperimentOn())
         {
            if(this.m_isAtMaxExpansionLevel)
            {
               maxBuilidingExpansionData = m_building.getBuildingExpansionDataByLevel(m_building.getItem().getMaxUpgradeLevel());
               super.pushBuildingExpansionData(maxBuilidingExpansionData);
            }
            else
            {
               super.pushNewData();
            }
         }
         else if(this.m_isAtMaxExpansionLevel)
         {
            maxExpansionData = null;
            maxExpansion = null;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               maxExpansionData = m_building.getItem().getMaxUpgradeDataSource();
            }
            else
            {
               maxExpansion = m_building.getItem().getMaxUpgradeData();
            }
            super.pushUpgradeData(maxExpansion,maxExpansionData);
         }
         else
         {
            super.pushNewData();
         }
      }
      
      private function frictionlessHarvestReadyNow(ev:Event) : void
      {
         (m_building as FeatureBuilding).frictionlessHarvestReadyNow();
         close();
      }
      
      private function hideOverlayDialog(main_mc:MovieClip) : void
      {
         var overlayTag:String = null;
         var worldType:String = Global.worldManager.currentWorldType;
         var seasons:int = WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldType);
         var currentSeason:int = WorldSeasonsManager.getInstance().getCurrentSeason(worldType);
         for(var j:int = 0; j <= seasons; j++)
         {
            overlayTag = "overlay" + j + "_mc";
            if(main_mc[overlayTag])
            {
               main_mc[overlayTag].visible = false;
            }
         }
      }
      
      private function displayOverlayDialog(main_mc:MovieClip) : void
      {
         var overlayTag:String = null;
         var unlockDate:Object = null;
         var worldType:String = Global.worldManager.currentWorldType;
         var seasons:int = WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldType);
         var currentSeason:int = WorldSeasonsManager.getInstance().getCurrentSeason(worldType);
         var playerNextSeason:int = WorldSeasonsManager.getInstance().getNextPlayerSeason(worldType);
         var accessType:String = WorldSeasonsManager.getInstance().getAccessType(worldType);
         for(var i:int = 0; i <= seasons; i++)
         {
            overlayTag = "overlay" + i + "_mc";
            if(main_mc[overlayTag])
            {
               if(i == currentSeason)
               {
                  main_mc[overlayTag].visible = true;
                  unlockDate = WorldSeasonsManager.getInstance().getSeasonUnlockETA(worldType,playerNextSeason,accessType);
                  if(unlockDate.days > 0)
                  {
                     main_mc[overlayTag][m_regionTimerTxt].text = "Unlocks in " + unlockDate.days + " days";
                  }
                  else if(unlockDate.hours > 0)
                  {
                     main_mc[overlayTag][m_regionTimerTxt].text = "Unlocks in " + unlockDate.hours + " hours";
                  }
                  else if(unlockDate.minutes > 0)
                  {
                     main_mc[overlayTag][m_regionTimerTxt].text = "Unlocks in " + unlockDate.minutes + " minutes";
                  }
                  else if(unlockDate.seconds > 0)
                  {
                     main_mc[overlayTag][m_regionTimerTxt].text = "Unlocks in " + unlockDate.seconds + " seconds";
                  }
                  else
                  {
                     main_mc[overlayTag][m_regionTimerTxt].text = "Reload the game!";
                  }
               }
               else
               {
                  main_mc[overlayTag].visible = false;
               }
            }
         }
      }
      
      private function hideSideCard(main_mc:MovieClip) : void
      {
         var sidecardTag:String = null;
         var worldType:String = Global.worldManager.currentWorldType;
         var seasons:int = WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldType);
         for(var j:int = 0; j <= seasons; j++)
         {
            sidecardTag = "sidecard" + j;
            if(main_mc[sidecardTag])
            {
               main_mc[sidecardTag].visible = false;
            }
         }
      }
      
      private function displaySideCard(main_mc:MovieClip) : void
      {
         var sidecardTag:String = null;
         var worldType:String = Global.worldManager.currentWorldType;
         var seasons:int = WorldSeasonsManager.getInstance().getNumSeasonsForWorld(worldType);
         var currentSeason:int = WorldSeasonsManager.getInstance().getCurrentSeason(worldType);
         for(var i:int = 0; i <= seasons; i++)
         {
            sidecardTag = "sidecard" + i;
            if(main_mc[sidecardTag])
            {
               if(i == currentSeason)
               {
                  main_mc[sidecardTag].visible = true;
               }
               else
               {
                  main_mc[sidecardTag].visible = false;
               }
            }
         }
      }
      
      override protected function customizeDialog(main_mc:MovieClip) : void
      {
         var overlayTag:String = null;
         var sideCardTag:String = null;
         if(WorldSeasonsManager.getInstance().hasSeasons(Global.worldManager.currentWorldType))
         {
            overlayTag = getOverlayTag();
            sideCardTag = getSideCardTag();
            if(!this.m_isAtMaxExpansionLevel)
            {
               if(this.m_storage.isNextStageRegionLocked())
               {
                  this.displaySideCard(main_mc);
                  this.displayOverlayDialog(main_mc);
               }
               else
               {
                  this.hideSideCard(main_mc);
                  this.hideOverlayDialog(main_mc);
               }
            }
            else
            {
               this.hideSideCard(main_mc);
               this.hideOverlayDialog(main_mc);
            }
         }
      }
      
      override protected function customizeTile(tile:MovieClip) : void
      {
         if(this.m_isAtMaxExpansionLevel || this.m_building.isNextStageRegionLocked())
         {
            ZLocUtils.setText(tile,"completeIcon_mc.completed_tf","Dialogs","GenericExpansion_completed_text");
            setVisibility(tile,"completeIcon_mc",true);
            setVisibility(tile,"completeNow_bt",false);
            setVisibility(tile,"getThis_bt",false);
            setVisibility(tile,"buy_bt",false);
            setVisibility(tile,"sendMaterials_tf",false);
            setVisibility(tile,"present_bt",false);
            setVisibility(tile,"fcPrice_mc",false);
            setVisibility(tile,"alive_tf",false);
            if(tile.askForMoreButton)
            {
               tile.askForMoreButton.turnOff();
            }
            if(tile.buyButton)
            {
               tile.buyButton.turnOff();
            }
            if(tile.useMatButton)
            {
               tile.useMatButton.turnOff();
            }
            setVisibility(tile,"use_mat_bt",false);
            setVisibility(tile,"available_tf",false);
         }
         if(!this.m_isAtMaxExpansionLevel && tile.name == "giftPanel4" && this.m_building.isNextStageRegionLocked())
         {
            setVisibility(tile,"fcPrice_mc",false);
            setVisibility(tile,"completeNow_bt",false);
            setVisibility(tile,"present_bt",true);
            setVisibility(tile,"sendMaterials_tf",true);
            setVisibility(tile,"completeIcon_mc",false);
            if(tile.completeNowBtn)
            {
               tile.completeNowBtn.turnOff();
            }
         }
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         if(this.shouldStartAnimation)
         {
            this.m_cart.play();
         }
         else
         {
            this.setNextLootItem();
         }
      }
      
      public function initPotentialLoot() : void
      {
         var curWorldName:String = Global.worldManager.currentWorldType;
         if(s_potentialLoot != null && s_potentialLoot[curWorldName] == null)
         {
            s_potentialLoot = null;
            s_lootItemIcons = new Dictionary();
         }
         if(s_potentialLoot == null)
         {
            TransactionManager.addTransaction(new TFetchLoot(this.getLootKey(),this.onFetchLootComplete),true);
         }
         else
         {
            this.randomizePotentialLoot();
         }
      }
      
      private function savePotentialLootArray(lootItems:Array) : void
      {
         var curWorldName:String = Global.worldManager.currentWorldType;
         var curBuildingName:String = m_building.getItemName();
         if(s_potentialLoot == null)
         {
            s_potentialLoot = new Array();
         }
         if(s_potentialLoot[curWorldName] == null)
         {
            s_potentialLoot[curWorldName] = new Array();
         }
         s_potentialLoot[curWorldName][curBuildingName] = lootItems;
      }
      
      private function getPotentialLootArray() : Array
      {
         var result:Array = null;
         var curWorldName:String = Global.worldManager.currentWorldType;
         var curBuildingName:String = m_building.getItemName();
         if(Boolean(s_potentialLoot) && Boolean(s_potentialLoot[curWorldName]) && Boolean(s_potentialLoot[curWorldName][curBuildingName]))
         {
            result = s_potentialLoot[curWorldName][curBuildingName];
         }
         return result;
      }
      
      private function onFetchLootComplete(lootItems:Array) : void
      {
         var lootItem:LootItem = null;
         this.savePotentialLootArray(lootItems);
         var potentialLoot:Array = this.getPotentialLootArray();
         this.randomizePotentialLoot();
         this.setNextLootItem();
         for(var lootIdx:int = 1; lootIdx < potentialLoot.length; lootIdx++)
         {
            lootItem = potentialLoot[lootIdx] as LootItem;
            if(lootItem.item)
            {
               LoadingManager.load(lootItem.item.getImageByName(ICON_IMAGE_NAME),ZCacheUtil.applyPartial(this.onIconLoaded,this,[lootItem,false]),LoadingManager.PRIORITY_LOW);
            }
         }
      }
      
      private function randomizePotentialLoot() : void
      {
         var potentialLoot:Array = this.getPotentialLootArray();
         if(potentialLoot != null)
         {
            ArrayUtil.randomize(potentialLoot);
            this.m_lastLootIndex = 0;
         }
      }
      
      private function onCartLoopComplete(ev:MovieClipEvent) : void
      {
         this.m_cartTimer.start();
         this.setNextLootItem();
      }
      
      private function onCartTimerComplete(ev:TimerEvent) : void
      {
         this.m_cartTimer.reset();
         if(this.shouldStartAnimation)
         {
            this.m_cart.play();
         }
      }
      
      private function get shouldStartAnimation() : Boolean
      {
         return m_shown && this.m_lootItem && this.m_cart && this.m_iconLoader == null && !this.m_cartTimer.running;
      }
      
      private function setNextLootItem() : void
      {
         var potentialLoot:Array = null;
         var prizeCart:MovieClip = null;
         var rarityIndex:int = 0;
         var cartIdx:int = 0;
         var level:int = 0;
         var icon:DisplayObject = null;
         if(m_loaded)
         {
            potentialLoot = this.getPotentialLootArray();
            if(potentialLoot != null && potentialLoot.length > 0)
            {
               if(this.m_lastLootIndex >= potentialLoot.length)
               {
                  this.m_lastLootIndex = 0;
               }
               this.m_lootItem = potentialLoot[this.m_lastLootIndex++] as LootItem;
            }
            else
            {
               this.m_lootItem = null;
            }
            prizeCart = m_window.main_mc.prizeCart_mc as MovieClip;
            if(this.m_lootItem == null)
            {
               setVisibility(prizeCart,"cart_mc",false);
            }
            else
            {
               setVisibility(prizeCart,"cart_mc",true);
               rarityIndex = this.m_lootItem.rarityIndex;
               for(cartIdx = 0; cartIdx <= LootItem.MAX_RARITY_INDEX; cartIdx++)
               {
                  setVisibility(prizeCart.cart_mc.cartBG_mc,"cartRare_" + cartIdx + "_mc",cartIdx == rarityIndex);
               }
               prizeCart.cart_mc.qty_mc.qty_tf.text = ZLocUtils.t("Dialogs",m_building.getItemName() + "_withdrawal_reward_quantity",{"quantity":this.m_lootItem.quantity});
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(prizeCart.cart_mc.qty_mc.qty_tf);
               }
               setVisibility(prizeCart.cart_mc,"qty_mc",this.m_lootItem.quantity > 1);
               if(Boolean(this.m_lootItem) && Boolean(this.m_lootItem.item))
               {
                  prizeCart.rarityInfo_mc.rarity_tf.text = this.m_lootItem.item.friendlyTitle;
                  if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
                  {
                     TemplateUIUtility.applyExpansionSubTextColor(prizeCart.rarityInfo_mc.rarity_tf);
                  }
               }
               level = parseInt(this.m_lootItem.getValueForKey("level") as String) - 1;
               if(level <= m_storage.storageLevel)
               {
                  setVisibility(prizeCart.rarityInfo_mc,"level_tf",false);
               }
               else
               {
                  setVisibility(prizeCart.rarityInfo_mc,"level_tf",true);
                  prizeCart.rarityInfo_mc.level_tf.text = ZLocUtils.t("Dialogs",m_building.getItemName() + "_withdrawal_reward_level",{"levelNum":level});
                  if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
                  {
                     TemplateUIUtility.applyExpansionSubTextColor(prizeCart.rarityInfo_mc.level_tf);
                  }
               }
               while(prizeCart.cart_mc.icon_mc.numChildren > 0)
               {
                  prizeCart.cart_mc.icon_mc.removeChildAt(prizeCart.cart_mc.icon_mc.numChildren - 1);
               }
               icon = s_lootItemIcons[this.m_lootItem];
               if(icon)
               {
                  this.setIcon(icon);
               }
               else if(Boolean(this.m_lootItem) && Boolean(this.m_lootItem.item))
               {
                  this.m_iconLoader = LoadingManager.load(this.m_lootItem.item.getImageByName(ICON_IMAGE_NAME),ZCacheUtil.applyPartial(this.onIconLoaded,this,[this.m_lootItem,true]));
               }
            }
         }
      }
      
      private function onIconLoaded(lootItem:LootItem, display:Boolean, ev:Event) : void
      {
         var icon:DisplayObject = null;
         var loaderInfo:LoaderInfo = ev.currentTarget as LoaderInfo;
         if(loaderInfo)
         {
            if(loaderInfo.loader === this.m_iconLoader)
            {
               this.m_iconLoader = null;
            }
            if(loaderInfo.content)
            {
               icon = loaderInfo.content;
               s_lootItemIcons[lootItem] = icon;
               if(display)
               {
                  this.setIcon(icon);
               }
            }
         }
      }
      
      private function setIcon(icon:DisplayObject) : void
      {
         if(m_loaded)
         {
            m_window.main_mc.prizeCart_mc.cart_mc.icon_mc.addChild(icon);
            if(this.shouldStartAnimation)
            {
               this.m_cart.play();
            }
         }
      }
      
      override protected function onHide() : void
      {
         if(this.m_cartTimer)
         {
            if(this.m_cartTimer.running)
            {
               this.m_cartTimer.stop();
               this.m_cartTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onCartTimerComplete);
            }
            this.m_cartTimer = null;
         }
         if(this.m_cart)
         {
            this.m_cart.stop();
            this.m_cart.removeEventListener(MovieClipEvent.LOOP_COMPLETE,this.onCartLoopComplete);
            this.m_cart.destroy();
            this.m_cart = null;
         }
         super.onHide();
      }
      
      override protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         TutorialUI.displayBuildingTutorialWindow(this.m_building as FeatureBuilding,this.getWhatIsThisImagePrefix());
      }
      
      override protected function getExpandFeedImage() : String
      {
         var level:String = String(m_building.storageLevel);
         return Global.getAssetURL("assets/buildings/building_" + m_building.getItem().name + "_" + level + "_icon.png");
      }
   }
}


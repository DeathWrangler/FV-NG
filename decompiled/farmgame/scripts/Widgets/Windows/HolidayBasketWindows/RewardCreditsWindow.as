package Widgets.Windows.HolidayBasketWindows
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.MFSConstants;
   import Classes.CreditCostInfo;
   import Classes.RewardCreditsBuilding;
   import Classes.ZItem.DeprecatorSettings;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.Dialog;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.HUD.HUDSkinConfig;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import GameMode.GMCreditsBuildingItemPlace;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.LicenseManager;
   import Managers.MFSRequestManager;
   import Managers.OffboardingManager;
   import Transactions.TAcquireLicense;
   import Transactions.TRedeemCreditsItem;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.CreditsBuilding.LeaderBoardFrame;
   import Widgets.Frames.CreditsBuilding.ProgressSlot;
   import Widgets.Frames.CreditsBuilding.ProgressSlotFrame;
   import Widgets.Frames.CreditsBuilding.RewardCreditsMeterFrame;
   import Widgets.Frames.CreditsBuilding.StatesFlyoutSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class RewardCreditsWindow extends FarmWindow
   {
      
      protected static const LOC_BUNDLE:String = "Dialogs";
      
      protected static const CENTER_ICON_VERTICAL_DISPLACE:Number = -50;
      
      protected static const DEFAULT_LOCATION_ICON_PATH:String = "assets/hud/LocationIcons/icon_home_travelMenu.png";
      
      protected static const EXPENSIVE_PACKAGE_THRESHOLD:int = 1;
      
      protected static const ALLOW_REDEEM_ITEM_ON_LOAD:Boolean = false;
      
      protected const NUM_PROGRESS_SLOTS:int = 6;
      
      protected const NUM_COMPARISON_SLOTS:int = 4;
      
      protected const EXTRA_TIER_ICON_SIZE:int = 100;
      
      protected var m_toggleManager:ZwToggleManager = null;
      
      protected var m_building:RewardCreditsBuilding;
      
      protected var m_buildingClassName:String;
      
      protected var m_showWhatIsThisOnLoad:Boolean;
      
      protected var m_showRedeemableItemOnLoad:Object;
      
      protected var m_progressSlotFrameArray:Array = [];
      
      protected var m_creditsToBuy:FarmItem = null;
      
      protected var m_itemToBuy:Object = null;
      
      protected var m_itemToBuyCostInfo:CreditCostInfo;
      
      protected var m_howDoesThisWorkPopup:Dialog = null;
      
      public var SEND_CREDITS_URL:String;
      
      public var m_extraTierPopup:ZwFrame;
      
      public var m_extraTierFrame:ZwFrame;
      
      protected var m_walletSize:int = Global.player.cash;
      
      protected var m_ticketWalletText:ZwTextField = null;
      
      protected var m_treatPackSize:int = 5;
      
      protected var m_treatPackSizeExpensive:int = 1;
      
      protected var m_leaderboardFrame:LeaderBoardFrame = null;
      
      protected var m_meterImage:ZwWidget = null;
      
      protected var m_currentMeterState:Number = 0;
      
      protected var m_buyCheckMark:MovieClip = null;
      
      protected var m_buyButton:FarmAnimatedTextButton;
      
      protected var m_askForButton:FarmAnimatedTextButton;
      
      protected var m_ticketReceivedText:ZwTextField = null;
      
      protected var m_stateMc:MovieClip = null;
      
      protected var m_creditTypes:Array = new Array();
      
      protected var m_askForCreditsPanelButtons:Array = new Array();
      
      public var m_disableFeedPosts:Boolean = false;
      
      public function RewardCreditsWindow(building:RewardCreditsBuilding, buildingClassName:String, dialogAssetUrl:String, showWhatIsThisOnLoad:Boolean = false, showRedeemableItemOnLoad:Object = null, useMultiFriendSelector:Boolean = false)
      {
         this.m_building = building;
         this.m_buildingClassName = buildingClassName;
         this.m_showWhatIsThisOnLoad = showWhatIsThisOnLoad;
         this.m_showRedeemableItemOnLoad = showRedeemableItemOnLoad;
         this.m_creditTypes = this.m_building.getCreditTypes();
         if(!ALLOW_REDEEM_ITEM_ON_LOAD)
         {
            this.m_showRedeemableItemOnLoad = false;
         }
         super(dialogAssetUrl);
         this.SEND_CREDITS_URL = "gifts.php?ref=" + buildingClassName + "_UI";
      }
      
      public static function getMcNumFromIndex(index:int) : String
      {
         var result:String = null;
         if(index <= 0)
         {
            result = "";
         }
         else
         {
            result = (index + 1).toString();
         }
         return result;
      }
      
      override protected function release() : void
      {
         if(this.m_toggleManager)
         {
            this.m_toggleManager.release();
            this.m_toggleManager = null;
         }
         if(this.m_progressSlotFrameArray)
         {
            this.m_progressSlotFrameArray = null;
         }
         if(this.m_leaderboardFrame)
         {
            this.m_leaderboardFrame = null;
         }
         if(this.m_meterImage)
         {
            this.m_meterImage = null;
         }
         if(this.m_buyButton)
         {
            this.m_buyButton = null;
         }
         if(this.m_askForButton)
         {
            this.m_askForButton = null;
         }
         if(this.m_askForCreditsPanelButtons)
         {
            this.m_askForCreditsPanelButtons = null;
         }
         super.release();
      }
      
      override protected function postLoadComplete() : void
      {
         var statesData:Array = null;
         var progressFrame:ZwFrame = null;
         var index:int = 0;
         var ticketType:String = null;
         var progressBtn:FarmAnimatedTextButton = null;
         var comparisonBtn:FarmAnimatedTextButton = null;
         this.triggerOpenStat();
         var titlePK:String = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"Title");
         if(m_window.title_tf)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.tk_pk_asTitle(titlePK)));
         }
         if(m_window.meter_mc)
         {
            addWidget(new RewardCreditsMeterFrame(m_window.meter_mc,this.m_building,this.m_buildingClassName));
         }
         else if(m_window.meter0_mc)
         {
            addWidget(new RewardCreditsMeterFrame(m_window.meter0_mc,this.m_building,this.m_buildingClassName));
            if(Global.player.getSeenFlag(this.m_buildingClassName + "_BrokeMeter"))
            {
               m_window.meter0_mc.prize_mc.visible = true;
               m_window.meter0_mc.prizeComplete_mc.visible = true;
            }
            else
            {
               m_window.meter0_mc.prize_mc.visible = true;
               m_window.meter0_mc.prizeComplete_mc.visible = false;
            }
         }
         else if(m_window.levels_mc)
         {
            statesData = Global.farmGameSettingsManager.getBuildingLevelItems(this.m_building.getCreditsFeatureName());
            addWidget(new StatesFlyoutSlotFrame(m_window.levels_mc,statesData,this.m_building,this.m_buildingClassName));
         }
         if(m_window.progress_mc)
         {
            progressFrame = new ZwFrame(m_window.progress_mc);
            this.buildProgressFrame(progressFrame);
         }
         for(var levelIndex:int = 0; m_window.hasOwnProperty("buildable" + levelIndex + "_mc"); levelIndex++)
         {
            m_window["buildable" + levelIndex + "_mc"].visible = false;
         }
         var level:int = this.m_building.getCurrentSuffix();
         if(m_window.hasOwnProperty("buildable" + level + "_mc"))
         {
            this.m_stateMc = m_window["buildable" + level + "_mc"];
            this.m_stateMc.visible = true;
         }
         var totalReceivedCredits:Object = this.m_building.getMultiTypeCredits(true);
         var currentCredits:Object = this.m_building.getMultiTypeCredits(false);
         if(this.m_creditTypes.length < 2)
         {
            if(m_window.availableWallet_tf)
            {
               this.m_ticketWalletText = addWidget(new ZwTextField(m_window.availableWallet_tf,currentCredits[this.m_buildingClassName + "_ticket"].toString())) as ZwTextField;
            }
         }
         else
         {
            index = 0;
            for(index = 0; index < this.m_creditTypes.length; index++)
            {
               ticketType = this.m_creditTypes[index];
               if(m_window["availableWallet" + getMcNumFromIndex(index) + "_tf"])
               {
                  this.m_ticketWalletText = addWidget(new ZwTextField(m_window["availableWallet" + getMcNumFromIndex(index) + "_tf"],currentCredits[ticketType].toString())) as ZwTextField;
               }
               if(m_window["receivedAmount" + getMcNumFromIndex(index) + "_tf"])
               {
                  this.m_ticketReceivedText = addWidget(new ZwTextField(m_window["receivedAmount" + getMcNumFromIndex(index) + "_tf"],totalReceivedCredits[ticketType].toString())) as ZwTextField;
               }
               if(Boolean(m_window["panel" + index.toString() + "_mc"]) && Boolean(m_window["panel" + index.toString() + "_mc"]["availableWallet" + index.toString() + "_tf"]))
               {
                  this.m_ticketWalletText = addWidget(new ZwTextField(m_window["panel" + index.toString() + "_mc"]["availableWallet" + index.toString() + "_tf"],currentCredits[ticketType].toString())) as ZwTextField;
               }
               if(Boolean(m_window["panel" + index.toString() + "_mc"]) && Boolean(m_window["panel" + index.toString() + "_mc"]["receivedAmount" + index.toString() + "_tf"]))
               {
                  this.m_ticketReceivedText = addWidget(new ZwTextField(m_window["panel" + index.toString() + "_mc"]["availableWallet" + index.toString() + "_tf"],totalReceivedCredits[ticketType].toString())) as ZwTextField;
               }
            }
         }
         if(m_window.leaderBoard_mc)
         {
            this.m_leaderboardFrame = addWidget(new LeaderBoardFrame(m_window.leaderBoard_mc,this.m_building,this.m_buildingClassName),false) as LeaderBoardFrame;
         }
         var strPK:String = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"Progress");
         var str:String = "" != strPK ? ZLocUtils.t_pk(strPK) : ZLocUtils.t("Dialogs","RewardCredits_Progress");
         if(Boolean(m_window.progress_bt) && Boolean(m_window.comparison_bt))
         {
            progressBtn = addWidget(new FarmAnimatedTextButton(m_window.progress_bt,str,this.progressButtonStatsTrack,true)) as FarmAnimatedTextButton;
            strPK = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"Comparison");
            str = "" != strPK ? ZLocUtils.t_pk(strPK) : ZLocUtils.t("Dialogs","RewardCredits_Comparison");
            comparisonBtn = addWidget(new FarmAnimatedTextButton(m_window.comparison_bt,str,this.comparisonButtonStatsTrack,true)) as FarmAnimatedTextButton;
            this.m_toggleManager = new ZwToggleManager();
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(progressBtn,progressFrame),true);
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(comparisonBtn,this.m_leaderboardFrame));
         }
         this.buildBuyAskForButtons();
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t(LOC_BUNDLE,"WhatIsThis"),this.displayWhatIsThis,true));
         if(m_window.hasOwnProperty("meter_mc"))
         {
            if(m_window.meter_mc.basket_mc)
            {
               this.m_meterImage = new ZwWidget(m_window.meter_mc.basket_mc);
               addWidget(this.m_meterImage);
               this.updateMeterImage();
            }
            if(m_window.meter_mc.worldIcon_mc)
            {
               addWidget(new FarmIcon(m_window.meter_mc.worldIcon_mc,this.getWorldIconPath()),true);
            }
         }
         if(m_window.treat_mc)
         {
            (m_window.treat_mc as MovieClip).visible = true;
         }
         if(m_window.treat2_mc)
         {
            (m_window.treat2_mc as MovieClip).visible = true;
            if(m_window.treat2_mc.treat2rollover_mc)
            {
               this.setRolloverText(m_window.treat2_mc.treat2rollover_mc);
               m_window.treat2_mc.treat2rollover_mc.visible = false;
               (m_window.treat2_mc as MovieClip).addEventListener(MouseEvent.ROLL_OVER,this.rolloverCallback);
               (m_window.treat2_mc as MovieClip).addEventListener(MouseEvent.ROLL_OUT,this.rolloutCallback);
            }
         }
         if(Boolean(m_window.treat2top_mc) && Boolean(m_window.treat2top_mc.treat2_mc))
         {
            (m_window.treat2top_mc as MovieClip).visible = true;
            if(m_window.treat2top_mc.treat2_mc.treat2rollover_mc)
            {
               this.setRolloverText(m_window.treat2top_mc.treat2_mc.treat2rollover_mc);
               m_window.treat2top_mc.treat2_mc.treat2rollover_mc.visible = false;
               (m_window.treat2top_mc.treat2_mc as MovieClip).addEventListener(MouseEvent.ROLL_OVER,this.rolloverCallback);
               (m_window.treat2top_mc.treat2_mc as MovieClip).addEventListener(MouseEvent.ROLL_OUT,this.rolloutCallback);
            }
         }
         if(this.m_showRedeemableItemOnLoad)
         {
            this.redeemItemCallback(this.m_showRedeemableItemOnLoad);
         }
         else if(!Global.player.getSeenFlag(this.m_buildingClassName + "StorageDialog") && this.m_showWhatIsThisOnLoad)
         {
            Global.player.setSeenFlag(this.m_buildingClassName + "StorageDialog");
            this.displayWhatIsThis();
         }
         if(this.m_building.hasMeterBreak())
         {
            this.loadExtraTier();
         }
         if(m_window.buyCheckMark_mc)
         {
            this.m_buyCheckMark = m_window.buyCheckMark_mc as MovieClip;
         }
         if(m_window["panel0_mc"])
         {
            this.setupTicketSlots(totalReceivedCredits,currentCredits);
            this.buildMultiBuyButtons(true);
            this.buildMultiAskButtons();
         }
         var deprecator:DeprecatorSettings = Global.farmGameSettingsManager.getDeprecatorSettings(this.m_buildingClassName);
         if(Boolean(Global.player.isDataLoaded) && Boolean(deprecator) && deprecator.checkPrereqs())
         {
            if(ObjectUtil.pathExists(m_window,["tradeIn_mc","tradein_bt"]))
            {
               m_window.tradeIn_mc.visible = true;
               addWidget(new FarmAnimatedTextButton(m_window.tradeIn_mc.tradein_bt,ZLocUtils.tk_pk(RewardCreditsBuilding.getLocalizedKey(this.m_building.getClassName(),"Offboard")).getString(),this.popReplacementConfirmationDialog));
            }
            if(!Global.player.getSeenFlag(this.m_buildingClassName + "ReplacementDialogSeen"))
            {
               FarmStatsManager.count(this.m_buildingClassName,"offboarding","initial_option","view");
               this.popReplacementConfirmationDialog();
            }
         }
         this.setupTimer();
      }
      
      public function popReplacementConfirmationDialog(result:Object = null) : void
      {
         var popup:GenericPopup = new GenericPopup(ZLocUtils.t(this.m_building.getClassName(),"OffboardDescription",{"basketName":ZLocUtils.tk_pk_asTitle(this.m_building.getItemFriendlyName())}),GenericPopup.TYPE_ACCEPTCANCEL,this.offboardBuilding);
         popup.setAcceptTextName("BasketOffboardAccept");
         popup.setCancelTextName("BasketOffboardPostpone");
         UI.displayPopup(popup,false);
         if(Global.player.getSeenFlag(this.m_buildingClassName + "ReplacementDialogSeen"))
         {
            FarmStatsManager.count(this.m_buildingClassName,"offboarding","option","view");
         }
      }
      
      override public function refreshWindow() : void
      {
         var slotFrame:ProgressSlotFrame = null;
         var totalReceivedCredits:Object = this.m_building.getMultiTypeCredits(true);
         var currentCredits:Object = this.m_building.getMultiTypeCredits(false);
         this.setupTicketSlots(totalReceivedCredits,currentCredits);
         this.refreshCreditsMeterAndText();
         this.checkAskButtonGrayOutStatus(this.m_askForButton);
         for each(slotFrame in this.m_progressSlotFrameArray)
         {
            slotFrame.refresh();
         }
      }
      
      protected function refreshWindowWrapper(result:Object) : void
      {
         if(m_window != null)
         {
            this.refreshWindow();
         }
      }
      
      protected function offboardBuilding(event:GenericPopupEvent) : void
      {
         var option:String = "option";
         if(!Global.player.getSeenFlag(this.m_buildingClassName + "ReplacementDialogSeen"))
         {
            option = "initial_option";
         }
         if(Boolean(event) && event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count(this.m_buildingClassName,"offboarding",option,"make_storable");
            this.m_building.alreadyOffboarded = OffboardingManager.handleOffBoarding(this.m_building,this.m_building.alreadyOffboarded,true);
            this.close();
         }
         else
         {
            FarmStatsManager.count(this.m_buildingClassName,"offboarding",option,"keep_basket");
         }
         Global.player.setSeenFlag(this.m_buildingClassName + "ReplacementDialogSeen");
      }
      
      protected function setupTicketSlots(totalReceivedCredits:Object, currentCredits:Object) : void
      {
         var ticketXML:XML = null;
         var licensedTicketName:String = null;
         var unlockDate:Number = NaN;
         var licenseCode:String = null;
         var lockedSlot:MovieClip = null;
         var m_element:MovieClip = null;
         var typeOfTicket:String = null;
         var tokenGroup:DisplayObject = null;
         var tokenFrame:ZwFrame = null;
         var buildingXML:XML = this.getBuildingCreditsXml();
         for(var ticketSlot:uint = 0; ticketSlot < this.m_creditTypes.length; ticketSlot++)
         {
            ticketXML = buildingXML["creditType"][ticketSlot] as XML;
            licensedTicketName = ticketXML.attribute("name").toString() + "_5pack";
            unlockDate = FarmGameUtil.synchronizedDateToNumber(ticketXML.attribute("date").toString());
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               licenseCode = Global.farmGameSettingsManager.getFarmItemByName(licensedTicketName).code;
            }
            else
            {
               licenseCode = Global.farmGameSettingsManager.getItemXMLByName(licensedTicketName).@code;
            }
            if(unlockDate > GlobalEngine.serverTime && !LicenseManager.getInstance().hasCurrentLicense(licenseCode))
            {
               lockedSlot = m_window["locked" + ticketSlot.toString() + "_mc"];
               if(getWidget(lockedSlot.buy_bt) != null)
               {
                  removeWidget(lockedSlot.buy_bt);
               }
               addWidget(new FarmAnimatedTextButton(lockedSlot.buy_bt,ZLocUtils.tk_pk(RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"Unlock")).getString(),ZCacheUtil.applyPartial(this.unlockTicket,this,[licensedTicketName,parseInt(ticketXML.attribute("cost").toString()),ticketXML.attribute("license").toString(),lockedSlot.buy_bt])),true);
               lockedSlot.buy_bt.cost_tf.text = ticketXML.attribute("cost").toString();
               lockedSlot.visible = true;
               lockedSlot.unlockDate_tf.text = ZLocUtils.tk_pk(RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"unlockDate" + ticketSlot.toString())).getString();
               if(m_window.hasOwnProperty("hidden" + ticketSlot.toString() + "_mc"))
               {
                  m_window["hidden" + ticketSlot.toString() + "_mc"].visible = false;
               }
               ticketSlot++;
               while(m_window.hasOwnProperty("hidden" + ticketSlot.toString() + "_mc"))
               {
                  m_window["hidden" + ticketSlot.toString() + "_mc"].visible = true;
                  ticketSlot++;
               }
               break;
            }
            if(m_window.hasOwnProperty("panel" + ticketSlot.toString() + "_mc"))
            {
               m_element = m_window["panel" + ticketSlot.toString() + "_mc"];
               m_element.visible = true;
               if(m_window["locked" + ticketSlot.toString() + "_mc"])
               {
                  m_window["locked" + ticketSlot.toString() + "_mc"].visible = false;
               }
               typeOfTicket = this.m_creditTypes[ticketSlot];
               if(m_element["availableWallet_tf"])
               {
                  m_element["availableWallet_tf"].text = currentCredits[typeOfTicket].toString();
               }
               if(m_element["receivedAmount_tf"])
               {
                  m_element["receivedAmount_tf"].text = totalReceivedCredits[typeOfTicket].toString();
               }
               tokenGroup = m_element["tokenGroup" + ticketSlot.toString() + "_mc"];
               if(Boolean(tokenGroup) && getWidget(tokenGroup) == null)
               {
                  tokenFrame = new ZwFrame(tokenGroup);
                  addWidget(tokenFrame);
                  this.buildProgressFrame(tokenFrame,ticketSlot);
               }
               else if(this.m_progressSlotFrameArray != null && this.m_progressSlotFrameArray.length > ticketSlot)
               {
                  (this.m_progressSlotFrameArray[ticketSlot] as ProgressSlotFrame).refresh();
               }
            }
         }
      }
      
      protected function unlockTicket(name:String, cost:int, licenseCode:String, element:MovieClip, event:MouseEvent) : void
      {
         var unlockButton:FarmAnimatedTextButton = null;
         if(Global.player.canBuyCash(cost))
         {
            if(!LicenseManager.getInstance().hasCurrentLicense(licenseCode))
            {
               TransactionManager.addTransaction(new TAcquireLicense(null,licenseCode,this.refreshWindowWrapper,name));
               unlockButton = getWidget(element) as FarmAnimatedTextButton;
               unlockButton.enabled = false;
               unlockButton.applyGrayOut = true;
               Global.player.cash -= cost;
               FarmStatsManager.count(this.m_buildingClassName,"unlock",name,cost.toString());
            }
         }
      }
      
      protected function triggerOpenStat() : void
      {
         FarmStatsManager.count(this.m_buildingClassName,"open_basket");
      }
      
      private function setRolloverText(element:DisplayObject) : void
      {
         var obj:Object = element as Object;
         if(obj.treat2rollover_tf)
         {
            obj.treat2rollover_tf.text = ZLocUtils.t("Dialogs",this.m_building.getCreditsFeatureName() + "_rollover_text");
         }
      }
      
      protected function rolloverCallback(event:MouseEvent) : void
      {
         var item:Object = event.currentTarget;
         var mc:MovieClip = item as MovieClip;
         mc.treat2rollover_mc.visible = true;
      }
      
      protected function rolloutCallback(event:MouseEvent) : void
      {
         var item:Object = event.currentTarget;
         var mc:MovieClip = item as MovieClip;
         mc.treat2rollover_mc.visible = false;
      }
      
      protected function meterFilledRewardCallback(itemName:String) : void
      {
         var gift:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         UI.displayPopup(new GenericIconPopup(ZLocUtils.t(this.m_buildingClassName,"meterFilledPrizeText",{"item":ZLocUtils.tk_pk_asTitle(gift.friendlyName)}),GenericPopup.TYPE_OK,null,gift.icon),false);
         Global.player.addGift(itemName,"0",1);
      }
      
      protected function awardBrokenMeterGift(redeemItemExtraTier:Array) : void
      {
         var item:Object = null;
         var nothing:Object = null;
         var transaction:TRedeemCreditsItem = null;
         for each(item in redeemItemExtraTier)
         {
            nothing = null;
            if(Boolean(item.costOrdered && item.costOrdered[0] && item.costOrdered[0].meterFilledReward) && Boolean(!isNaN(item.costOrdered[0].meterFilledReward)) && item.costOrdered[0].meterFilledReward <= this.m_building.getTotalCreditsReceived())
            {
               if(!Global.player.getSeenFlag(this.m_buildingClassName + "_BrokenMeterGift_" + item.name))
               {
                  transaction = new TRedeemCreditsItem(this.m_building,item.name,0,false,ZCacheUtil.applyPartial(this.meterFilledRewardCallback,this,[item.name]));
                  transaction.setCenterIconVerticalDisplace(CENTER_ICON_VERTICAL_DISPLACE);
                  TransactionManager.addTransaction(transaction,true);
                  Global.player.setSeenFlag(this.m_buildingClassName + "_BrokenMeterGift_" + item.name,true);
                  this.refreshWindow();
               }
            }
         }
      }
      
      protected function loadExtraTier() : void
      {
         var ps:ProgressSlot = null;
         var str:String = null;
         var strPK:String = null;
         var itemPK:String = null;
         var hasBrokenTheMeterBefore:Boolean = Global.player.getSeenFlag(this.m_buildingClassName + "_BrokeMeter");
         var redeemItemExtraTier:Array = null;
         if(this.m_building.hasMeterBreak() && (this.m_building.getTotalCreditsReceived() >= this.getMeterMaxCredits() || hasBrokenTheMeterBefore))
         {
            redeemItemExtraTier = this.constructNewProgressData(this.NUM_PROGRESS_SLOTS,this.NUM_PROGRESS_SLOTS + 1);
            this.awardBrokenMeterGift(redeemItemExtraTier);
            if(this.m_extraTierPopup != null && this.m_extraTierFrame != null)
            {
               (this.m_extraTierPopup.getWidget(this.m_extraTierPopup.element.generic_0_tf) as ZwTextField).text = ZLocUtils.t("RewardCreditsBuilding","ExtraTier_0");
               str = "";
               strPK = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"ExtraTier_1");
               itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_buildingClassName);
               if("" != strPK)
               {
                  if("" != itemPK && ZLocUtils.isObject(itemPK))
                  {
                     str = ZLocUtils.t_pk(strPK,null,{"item":ZLocUtils.tk_pk(itemPK)});
                  }
                  else
                  {
                     str = ZLocUtils.t_pk(strPK);
                  }
               }
               (this.m_extraTierPopup.getWidget(this.m_extraTierPopup.element.generic_1_tf) as ZwTextField).text = str;
               (this.m_extraTierPopup.getWidget(this.m_extraTierPopup.element.generic_2_tf) as ZwTextField).text = ZLocUtils.t("RewardCreditsBuilding","ExtraTier_2");
               if(redeemItemExtraTier.length > 0)
               {
                  ps = this.m_extraTierFrame.getWidget(this.m_extraTierFrame.element.slot_0_mc) as ProgressSlot;
                  ps.resizeIcon(this.EXTRA_TIER_ICON_SIZE);
                  ps.populate(redeemItemExtraTier[redeemItemExtraTier.length - 1]);
               }
            }
            else if(Boolean(m_window.messageLarge_mc) && Boolean(m_window.progressFrame2_mc))
            {
               addWidget(this.m_extraTierPopup = new ZwFrame(m_window.messageLarge_mc));
               this.m_extraTierPopup.addWidget(new FarmButton(this.m_extraTierPopup.element.close_bt,this.onCloseExtraTier));
               this.m_extraTierPopup.addWidget(new ZwFrame(this.m_extraTierPopup.element.fadeCurtain_mc));
               this.m_extraTierPopup.addWidget(new ZwTextField(this.m_extraTierPopup.element.generic_0_tf,ZLocUtils.t("RewardCreditsBuilding","ExtraTier_0")));
               str = "";
               strPK = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"ExtraTier_1");
               itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_buildingClassName);
               if("" != strPK)
               {
                  if("" != itemPK && ZLocUtils.isObject(itemPK))
                  {
                     str = ZLocUtils.t_pk(strPK,null,{"item":ZLocUtils.tk_pk(itemPK)});
                  }
                  else
                  {
                     str = ZLocUtils.t_pk(strPK);
                  }
               }
               this.m_extraTierPopup.addWidget(new ZwTextField(this.m_extraTierPopup.element.generic_1_tf,str));
               this.m_extraTierPopup.addWidget(new ZwTextField(this.m_extraTierPopup.element.generic_2_tf,ZLocUtils.t("RewardCreditsBuilding","ExtraTier_2")));
               addWidget(this.m_extraTierFrame = new ZwFrame(m_window.progressFrame2_mc));
               if(redeemItemExtraTier.length > 0)
               {
                  this.m_extraTierFrame.addWidget(ps = new ProgressSlot(m_window.progressFrame2_mc.slot_0_mc,this.redeemItemCallback,this.m_buildingClassName));
                  ps.resizeIcon(this.EXTRA_TIER_ICON_SIZE);
                  ps.populate(redeemItemExtraTier[redeemItemExtraTier.length - 1]);
               }
            }
            if(hasBrokenTheMeterBefore)
            {
               this.onCloseExtraTier();
            }
            Global.player.setSeenFlag(this.m_buildingClassName + "_BrokeMeter");
         }
      }
      
      override public function show() : void
      {
         super.show();
         this.updateMeterImage();
      }
      
      protected function updateMeterImage() : Boolean
      {
         var stateChangeLevel:Number = NaN;
         var mcMeterImage:MovieClip = null;
         var toReturn:Boolean = false;
         if(this.m_meterImage != null)
         {
            stateChangeLevel = this.m_building.getLevelStateChange();
            mcMeterImage = this.m_meterImage.element as MovieClip;
            if(Boolean(mcMeterImage) && stateChangeLevel + 1 > this.m_currentMeterState)
            {
               this.m_currentMeterState = stateChangeLevel + 1;
               mcMeterImage.gotoAndStop(this.m_currentMeterState);
               toReturn = true;
            }
         }
         return toReturn;
      }
      
      public function progressButtonStatsTrack(event:Event) : void
      {
         FarmStatsManager.count(this.m_buildingClassName,"open_rewards");
      }
      
      public function comparisonButtonStatsTrack(event:Event) : void
      {
         FarmStatsManager.count(this.m_buildingClassName,"open_comparison");
      }
      
      public function onCloseExtraTier(event:Event = null) : void
      {
         if(this.m_extraTierPopup != null)
         {
            this.m_extraTierPopup.enabled = this.m_extraTierPopup.visible = false;
         }
      }
      
      protected function displayWhatIsThis(event:Event = null) : void
      {
         var imageSize:Number = 100;
         var str:String = "";
         var strPK:String = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"HowDoesThisWork");
         var basketPK:String = RewardCreditsBuilding.getBasketFriendlyName(this.m_buildingClassName);
         var itemPK:String = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_buildingClassName);
         var buildingPK:String = RewardCreditsBuilding.getBuildableFriendlyName(this.m_buildingClassName);
         if("" != strPK)
         {
            if("" != basketPK && ZLocUtils.isObject(basketPK) && "" != itemPK && ZLocUtils.isObject(itemPK) && "" != buildingPK && ZLocUtils.isObject(buildingPK))
            {
               str = ZLocUtils.t_pk(strPK,null,{
                  "basket":ZLocUtils.tk_pk(basketPK),
                  "item":ZLocUtils.tk_pk(itemPK),
                  "item_same":ZLocUtils.tk_pk(itemPK),
                  "building":ZLocUtils.tk_pk(buildingPK)
               });
            }
            else
            {
               str = ZLocUtils.t_pk(strPK);
            }
         }
         this.m_howDoesThisWorkPopup = new GenericXMLDialog("","",null,this.m_building.getHowDoesThisWorkImageRelUrl(),imageSize,imageSize,str,this.onHowDoesThisWorkClose,false,ZLocUtils.t(LOC_BUNDLE,"Accept"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
         UI.displayPopup(this.m_howDoesThisWorkPopup,false,this.m_buildingClassName + "_howDoesThisWorkPopup",true);
      }
      
      protected function onHowDoesThisWorkClose(event:GenericPopupEvent) : void
      {
         this.m_howDoesThisWorkPopup = null;
      }
      
      protected function buildProgressFrame(frame:ZwFrame, slotIndex:int = -1) : void
      {
         var setupProgressFrameCreditsText:Function;
         var progressSlotFrame:ProgressSlotFrame;
         var teaserDisableDate:String = null;
         var teaserEndTime:Number = NaN;
         var newGiftsText:String = null;
         var element:Object = frame.element;
         var index:int = 0;
         if(slotIndex >= 0)
         {
            index = slotIndex;
         }
         setupProgressFrameCreditsText = function(pFrame:ProgressSlotFrame):void
         {
            var strPK:String = null;
            if(pFrame.element.spendLabel_tf)
            {
               strPK = RewardCreditsBuilding.getLocalizedKey(m_buildingClassName,"NumCreditsLabel");
               if("" == strPK)
               {
                  strPK = "RewardCreditsBuilding:NumCreditsLabel";
               }
               pFrame.addWidget(new ZwTextField(pFrame.element.spendLabel_tf,ZLocUtils.t_pk(strPK)));
            }
            if(pFrame.element.spendAmount_tf)
            {
               pFrame.addWidget(new ZwTextField(pFrame.element.spendAmount_tf,getNumCreditsAmountText()));
            }
         };
         this.m_progressSlotFrameArray[index] = new ProgressSlotFrame(frame.element as MovieClip,this.redeemItemCallback,this.m_building,this,setupProgressFrameCreditsText,this.m_buildingClassName,this.onSingleClickBuy);
         progressSlotFrame = this.m_progressSlotFrameArray[index];
         if(getWidget(progressSlotFrame) == null)
         {
            addWidget(progressSlotFrame);
         }
         progressSlotFrame.items = this.constructNewProgressData(0,this.NUM_PROGRESS_SLOTS,slotIndex);
         if(progressSlotFrame.items.length > this.NUM_PROGRESS_SLOTS)
         {
            progressSlotFrame.pageNumber = progressSlotFrame.items.length / this.NUM_PROGRESS_SLOTS - 1;
            teaserDisableDate = Global.farmGameSettingsManager.getString(this.m_buildingClassName + "NewGiftsTeaserDisableDate");
            if(teaserDisableDate != "")
            {
               teaserEndTime = FarmGameUtil.synchronizedDateToNumber(teaserDisableDate);
               if(GlobalEngine.serverTime < teaserEndTime)
               {
                  newGiftsText = ZLocUtils.t("RewardCreditsBuilding","NewGifts");
                  if(newGiftsText != "" && Boolean(frame.element["teaser_mc"]))
                  {
                     frame.addWidget(new ZwTextField(frame.element.teaser_mc.generic_tf,newGiftsText));
                     frame.element.teaser_mc.visible = true;
                  }
               }
            }
         }
      }
      
      protected function getNumCreditsAmountText() : String
      {
         var amount:uint = this.m_building.getCurrentCredits();
         var amountText:String = ZLocUtils.t("RewardCreditsBuilding","NumCreditsAmount",{"quantity":amount});
         if(amountText == "")
         {
            amountText = this.m_building.getCurrentCredits().toString();
         }
         return amountText;
      }
      
      protected function redeemItemCallback(itemData:Object) : void
      {
         var redeemItemData:Object = null;
         var message:String = null;
         var imageSize:Number = NaN;
         var folderNum:int = 0;
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         var strPK:String = null;
         if(!Global.player.hasGiftBoxCapacity())
         {
            UI.displayMessage(ZLocUtils.t(LOC_BUNDLE,"InventoryCellar_GiftBoxFull"),0,null,"",true);
         }
         else
         {
            redeemItemData = this.m_itemToBuy = itemData;
            this.m_itemToBuyCostInfo = this.m_building.getRedeemItemCostInfo(redeemItemData.cost);
            if(this.m_itemToBuyCostInfo.canAfford)
            {
               strPK = "";
               strPK = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"RewardCredits_RedeemConfirm");
               if("" == strPK)
               {
                  strPK = LOC_BUNDLE + ":RewardCredits_RedeemConfirm";
               }
               message = ZLocUtils.t_pk(strPK,null,{"quantity":this.m_itemToBuyCostInfo.totalCreditCost});
               FarmStatsManager.count(this.m_buildingClassName,"redeem",redeemItemData.name,"ticket_redeem");
            }
            else
            {
               message = ZLocUtils.t(LOC_BUNDLE,"RewardCredits_RedeemConfirmFarmCash",{
                  "item":ZLocUtils.tk_pk(redeemItemData.friendlyName),
                  "cashQuantity":this.m_itemToBuyCostInfo.costToComplete
               });
               FarmStatsManager.count(this.m_buildingClassName,"redeem",redeemItemData.name,"FC_impulse_buy");
            }
            imageSize = 100;
            if(itemData.avatarItemCode == null)
            {
               folderNum = 2;
            }
            else
            {
               folderNum = 3;
            }
            centerIconUrl = Global.reverseAssetURL(itemData.icon,folderNum);
            dialog = new GenericXMLDialog(null,"",null,centerIconUrl,imageSize,imageSize,message,this.onConfirmRedeem,false,ZLocUtils.t("Dialogs","Accept"),null,ZLocUtils.t("Dialogs","Cancel"),null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
            UI.displayPopup(dialog,false);
         }
      }
      
      protected function getRedeemCallBack() : Function
      {
         return null;
      }
      
      protected function onConfirmRedeem(event:GenericPopupEvent) : void
      {
         var canRedeem:Boolean = false;
         var redeemItemData:Object = null;
         var creditType:String = null;
         var transaction:TRedeemCreditsItem = null;
         var missingCredits:Object = null;
         var featureCreditName:String = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            canRedeem = false;
            redeemItemData = this.m_itemToBuy;
            if(this.m_itemToBuyCostInfo.canAfford)
            {
               canRedeem = true;
            }
            else if(Global.player.cash >= this.m_itemToBuyCostInfo.costToComplete)
            {
               canRedeem = true;
            }
            if(canRedeem)
            {
               if(redeemItemData.avatarItemCode == null)
               {
                  transaction = new TRedeemCreditsItem(this.m_building,redeemItemData.name,this.m_itemToBuyCostInfo.totalCreditCost,false,this.getRedeemCallBack());
               }
               else
               {
                  transaction = new TRedeemCreditsItem(this.m_building,redeemItemData.avatarItemCode,this.m_itemToBuyCostInfo.totalCreditCost,true,this.getRedeemCallBack());
               }
               transaction.setCenterIconVerticalDisplace(CENTER_ICON_VERTICAL_DISPLACE);
               TransactionManager.addTransaction(transaction,true);
               if(this.m_itemToBuyCostInfo.costToComplete)
               {
                  Global.player.cash -= this.m_itemToBuyCostInfo.costToComplete;
                  missingCredits = this.m_itemToBuyCostInfo.missingCredits;
                  for(creditType in missingCredits)
                  {
                     this.m_building.addCredits(missingCredits[creditType],creditType,this);
                  }
                  this.m_building.setDisplayObjectDirty(true);
                  this.m_building.reloadImage();
                  this.refreshCreditsMeterAndText();
               }
               if(this.m_itemToBuyCostInfo.totalCreditCost)
               {
                  for(creditType in redeemItemData.cost)
                  {
                     featureCreditName = creditType == "feature" ? this.m_building.getCreditsFeatureName() : creditType;
                     this.m_building.useCredits(redeemItemData.cost[creditType],featureCreditName);
                  }
               }
               if(redeemItemData.avatarItemCode == null)
               {
                  Global.player.addGift(redeemItemData.name);
               }
               else
               {
                  Global.player.avatarState.grantItem(redeemItemData.avatarItemCode);
               }
            }
            else
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",this.m_itemToBuyCostInfo.totalCreditCost,redeemItemData.type);
            }
            onClose(event);
         }
      }
      
      protected function onSingleClickBuy(itemData:Object) : Boolean
      {
         var creditType:String = null;
         var transaction:TRedeemCreditsItem = null;
         var missingCredits:Object = null;
         var featureCreditName:String = null;
         var result:Boolean = false;
         this.m_itemToBuy = itemData;
         var canRedeem:Boolean = false;
         var redeemItemData:Object = this.m_itemToBuy;
         if(this.m_itemToBuyCostInfo.canAfford)
         {
            canRedeem = true;
         }
         else if(Global.player.cash >= this.m_itemToBuyCostInfo.costToComplete)
         {
            canRedeem = true;
         }
         if(canRedeem)
         {
            if(redeemItemData.avatarItemCode == null)
            {
               transaction = new TRedeemCreditsItem(this.m_building,redeemItemData.name,this.m_itemToBuyCostInfo.totalCreditCost,false,null);
            }
            else
            {
               transaction = new TRedeemCreditsItem(this.m_building,redeemItemData.avatarItemCode,this.m_itemToBuyCostInfo.totalCreditCost,true,null);
            }
            transaction.setCenterIconVerticalDisplace(CENTER_ICON_VERTICAL_DISPLACE);
            TransactionManager.addTransaction(transaction,true);
            if(this.m_itemToBuyCostInfo.costToComplete)
            {
               Global.player.cash -= this.m_itemToBuyCostInfo.costToComplete;
               missingCredits = this.m_itemToBuyCostInfo.missingCredits;
               for(creditType in missingCredits)
               {
                  this.m_building.addCredits(missingCredits[creditType],creditType,this);
               }
               this.m_building.setDisplayObjectDirty(true);
               this.m_building.reloadImage();
               FarmStatsManager.count(this.m_buildingClassName,redeemItemData.name as String,this.m_itemToBuyCostInfo.costToComplete.toString());
            }
            if(this.m_itemToBuyCostInfo.totalCreditCost)
            {
               for(creditType in redeemItemData.cost)
               {
                  featureCreditName = creditType == "feature" ? this.m_building.getCreditsFeatureName() : creditType;
                  this.m_building.useCredits(redeemItemData.cost[creditType],featureCreditName);
               }
            }
            if(redeemItemData.avatarItemCode == null)
            {
               Global.player.addGift(redeemItemData.name);
            }
            else
            {
               Global.player.avatarState.grantItem(redeemItemData.avatarItemCode);
            }
            this.refreshCreditsMeterAndText();
            result = true;
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",this.m_itemToBuyCostInfo.totalCreditCost,redeemItemData.type);
         }
         return result;
      }
      
      protected function isAskSendEnabled() : Boolean
      {
         var disableDate:String = this.getAskSendDisableDate();
         var endTime:Number = FarmGameUtil.synchronizedDateToNumber(disableDate);
         return GlobalEngine.serverTime < endTime;
      }
      
      protected function getAskSendDisableDate() : String
      {
         return Global.farmGameSettingsManager.getString(this.m_buildingClassName + "AskSendDisableDate");
      }
      
      protected function checkAskSendExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant("fv_" + this.m_buildingClassName) != 0;
      }
      
      protected function buildBuyAskForButtons() : void
      {
         var str:String = "";
         var strPK:String = "";
         var creditQuantity:String = "5";
         var creditQuantity2:String = "1";
         var itemPK:String = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_buildingClassName);
         if(this.isAskSendEnabled())
         {
            if(m_window.send_bt)
            {
               strPK = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"SendCredits");
               if("" != strPK)
               {
                  if("" != itemPK && ZLocUtils.isObject(itemPK))
                  {
                     str = ZLocUtils.t_pk(strPK,null,{"item":ZLocUtils.tk_pk(itemPK)});
                  }
                  else
                  {
                     str = ZLocUtils.t_pk(strPK);
                  }
               }
               addWidget(new FarmAnimatedTextButton(m_window.send_bt,str,this.onSendCredits,true));
            }
            if(m_window.askFor_mc)
            {
               str = "";
               strPK = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"AskForCredits");
               if("" != strPK)
               {
                  if("" != itemPK && ZLocUtils.isObject(itemPK))
                  {
                     str = ZLocUtils.t_pk(strPK,null,{"item":ZLocUtils.tk_pk(itemPK)});
                  }
                  else
                  {
                     str = ZLocUtils.t_pk(strPK);
                  }
               }
               else
               {
                  str = ZLocUtils.t("RewardCreditsBuilding","AskForCredits");
               }
               this.m_askForButton = new FarmAnimatedTextButton(m_window.askFor_mc,str,this.generateAskForCreditsCallback(),true);
               addWidget(this.m_askForButton);
            }
         }
         if(this.m_creditTypes.length > 1 && Boolean(m_window.buttonframe_mc))
         {
            this.buildMultiBuyButtons();
         }
         else if(m_window.buy_mc)
         {
            this.buildBuyButton(m_window.buy_mc);
         }
      }
      
      private function generateAskForCreditsCallback(creditType:String = null) : Function
      {
         return function(event:Event):void
         {
            m_disableFeedPosts = true;
            refreshWindow();
            m_building.askForCredits(creditType,onAskButtonCompleteCallback);
         };
      }
      
      private function onAskButtonCompleteCallback(result:Object = null) : void
      {
         var obj:Object = null;
         this.m_disableFeedPosts = false;
         this.refreshWindow();
         if(this.m_askForCreditsPanelButtons)
         {
            for each(obj in this.m_askForCreditsPanelButtons)
            {
               if(Boolean(obj["button"]) && Boolean(obj["creditType"]))
               {
                  (obj.button as FarmAnimatedTextButton).enabled = true;
                  (obj.button as FarmAnimatedTextButton).text = this.m_building.askForCreditsButtonText(obj.creditType);
               }
            }
         }
      }
      
      private function updateBuyQuantities() : void
      {
         if(this.m_walletSize >= 70)
         {
            this.m_treatPackSize = 20;
            this.m_treatPackSizeExpensive = 15;
         }
         else if(this.m_walletSize >= 20 && this.m_walletSize < 70)
         {
            this.m_treatPackSize = 15;
            this.m_treatPackSizeExpensive = 10;
         }
         else if(this.m_walletSize >= 15 && this.m_walletSize < 20)
         {
            this.m_treatPackSize = 10;
            this.m_treatPackSizeExpensive = 5;
         }
         else
         {
            this.m_treatPackSize = 5;
            this.m_treatPackSizeExpensive = 1;
         }
      }
      
      protected function packSizeToSuffix(size:int) : String
      {
         var result:String = "";
         if(size > 1)
         {
            result = "_" + size.toString() + "pack";
         }
         return result;
      }
      
      protected function buildBuyButton(button1:MovieClip, button2:MovieClip = null) : void
      {
         var str:String = null;
         var strPK:String = null;
         var itemPK:String = null;
         if(button1 != null)
         {
            this.updateBuyQuantities();
            str = "";
            strPK = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"BuyCredits");
            itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_buildingClassName);
            if("" == strPK)
            {
               strPK = "RewardCreditsBuilding:BuyCredits";
            }
            if("" != itemPK && ZLocUtils.isObject(itemPK))
            {
               str = ZLocUtils.t_pk(strPK,null,{
                  "item":ZLocUtils.tk_pk(itemPK),
                  "quantity":this.m_treatPackSize.toString()
               });
            }
            else
            {
               str = ZLocUtils.t_pk(strPK);
            }
            this.m_buyButton = new FarmAnimatedTextButton(button1,str,this.onBuyCredits,true);
            addWidget(this.m_buyButton);
         }
      }
      
      protected function buildMultiBuyButtons(slots:Boolean = false) : void
      {
         var item:FarmItem = null;
         var itemPackName:String = null;
         var buttonName:String = null;
         var treatPackSize:int = 0;
         var index:int = 0;
         var element:DisplayObject = null;
         var func:Function = null;
         var offBoard:Array = this.m_building.getOffBoardingData();
         this.updateBuyQuantities();
         for(index = 0; index < this.m_creditTypes.length; index++)
         {
            buttonName = "buttonframe" + getMcNumFromIndex(index) + "_mc";
            if(slots && Boolean(m_window["panel" + index.toString() + "_mc"]))
            {
               buttonName = "buttonframe" + index.toString() + "_mc";
               element = m_window["panel" + index.toString() + "_mc"][buttonName];
            }
            else
            {
               element = m_window[buttonName];
            }
            if(element)
            {
               itemPackName = this.m_creditTypes[index] + this.packSizeToSuffix(this.m_treatPackSize);
               item = Global.farmGameSettingsManager.getFarmItemByName(itemPackName);
               if(item)
               {
                  if(item.cash / this.m_treatPackSize > EXPENSIVE_PACKAGE_THRESHOLD)
                  {
                     treatPackSize = this.m_treatPackSizeExpensive;
                     itemPackName = this.m_creditTypes[index] + this.packSizeToSuffix(treatPackSize);
                  }
                  else
                  {
                     treatPackSize = this.m_treatPackSize;
                  }
                  func = ZCacheUtil.applyPartial(this.onBuyVariableCredits,this,[itemPackName]);
                  this.addWalletSizeButton(element,itemPackName,treatPackSize.toString(),func,this.m_creditTypes[index]);
               }
            }
         }
      }
      
      protected function buildMultiAskButtons() : void
      {
         var index:int = 0;
         var str:String = null;
         var element:MovieClip = null;
         this.m_askForCreditsPanelButtons = new Array();
         for(index = 0; index < this.m_creditTypes.length; index++)
         {
            if(Boolean(m_window["panel" + index.toString() + "_mc"]) && Boolean(m_window["panel" + index.toString() + "_mc"]["askFor_mc"]))
            {
               str = this.m_building.askForCreditsButtonText(this.m_creditTypes[index]);
               element = m_window["panel" + index.toString() + "_mc"]["askFor_mc"];
               this.m_askForButton = addWidget(new FarmAnimatedTextButton(element,str,this.generateAskForCreditsCallback(this.m_creditTypes[index]),true)) as FarmAnimatedTextButton;
               this.checkAskButtonGrayOutStatus(this.m_askForButton);
               this.m_askForCreditsPanelButtons.push({
                  "button":this.m_askForButton,
                  "creditType":this.m_creditTypes[index]
               });
            }
         }
      }
      
      private function checkAskButtonGrayOutStatus(askButton:FarmAnimatedTextButton) : void
      {
         var waitStr:String = ZLocUtils.t_pk(RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"Waiting"));
         var askStr:String = "";
         var strPK:String = RewardCreditsBuilding.getLocalizedKey(this.m_buildingClassName,"AskForCredits");
         var itemPK:String = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_buildingClassName);
         if("" != strPK)
         {
            if("" != itemPK && ZLocUtils.isObject(itemPK))
            {
               askStr = ZLocUtils.t_pk(strPK,null,{"item":ZLocUtils.tk_pk(itemPK)});
            }
            else
            {
               askStr = ZLocUtils.t_pk(strPK);
            }
         }
         else
         {
            askStr = ZLocUtils.t("RewardCreditsBuilding","AskForCredits");
         }
         if(!this.m_building.isAllowedToSendR4R() && (this.m_disableFeedPosts == true || !this.m_building.isOutsideAskPostFeedThrottle() || !this.m_building.isAllowedToPostAskFeed(this.m_creditTypes[0])))
         {
            askButton.enabled = false;
            askButton.text = waitStr;
            askButton.applyGrayOut = true;
         }
         else
         {
            askButton.enabled = this.isAskSendEnabled();
            askButton.text = askStr;
            askButton.applyGrayOut = false;
         }
      }
      
      private function addWalletSizeButton(element:DisplayObject, itemName:String, itemQty:String, buyCallback:Function, stringReplace:String = "") : void
      {
         var creditItem:FarmItem = null;
         var buttonText:String = null;
         var buyFrame2:ZwFrame = addWidget(new ZwFrame(element)) as ZwFrame;
         var obj:Object = element as Object;
         if(obj.buy_mc)
         {
            creditItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            buttonText = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry(this.m_buildingClassName,"BuyButtonText_" + stringReplace),new ZLocFailoverEntry("RewardCreditsBuilding","BuyButtonText")],{"quantity":itemQty});
            buyFrame2.addWidget(new ZwTextField(obj.buy_mc.generic_tf,buttonText));
            buyFrame2.addWidget(new FarmAnimatedButton(obj.buy_mc,buyCallback)) as FarmAnimatedButton;
            buyFrame2.addWidget(new ZwTextField(obj.buy_mc.fc_amount_tf,creditItem.cash.toString()));
            if(obj.treat2_mc)
            {
               (obj.treat2_mc as MovieClip).visible = true;
               if(obj.treat2_mc.treat2rollover_mc)
               {
                  this.setRolloverText(obj.treat2_mc.treat2rollover_mc);
                  obj.treat2_mc.treat2rollover_mc.visible = false;
                  (obj.treat2_mc as MovieClip).addEventListener(MouseEvent.ROLL_OVER,this.rolloverCallback);
                  (obj.treat2_mc as MovieClip).addEventListener(MouseEvent.ROLL_OUT,this.rolloutCallback);
               }
            }
         }
      }
      
      private function onSendCredits(evt:MouseEvent) : void
      {
         FarmStatsManager.count(this.m_buildingClassName,"send_credits");
         if(Utilities.isFullScreen())
         {
            Utilities.toggleFullScreen();
         }
         close();
         FreeGiftSelectionWindow.popWindow();
      }
      
      protected function onAskForCredits(evt:MouseEvent) : void
      {
         MFSRequestManager.getInstance().makeAskCreditsRequest(this.m_buildingClassName,MFSConstants.SOURCE_UI,this.m_buildingClassName,"request_more_credits");
      }
      
      protected function onBuyCredits(evt:MouseEvent) : void
      {
         if(this.m_shown && !this.isSingleClickEnabled())
         {
            this.hide();
         }
         var rewardCreditNames:Array = Global.storageSettings.getStorageItems(this.m_buildingClassName.toLowerCase());
         var itemName:String = rewardCreditNames[0].name + this.packSizeToSuffix(this.m_treatPackSize);
         this.m_creditsToBuy = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.executeBuyFlow(this.m_creditsToBuy);
      }
      
      protected function onBuyVariableCredits(itemName:String, evt:MouseEvent) : void
      {
         if(this.m_shown && !this.isSingleClickEnabled())
         {
            this.hide();
         }
         this.m_creditsToBuy = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.executeBuyFlow(this.m_creditsToBuy);
      }
      
      private function executeBuyFlow(creditsToBuy:FarmItem) : void
      {
         var messageText:String = null;
         var imageSize:Number = NaN;
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         if(this.isSingleClickEnabled())
         {
            if(Global.player.canBuyCash(creditsToBuy.cash,true,creditsToBuy.type))
            {
               Global.world.addGameMode(new GMCreditsBuildingItemPlace(creditsToBuy.name,false),false);
               this.refreshWindow();
               this.refreshCreditsMeterAndText();
               this.showBuyCheckMark();
               FarmStatsManager.count(this.m_buildingClassName,"purchase_credits","accept");
            }
         }
         else
         {
            messageText = ZLocUtils.t(LOC_BUNDLE,"ConstructionBuilding_BuyConfirmation",{
               "item":ZLocUtils.tk_pk(creditsToBuy.friendlyName),
               "cashQuantity":creditsToBuy.cash
            });
            imageSize = 100;
            centerIconUrl = Global.reverseAssetURL(creditsToBuy.icon,2);
            dialog = new GenericXMLDialog(null,"",null,centerIconUrl,imageSize,imageSize,messageText,this.onBuyCreditsConfirmation,false,ZLocUtils.t("Dialogs","Accept"),null,ZLocUtils.t("Dialogs","Cancel"),null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
            UI.displayPopup(dialog,false);
         }
         if(this.m_building.isAtFeatureCreditLimit())
         {
            if(this.m_buyButton)
            {
               this.m_buyButton.enabled = false;
            }
            this.m_askForButton.enabled = false;
         }
      }
      
      private function onBuyCreditsConfirmation(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT && this.m_creditsToBuy != null)
         {
            if(Global.player.canBuyCash(this.m_creditsToBuy.cash,true))
            {
               Global.world.addGameMode(new GMCreditsBuildingItemPlace(this.m_creditsToBuy.name,false),false);
            }
            this.refreshCreditsMeterAndText();
            if(this.m_leaderboardFrame != null)
            {
               this.m_leaderboardFrame.repopulateData();
            }
            this.show();
            FarmStatsManager.count(this.m_buildingClassName,"purchase_credits","accept");
         }
         else if(!this.m_shown)
         {
            this.show();
            FarmStatsManager.count(this.m_buildingClassName,"purchase_credits","cancel");
         }
      }
      
      public function refreshCreditsMeterAndText() : void
      {
         var rewardMeter:RewardCreditsMeterFrame = null;
         var prizeRewardMeter:RewardCreditsMeterFrame = null;
         var prizeRewardMeter2:RewardCreditsMeterFrame = null;
         var rewardStates:StatesFlyoutSlotFrame = null;
         var index:int = 0;
         var ticketWalletText:ZwTextField = null;
         var ticketReceivedText:ZwTextField = null;
         var level:int = 0;
         if(m_window.meter_mc)
         {
            rewardMeter = this.getWidget(m_window.meter_mc) as RewardCreditsMeterFrame;
            rewardMeter.animated = true;
            rewardMeter.refreshMeter();
         }
         else if(Boolean(m_window.meter0_mc) && this.getWidget(m_window.meter0_mc) != null)
         {
            prizeRewardMeter = this.getWidget(m_window.meter0_mc) as RewardCreditsMeterFrame;
            prizeRewardMeter.animated = true;
            prizeRewardMeter.refreshMeter();
            if(Global.player.getSeenFlag(this.m_buildingClassName + "_BrokeMeter"))
            {
               m_window.meter0_mc.prize_mc.visible = true;
               m_window.meter0_mc.prizeComplete_mc.visible = true;
            }
            else
            {
               m_window.meter0_mc.prize_mc.visible = true;
               m_window.meter0_mc.prizeComplete_mc.visible = false;
            }
         }
         else if(Boolean(m_window.meter1_mc) && this.getWidget(m_window.meter1_mc) != null)
         {
            prizeRewardMeter2 = this.getWidget(m_window.meter1_mc) as RewardCreditsMeterFrame;
            prizeRewardMeter2.animated = true;
            prizeRewardMeter2.refreshMeter();
         }
         else if(m_window.levels_mc)
         {
            rewardStates = this.getWidget(m_window.levels_mc) as StatesFlyoutSlotFrame;
            rewardStates.refresh();
         }
         var progressSlotFrame:ProgressSlotFrame = null;
         if(this.m_progressSlotFrameArray.length > 0)
         {
            progressSlotFrame = this.m_progressSlotFrameArray[0];
         }
         if(Boolean(progressSlotFrame) && Boolean(progressSlotFrame.element.spendAmount_tf))
         {
            (progressSlotFrame.getWidget(progressSlotFrame.element.spendAmount_tf) as ZwTextField).text = this.getNumCreditsAmountText();
            progressSlotFrame.refresh();
         }
         var currentCredits:Object = this.m_building.getMultiTypeCredits(false);
         var totalCredits:Object = this.m_building.getMultiTypeCredits(true);
         if(this.m_creditTypes.length > 1)
         {
            index = 0;
            for(index = 0; index < this.m_creditTypes.length; index++)
            {
               if(m_window["availableWallet" + getMcNumFromIndex(index) + "_tf"])
               {
                  ticketWalletText = getWidget(m_window["availableWallet" + getMcNumFromIndex(index) + "_tf"]) as ZwTextField;
                  ticketWalletText.text = currentCredits[this.m_creditTypes[index]].toString();
               }
               if(m_window["receivedAmount" + getMcNumFromIndex(index) + "_tf"])
               {
                  ticketReceivedText = getWidget(m_window["receivedAmount" + getMcNumFromIndex(index) + "_tf"]) as ZwTextField;
                  ticketReceivedText.text = totalCredits[this.m_creditTypes[0]].toString();
               }
               if(Boolean(m_window["panel" + index.toString() + "_mc"]) && Boolean(m_window["panel" + index.toString() + "_mc"]["availableWallet" + index.toString() + "_tf"]))
               {
                  m_window["panel" + index.toString() + "_mc"]["availableWallet" + index.toString() + "_tf"].text = currentCredits[this.m_creditTypes[index]].toString();
               }
               if(Boolean(m_window["panel" + index.toString() + "_mc"]) && Boolean(m_window["panel" + index.toString() + "_mc"]["receivedAmount" + index.toString() + "_tf"]))
               {
                  m_window["panel" + index.toString() + "_mc"]["receivedAmount" + index.toString() + "_tf"].text = totalCredits[this.m_creditTypes[0]].toString();
               }
            }
         }
         else if(this.m_ticketWalletText)
         {
            this.m_ticketWalletText.text = currentCredits[this.m_buildingClassName].toString();
         }
         if(this.m_stateMc)
         {
            this.m_stateMc.visible = false;
            level = this.m_building.getCurrentSuffix();
            if(m_window.hasOwnProperty("buildable" + level + "_mc"))
            {
               this.m_stateMc = m_window["buildable" + level + "_mc"];
               this.m_stateMc.visible = true;
            }
         }
         if(this.m_progressSlotFrameArray.length > 0)
         {
            (this.m_progressSlotFrameArray[0] as ProgressSlotFrame).refresh();
         }
         this.loadExtraTier();
         this.updateMeterImage();
      }
      
      private function constructNewProgressData(startIndex:int = 0, endIndex:int = 6, ticketIndex:int = -1) : Array
      {
         var redeemItemData:Object = null;
         var eligibleForLastItem:Boolean = false;
         var costInfo:CreditCostInfo = null;
         var validToRedeem:Boolean = false;
         var inRedeemExperiment:Boolean = false;
         var brokenMeterLimit:uint = 0;
         var limitedByBrokenMeter:Boolean = false;
         var redeemItems:Array = Global.farmGameSettingsManager.getBuildingRewardItems(this.m_building.getCreditsFeatureName());
         var redeemItemDataObjects:Array = new Array();
         for(var index:Number = 0; index < redeemItems.length; index++)
         {
            redeemItemData = redeemItems[index];
            eligibleForLastItem = true;
            if(redeemItemData)
            {
               redeemItemData.showInfo = eligibleForLastItem;
               redeemItemData.creditTypes = this.m_creditTypes;
               redeemItemData.cost = redeemItems[index].cost;
               costInfo = this.m_building.getRedeemItemCostInfo(redeemItemData.cost);
               eligibleForLastItem = costInfo.canAfford;
               redeemItemData.canAfford = false;
               if(costInfo.canAfford && !redeemItemData.locked)
               {
                  redeemItemData.canAfford = true;
               }
               validToRedeem = redeemItemData.startDate == null || redeemItemData.startDate == "" || FarmGameUtil.synchronizedDateToNumber(redeemItemData.startDate) < GlobalEngine.serverTime;
               inRedeemExperiment = redeemItemData.experiment == null || redeemItemData.experiment == "" || Global.experimentManager.getExperimentVariant(redeemItemData.experiment) > 0;
               brokenMeterLimit = this.getMeterMaxCredits();
               limitedByBrokenMeter = false;
               if(redeemItemData.cost.length < 2)
               {
                  if(this.m_building.hasMeterBreak() && redeemItemData.cost >= brokenMeterLimit && this.m_building.getTotalCreditsReceived() < brokenMeterLimit)
                  {
                     limitedByBrokenMeter = true;
                  }
               }
               if(validToRedeem && inRedeemExperiment && !limitedByBrokenMeter && (ticketIndex == -1 || this.m_creditTypes[ticketIndex] == redeemItemData.costOrdered[0].type))
               {
                  redeemItemDataObjects.push(redeemItemData);
               }
            }
         }
         return redeemItemDataObjects;
      }
      
      protected function getBuildingCreditsXml() : XML
      {
         return Global.farmGameSettingsManager.getBuildingCreditsXml(this.m_buildingClassName);
      }
      
      protected function getMeterMaxCredits() : uint
      {
         var result:uint = 0;
         var creditsXml:XML = this.getBuildingCreditsXml();
         if(creditsXml)
         {
            result = uint(creditsXml.@meterMaxCredits);
         }
         return result;
      }
      
      protected function getWorldIconPath() : String
      {
         var result:String = "";
         var worldConfig:Object = Global.worldSettingsManager.getConfigByWorld(Global.worldManager.currentWorldType);
         var hudSkinConfig:HUDSkinConfig = null;
         if(Boolean(worldConfig) && Boolean(worldConfig.hudSkinConfig))
         {
            hudSkinConfig = worldConfig.hudSkinConfig as HUDSkinConfig;
         }
         if(hudSkinConfig)
         {
            result = hudSkinConfig.travelDropDownIconPath;
            if(result == "")
            {
               result = DEFAULT_LOCATION_ICON_PATH;
            }
         }
         return result;
      }
      
      protected function isSingleClickEnabled() : Boolean
      {
         var result:Boolean = false;
         var data:XML = Global.farmGameSettingsManager.getBuildingCreditsXml(this.m_buildingClassName);
         if(data.@singleClickBuy.toString() == "true")
         {
            result = true;
         }
         return result;
      }
      
      protected function showBuyCheckMark() : void
      {
         if(this.m_buyCheckMark)
         {
            this.m_buyCheckMark.visible = true;
            this.m_buyCheckMark.gotoAndPlay(0);
            this.m_buyCheckMark.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if(this.m_buyCheckMark != null && this.m_buyCheckMark.currentFrame == this.m_buyCheckMark.totalFrames)
         {
            this.m_buyCheckMark.stop();
            this.m_buyCheckMark.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this.m_buyCheckMark.visible = false;
         }
      }
      
      protected function setupTimer() : void
      {
         var offBoard:Array = this.m_building.getOffBoardingData();
         this.setupPreOffBoarding(offBoard);
      }
      
      protected function setupPreOffBoarding(offBoard:Array) : Boolean
      {
         var splitText:Array = null;
         var numeral:String = null;
         var identifier:String = null;
         var expire:ZwFrame = null;
         var toReturn:Boolean = false;
         if(offBoard != null && offBoard.hasOwnProperty("isPreOffBoard") && offBoard["isPreOffBoard"] == true && offBoard.hasOwnProperty("timeLeftText") && offBoard["timeLeftText"] != "" && offBoard["timeLeftText"] != null && m_window.hasOwnProperty("expiretimer_mc"))
         {
            splitText = (offBoard["timeLeftText"] as String).split(" ");
            numeral = splitText.shift();
            identifier = splitText.join(" ");
            expire = addWidget(new ZwFrame(m_window.expiretimer_mc)) as ZwFrame;
            expire.addWidget(new ZwTextField(m_window.expiretimer_mc.timer_tf,identifier));
            expire.addWidget(new ZwTextField(m_window.expiretimer_mc.timerlabel_tf,numeral));
            toReturn = true;
         }
         return toReturn;
      }
   }
}


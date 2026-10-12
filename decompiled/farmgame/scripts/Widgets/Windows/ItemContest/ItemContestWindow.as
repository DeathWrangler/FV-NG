package Widgets.Windows.ItemContest
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.UI;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import Managers.ItemContestManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.*;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.controller.DynamicDialog;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ItemContestWindow extends FarmWindow
   {
      
      private static const SMALLBG_LIMIT:Number = 4;
      
      private static const HDTW_SCENE_NUMBER:Number = 4;
      
      private static const TRYAGAINRIBBON_FRAME:Number = 9;
      
      private static const AVATARWIN_FRAME:Number = 1;
      
      private static const AVATARLOSE_FRAME:Number = 2;
      
      private static const PAYONLOSE_VARIANT_KEEPMULCH:Number = 2;
      
      private static const PAYONLOSE_VARIANT_PAYTOWIN:Number = 3;
      
      private var m_contestManager:ItemContestManager;
      
      private var m_contestantEntered:String = "";
      
      private var m_frame:GenericSlotContainerFrame;
      
      private var m_activeContestFrame:ICActiveContestSlotFrame;
      
      private var m_dialog:GenericDialog = null;
      
      private var m_hdtwScene:Number = 0;
      
      private var m_resultAccept:FarmAnimatedTextButton;
      
      private var m_helpState:Number = 0;
      
      public function ItemContestWindow(assetUrl:String)
      {
         super(assetUrl);
         this.m_contestManager = ItemContestManager.getInstance();
         this.addEventListener(ItemContestManager.EVENTLISTENER_CONTEST_TYPE,this.mulchFound);
         MT4DManager.getInstance().addEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.destroyDialog);
      }
      
      private function mulchFound(mulchItem:Object) : void
      {
         if(this.m_frame != null)
         {
            this.m_frame.refresh();
         }
      }
      
      private function addWidgets() : void
      {
         var bonus:MovieClip = null;
         if(getWidget(m_window.title_tf) == null)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(new ZwTextField(m_window.title_tf),false);
            }
            if(m_window.hasOwnProperty("moreInfo_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window.moreInfo_bt),false);
            }
            if(ObjectUtil.pathExists(m_window,["main_mc","theme_mc"]))
            {
               addWidget(new FarmIcon(m_window.main_mc.theme_mc),false);
            }
            if(ObjectUtil.pathExists(m_window,["bonusPrize_mc","bonus_mc"]))
            {
               bonus = m_window.bonusPrize_mc.bonus_mc;
               if(bonus.hasOwnProperty("item_mc"))
               {
                  addWidget(new FarmIcon(bonus.item_mc),false);
               }
               if(bonus.hasOwnProperty("bg_mc"))
               {
                  addWidget(new FarmIcon(bonus.bg_mc),false);
               }
               if(bonus.hasOwnProperty("farmCash_mc"))
               {
                  addWidget(new ZwBaseWidget(bonus.farmCash_mc),false);
                  if(bonus.farmCash_mc.hasOwnProperty("cashBG_mc"))
                  {
                     addWidget(new FarmIcon(bonus.farmCash_mc.cashBG_mc),false);
                  }
               }
               if(bonus.hasOwnProperty("places_mc"))
               {
                  addWidget(new ZwBaseWidget(bonus.places_mc),false);
               }
            }
            if(ObjectUtil.pathExists(m_window,["bonusPrize_mc","bonus_tf"]))
            {
               addWidget(new ZwTextField(m_window.bonusPrize_mc.bonus_tf),false);
            }
            if(m_window.hasOwnProperty("info_tf"))
            {
               addWidget(new ZwTextField(m_window.info_tf),false);
            }
            if(m_window.hasOwnProperty("tutorial_mc"))
            {
               addWidget(new ZwBaseWidget(m_window.tutorial_mc),false);
               if(m_window.tutorial_mc.hasOwnProperty("okay_bt"))
               {
                  addWidget(new FarmAnimatedTextButton(m_window.tutorial_mc.okay_bt,ZLocUtils.tk_pk_asTitle("Dialogs:Okay")),false);
               }
            }
            if(m_window.hasOwnProperty("slots_mc"))
            {
               this.m_activeContestFrame = addWidget(new ICActiveContestSlotFrame(m_window.slots_mc,this)) as ICActiveContestSlotFrame;
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var title:ZwTextField = null;
         var moreInfoButton:FarmAnimatedTextButton = null;
         var themeBackground:FarmIcon = null;
         super.postLoadComplete();
         this.addWidgets();
         if(m_window.hasOwnProperty("title_tf"))
         {
            title = getWidget(m_window.title_tf) as ZwTextField;
            title.text = ZLocUtils.tk_pk_asTitle("Dialogs:ContestFeatureName");
            title.visible = true;
         }
         if(m_window.hasOwnProperty("moreInfo_bt"))
         {
            moreInfoButton = getWidget(m_window.moreInfo_bt) as FarmAnimatedTextButton;
            moreInfoButton.text = ZLocUtils.t("Dialogs","WhatIsThis");
            moreInfoButton.callback = this.howDoesThisWorkClick;
            moreInfoButton.visible = true;
         }
         var items:Array = this.m_contestManager.getItemsForContest();
         if(m_window.hasOwnProperty("main_mc"))
         {
            m_window.main_mc.visible = true;
            if((m_window.main_mc as MovieClip).hasOwnProperty("theme_mc"))
            {
               themeBackground = getWidget(m_window.main_mc.theme_mc) as FarmIcon;
               themeBackground.loadIcon(this.m_contestManager.getTheme());
            }
            this.m_frame = new GenericSlotContainerFrame(m_window.main_mc,ItemContestSlot,items,this);
            if(themeBackground)
            {
               themeBackground.visible = true;
            }
         }
         this.setupOverallPrize();
         if(m_window.hasOwnProperty("overlay_mc"))
         {
            m_window.overlay_mc.visible = false;
         }
         if(m_window.hasOwnProperty("winLose_mc"))
         {
            m_window.winLose_mc.visible = false;
         }
         if(m_window.hasOwnProperty("interstitial_mc"))
         {
            m_window.interstitial_mc.visible = false;
         }
         if(!Global.player.getSeenFlag("ContestWhatIsThis"))
         {
            this.howDoesThisWorkClick(null);
         }
      }
      
      public function setupHelpText(itemName:String, full:Boolean) : void
      {
         var info:ZwTextField = null;
         var helpText:String = null;
         if(m_window.hasOwnProperty("info_tf"))
         {
            info = getWidget(m_window.info_tf) as ZwTextField;
            helpText = info.text;
            if(this.m_helpState == 0 && itemName == "")
            {
               helpText = ZLocUtils.tk_pk_asTitle("Dialogs:contestHelpEmpty");
            }
            else if(this.m_helpState < 1 && !full)
            {
               helpText = ZLocUtils.t("Dialogs","contestHelpHasMulch",{"item":itemName});
               this.m_helpState = 1;
            }
            else if(full)
            {
               helpText = ZLocUtils.t("Dialogs","contestHelpFull",{"item":itemName});
               this.m_helpState = 2;
            }
            info.text = helpText;
            info.visible = true;
         }
      }
      
      private function setupOverallPrize() : void
      {
         var bonus:MovieClip = null;
         var cashPrize:Number = NaN;
         var prizeTheme:String = null;
         var iconBox:FarmIcon = null;
         var bonusItem:FarmItem = null;
         var prizeBackground:FarmIcon = null;
         var cashBackground:FarmIcon = null;
         var ribbon:MovieClip = null;
         var bonusText:ZwTextField = null;
         var prizeLevel:Number = this.m_contestManager.getPrizeLevel();
         var prizes:Object = this.m_contestManager.getPrize();
         if(ObjectUtil.pathExists(m_window,["bonusPrize_mc","bonus_mc"]) && prizes != null)
         {
            bonus = m_window.bonusPrize_mc.bonus_mc;
            m_window.bonusPrize_mc.visible = true;
            m_window.bonusPrize_mc.bonus_mc.visible = true;
            cashPrize = 0;
            if(bonus.hasOwnProperty("item_mc"))
            {
               iconBox = getWidget(bonus.item_mc) as FarmIcon;
               bonusItem = prizes.item;
               cashPrize = Number(prizes.cash);
               if(bonusItem != null)
               {
                  iconBox.loadIcon(bonusItem.icon);
                  iconBox.visible = true;
               }
            }
            prizeTheme = this.m_contestManager.getPrizeTheme();
            if(bonus.hasOwnProperty("bg_mc"))
            {
               prizeBackground = getWidget(bonus.bg_mc) as FarmIcon;
               prizeBackground.loadIcon(prizeTheme);
               prizeBackground.visible = true;
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CONTESTS_CASHSURFACE) == 2 && cashPrize > 0 && bonus.hasOwnProperty("farmCash_mc"))
            {
               getWidget(bonus.farmCash_mc).visible = true;
               if(bonus.farmCash_mc.hasOwnProperty("cashBG_mc"))
               {
                  cashBackground = getWidget(bonus.farmCash_mc.cashBG_mc) as FarmIcon;
                  cashBackground.loadIcon(prizeTheme);
                  cashBackground.visible = true;
               }
            }
            else if(bonus.hasOwnProperty("farmCash_mc"))
            {
               getWidget(bonus.farmCash_mc).visible = false;
            }
            if(bonus.hasOwnProperty("places_mc"))
            {
               ribbon = bonus.places_mc;
               this.m_contestManager.setUpRibbon(ribbon,prizeLevel - 1);
            }
         }
         if(ObjectUtil.pathExists(m_window,["bonusPrize_mc","bonus_tf"]))
         {
            bonusText = getWidget(m_window.bonusPrize_mc.bonus_tf) as ZwTextField;
            bonusText.text = ZLocUtils.tk_pk_asTitle("Dialogs:ContestTierPrize");
            bonusText.visible = true;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.hasPopupOpen())
         {
            this.m_dialog.destroy();
            this.m_dialog = null;
         }
         super.onClose(event);
      }
      
      public function hasPopupOpen() : Boolean
      {
         return this.m_dialog != null;
      }
      
      private function destroyDialog(object:WidgetControllerEvent) : void
      {
         var dialog:DynamicDialog = object.getDialog();
         if(this.hasPopupOpen() && dialog.getName() == this.m_dialog.getName())
         {
            this.m_dialog = null;
         }
      }
      
      private function refreshTheme() : void
      {
         var themeBackground:FarmIcon = null;
         if(m_window.hasOwnProperty("main_mc"))
         {
            if((m_window.main_mc as MovieClip).hasOwnProperty("theme_mc"))
            {
               themeBackground = getWidget(m_window.main_mc.theme_mc) as FarmIcon;
               themeBackground.loadIcon(this.m_contestManager.getTheme());
            }
            if(themeBackground)
            {
               themeBackground.visible = true;
            }
         }
      }
      
      public function contestantEntered(contestant:String) : void
      {
         var curtain:MovieClip = null;
         this.m_helpState = 0;
         if(m_window.hasOwnProperty("interstitial_mc"))
         {
            curtain = m_window.interstitial_mc;
            curtain.visible = true;
            curtain.gotoAndPlay(1);
         }
         if(m_window.hasOwnProperty("bonusPrize_mc"))
         {
            m_window.bonusPrize_mc.visible = false;
         }
         if(m_window.hasOwnProperty("info_tf"))
         {
            m_window.info_tf.visible = false;
         }
         if(m_window.hasOwnProperty("main_mc"))
         {
            m_window.main_mc.visible = false;
         }
         if(this.m_activeContestFrame != null)
         {
            this.m_activeContestFrame.visible = false;
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
            m_window.close_bt.visible = false;
         }
         if(m_window.hasOwnProperty("moreInfo_bt"))
         {
            m_window.moreInfo_bt.visible = false;
         }
         this.m_contestantEntered = contestant;
      }
      
      override public function refreshWindow() : void
      {
         var items:Array = null;
         this.m_helpState = 0;
         super.refreshWindow();
         if(this.hasPopupOpen())
         {
            this.m_dialog.destroy();
            this.m_dialog = null;
         }
         if(this.m_frame != null)
         {
            items = this.m_contestManager.getItemsForContest();
            this.m_frame.setData(items);
         }
         if(this.m_activeContestFrame != null)
         {
            this.m_activeContestFrame.visible = true;
            this.m_activeContestFrame.refresh();
         }
         this.setupOverallPrize();
      }
      
      public function showResults(result:Object) : void
      {
         var frame:MovieClip = null;
         var prizeLevel:Number = NaN;
         var avatarFrame:Number = NaN;
         var buttonText:String = null;
         var bubbleHeader:String = null;
         var bubbleSubheader:String = null;
         var bubbleBody:String = null;
         var popLoseDialog:Boolean = false;
         var item:FarmItem = null;
         var prizes:Object = null;
         var itemName:String = null;
         var payOnLose:Number = NaN;
         var icon:ObjectPreviewFrame = null;
         var shouldOffset:Boolean = false;
         var bubble:MovieClip = null;
         if(this.hasPopupOpen())
         {
            this.m_dialog.destroy();
            this.m_dialog = null;
         }
         if(result.hasOwnProperty("success") && Boolean(result.success))
         {
            if(m_window.hasOwnProperty("winLose_mc"))
            {
               frame = m_window.winLose_mc;
               frame.visible = true;
               prizeLevel = ItemContestWindow.TRYAGAINRIBBON_FRAME;
               avatarFrame = ItemContestWindow.AVATARLOSE_FRAME;
               buttonText = ZLocUtils.tk_pk_asTitle("Dialogs:AwShucks");
               bubbleHeader = ZLocUtils.tk_pk_asTitle("Dialogs:TryAgain");
               bubbleSubheader = ZLocUtils.t("Dialogs","WeAlmostHadIt");
               bubbleBody = ZLocUtils.t("Dialogs","BetterLuckNextTime");
               popLoseDialog = true;
               if(result.hasOwnProperty("win") && Boolean(result.win))
               {
                  if(frame.hasOwnProperty("win_mc"))
                  {
                     (frame.win_mc as MovieClip).play();
                  }
                  prizeLevel = this.m_contestManager.getPrizeLevel(this.m_contestantEntered);
                  avatarFrame = ItemContestWindow.AVATARWIN_FRAME;
                  bubbleHeader = ZLocUtils.tk_pk_asTitle("Dialogs:Congrats");
                  bubbleSubheader = ZLocUtils.t("Dialogs","EarnedPlace",{"place":ZLocUtils.tk_pk_asTitle("Dialogs:Place" + prizeLevel.toString())});
                  bubbleBody = ZLocUtils.tk_pk_asTitle("Dialogs:CheckYourGiftbox");
                  buttonText = ZLocUtils.tk_pk_asTitle("Dialogs:Awesome");
                  Global.player.addGift(this.m_contestantEntered);
                  prizes = this.m_contestManager.getPrize();
                  itemName = prizes.item.name;
                  this.m_contestManager.moveUpTier(this.m_contestantEntered,result.data.mulch.curr,result.data.mulch.next,Number(result.data.mulch.start),Number(result.data.mulch.duration));
                  if(prizeLevel > this.m_contestManager.getPrizeLevel())
                  {
                     Global.player.addGift(itemName);
                     Global.player.cash += prizes.cash;
                     FarmStatsManager.count(ItemContestManager.FEATURE_NAME,"complete_tier",prizeLevel.toString(),this.m_contestManager.getCurrentContestName());
                  }
                  popLoseDialog = false;
               }
               if(frame.hasOwnProperty("place_mc"))
               {
                  this.m_contestManager.setUpRibbon(frame.place_mc,prizeLevel - 1);
               }
               if(result.hasOwnProperty("data"))
               {
                  payOnLose = 0;
                  if(result.data != null && Boolean(result.data.hasOwnProperty("payOnLose")))
                  {
                     payOnLose = Number(result.data["payOnLose"]);
                  }
                  if(this.m_resultAccept != null)
                  {
                     this.m_resultAccept.release();
                  }
                  this.m_resultAccept = new FarmAnimatedTextButton(frame.okay_bt,buttonText,ZCacheUtil.applyPartial(this.okayCallback,this,[popLoseDialog,payOnLose]));
               }
               item = Global.farmGameSettingsManager.getFarmItemByName(this.m_contestantEntered);
               if(frame.hasOwnProperty("contestant_mc"))
               {
                  icon = getWidget(frame.contestant_mc) as ObjectPreviewFrame;
                  shouldOffset = true;
                  if(icon != null)
                  {
                     removeWidget(frame.contestant_mc);
                     shouldOffset = false;
                  }
                  icon = addWidget(new ObjectPreviewFrame(frame.contestant_mc,item,null,[item.sizeX == 1 ? 2 : 1.75]),true) as ObjectPreviewFrame;
                  if(shouldOffset)
                  {
                     icon.x -= icon.width / 2;
                     icon.y -= icon.height;
                  }
               }
               if(frame.hasOwnProperty("avatar_mc"))
               {
                  (frame.avatar_mc as MovieClip).gotoAndStop(avatarFrame);
                  frame.avatar_mc.visible = true;
               }
               if(frame.hasOwnProperty("talkBubble_mc"))
               {
                  bubble = frame.talkBubble_mc;
                  if(bubble.hasOwnProperty("header_tf"))
                  {
                     new ZwTextField(bubble.header_tf,bubbleHeader).visible = true;
                  }
                  if(bubble.hasOwnProperty("subheader_tf"))
                  {
                     new ZwTextField(bubble.subheader_tf,bubbleSubheader).visible = true;
                  }
                  if(bubble.hasOwnProperty("body_tf"))
                  {
                     new ZwTextField(bubble.body_tf,bubbleBody).visible = true;
                  }
                  bubble.visible = true;
               }
               if(m_window.hasOwnProperty("interstitial_mc"))
               {
                  m_window.interstitial_mc.gotoAndPlay(16);
               }
            }
         }
      }
      
      private function okayCallback(popLoseDialog:Boolean, payOnLose:Number, event:Event) : void
      {
         var loseVariant:Number = NaN;
         var mulchItem:FarmItem = null;
         var contestantItem:FarmItem = null;
         this.m_contestManager.loseMulch(this.m_contestantEntered);
         this.refreshWindow();
         if(popLoseDialog)
         {
            loseVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CONTESTS_PAY_ON_LOSE);
            if(loseVariant == ItemContestWindow.PAYONLOSE_VARIANT_KEEPMULCH)
            {
               FarmStatsManager.count(ItemContestManager.FEATURE_NAME,"preserve_mulch_prompt",this.m_contestantEntered,this.m_contestManager.getMulchLost().toString());
               mulchItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_contestManager.getMulch(this.m_contestantEntered));
               this.m_dialog = UI.showMessage(ZLocUtils.t("Dialogs","PayToKeepMulch",{"cost":payOnLose}),UI.BUTTON_LAYOUT_ACCEPT_CANCEL,null,mulchItem.icon,false,ZCacheUtil.applyPartial(this.m_contestManager.payToSaveMulch,this,[this.m_contestantEntered,this.refreshWindow,payOnLose]),"PayToSaveMulchPopup",false,ZLocUtils.t("Dialogs","Buy"));
            }
            else if(loseVariant == ItemContestWindow.PAYONLOSE_VARIANT_PAYTOWIN)
            {
               FarmStatsManager.count(ItemContestManager.FEATURE_NAME,"win_prompt",this.m_contestantEntered,this.m_contestManager.getMulchLost().toString());
               contestantItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_contestantEntered);
               this.m_dialog = UI.showMessage(ZLocUtils.t("Dialogs","PayToWinContest",{
                  "item":ZLocUtils.tk_pk_asTitle(contestantItem.friendlyName),
                  "cost":payOnLose
               }),UI.BUTTON_LAYOUT_ACCEPT_CANCEL,null,contestantItem.icon,false,ZCacheUtil.applyPartial(this.payToWinCallback,this,[payOnLose]),"PayToWinContestPopup",false,ZLocUtils.t("Dialogs","Buy"));
            }
         }
         if(m_window.hasOwnProperty("winLose_mc"))
         {
            m_window.winLose_mc.visible = false;
            if(m_window.winLose_mc.hasOwnProperty("win_mc"))
            {
               m_window.winLose_mc.win_mc.visible = false;
            }
         }
         if(m_window.hasOwnProperty("bonusPrize_mc"))
         {
            m_window.bonusPrize_mc.visible = true;
         }
         if(m_window.hasOwnProperty("main_mc"))
         {
            m_window.main_mc.visible = true;
         }
         if(this.m_activeContestFrame != null)
         {
            this.m_activeContestFrame.visible = true;
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
            m_window.close_bt.visible = true;
         }
         if(m_window.hasOwnProperty("moreInfo_bt"))
         {
            m_window.moreInfo_bt.visible = true;
         }
      }
      
      private function payToWinCallback(payOnLose:Number, isAccept:Boolean) : void
      {
         if(isAccept && Global.player.cash > payOnLose)
         {
            this.contestantEntered(this.m_contestantEntered);
            this.m_contestManager.payToWin(this.m_contestantEntered,payOnLose,this.showResults);
            this.m_dialog.destroy();
            this.m_dialog = null;
         }
         else
         {
            UI.showMessage(ZLocUtils.t("Dialogs","NoCash"));
         }
      }
      
      public function showOverlay(contestant:String, event:Event) : void
      {
         var categoryData:Array = null;
         var overlay:MovieClip = null;
         var background:FarmIcon = null;
         var arrayLength:Number = NaN;
         if(m_window.hasOwnProperty("overlay_mc") && !this.hasPopupOpen())
         {
            categoryData = this.m_contestManager.getCategory(contestant);
            overlay = m_window.overlay_mc;
            overlay.visible = true;
            arrayLength = categoryData.length;
            if(arrayLength > ItemContestWindow.SMALLBG_LIMIT)
            {
               background = new FarmIcon(overlay.largeBG_mc);
               background.loadIcon(this.m_contestManager.getOverlayBG(true));
               overlay.smallBG_mc.visible = false;
            }
            else
            {
               background = new FarmIcon(overlay.smallBG_mc);
               background.loadIcon(this.m_contestManager.getOverlayBG(false));
               overlay.largeBG_mc.visible = false;
            }
            if(overlay.hasOwnProperty("close_bt"))
            {
               new FarmButton(overlay.close_bt,this.overlayClose);
            }
            this.setUpOverlay(categoryData);
            background.visible = true;
         }
      }
      
      private function overlayClose(event:Event) : void
      {
         m_window.overlay_mc.visible = false;
      }
      
      public function setUpOverlay(data:Array) : void
      {
         var length:Number = data.length;
         var count:Number = 0;
         while(m_window.overlay_mc.hasOwnProperty("slot_" + count + "_mc"))
         {
            m_window.overlay_mc["slot_" + count + "_mc"].visible = false;
            count++;
         }
         var slots:Array = ["slot_0_mc","slot_1_mc","slot_2_mc","slot_3_mc"];
         switch(length)
         {
            case 5:
               slots.push("slot_7_mc");
               break;
            case 6:
               slots.push("slot_6_mc","slot_8_mc");
               break;
            case 7:
               slots.push("slot_5_mc","slot_7_mc","slot_9_mc");
               break;
            case 8:
               slots.push("slot_4_mc","slot_6_mc","slot_8_mc","slot_10_mc");
         }
         for(var i:Number = 0; i < slots.length; i++)
         {
            this.setupSlot(m_window.overlay_mc[slots[i]],data[i],slots.length - i);
         }
      }
      
      public function setupSlot(slot:MovieClip, data:Object, place:Number) : void
      {
         var slotWidget:ZwWidget = getWidget(slot) as ZwWidget;
         if(slotWidget == null)
         {
            slotWidget = addWidget(new ZwWidget(slot)) as ZwWidget;
         }
         slotWidget.visible = true;
         slot.visible = true;
         var contestantItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(data["contestant"]);
         var icon:FarmIcon = new FarmIcon(slot.icon_mc);
         icon.loadIcon(contestantItem.icon);
         icon.visible = true;
         if(slot.hasOwnProperty("place_tf"))
         {
            new ZwTextField(slot.place_tf,ZLocUtils.tk_pk_asTitle("Dialogs:Place" + place.toString()));
            slot.gotoAndStop(place);
         }
         if(contestantItem.buyable && contestantItem.checkMarketPrereqs() && contestantItem.checkPurchasePrereqs())
         {
            if(slot.hasOwnProperty("cost_bt"))
            {
               slot.cost_bt.price_tf.text = contestantItem.cash;
               Utilities.toggleInputOnlySelf(slot.cost_bt.price_tf,false);
               new FarmAnimatedButton(slot.cost_bt,ZCacheUtil.applyPartial(this.buyItem,this,[contestantItem])).visible = true;
            }
            if(slot.hasOwnProperty("lock_mc"))
            {
               slot.lock_mc.visible = false;
               slotWidget.detachTooltip();
            }
         }
         else
         {
            if(slot.hasOwnProperty("cost_bt"))
            {
               slot.cost_bt.visible = false;
            }
            if(slot.hasOwnProperty("lock_mc"))
            {
               slot.lock_mc.visible = true;
               slotWidget.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","LockedContestant",{"place":ZLocUtils.tk_pk_asTitle("Dialogs:Place" + place.toString())})));
            }
         }
      }
      
      private function buyItem(item:FarmItem, event:Event) : void
      {
         Global.player.buyFarmItem(item,Currency.CASH);
         this.close();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         var tutorialWindow:ZwBaseWidget = null;
         var okayButton:FarmAnimatedTextButton = null;
         if(!this.hasPopupOpen())
         {
            tutorialWindow = getWidget(m_window.tutorial_mc) as ZwBaseWidget;
            tutorialWindow.visible = true;
            okayButton = getWidget(m_window.tutorial_mc.okay_bt) as FarmAnimatedTextButton;
            okayButton.callback = this.howDoesThisWorkClick;
            okayButton.visible = true;
            ++this.m_hdtwScene;
            if(this.m_hdtwScene > 1 && this.m_hdtwScene <= ItemContestWindow.HDTW_SCENE_NUMBER)
            {
               m_window.tutorial_mc.play();
            }
            else if(this.m_hdtwScene > ItemContestWindow.HDTW_SCENE_NUMBER)
            {
               if(!Global.player.getSeenFlag("ContestWhatIsThis"))
               {
                  Global.player.setSeenFlag("ContestWhatIsThis");
               }
               this.m_hdtwScene = 0;
               (m_window.tutorial_mc as MovieClip).gotoAndStop(0);
               tutorialWindow.visible = false;
            }
         }
      }
      
      public function setSelectedContest(contestName:String) : void
      {
         FarmStatsManager.count("item_contest","select",contestName);
         this.m_contestManager.setSelectedContest(contestName);
         this.refreshTheme();
         this.refreshWindow();
      }
      
      public function getActiveContestNames() : Vector.<String>
      {
         return this.m_contestManager.getActiveContestNames();
      }
      
      public function getSelectedContestName() : String
      {
         return this.m_contestManager.getSelectedContestName();
      }
   }
}


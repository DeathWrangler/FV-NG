package Display.Party
{
   import Classes.PartyBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.Dialogs.GenericDialogConfig;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Transactions.TFriendSetBuyLevel;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.controller.TooltipController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class RoyalWeddingPartyDialog extends PartyDialog
   {
      
      private static const STYLE_GREEN_BOX:String = "RoyalWeddingGreenBox";
      
      private static const SEEN_WHATS_THIS_DIALOG:String = "WhatsThisDialog";
      
      private var m_xml:XML = null;
      
      private var m_confirmBuy:GenericDialog = null;
      
      private var m_levelHandler:int = 0;
      
      private var m_offboardingDialog:GenericDialog = null;
      
      private var m_isShowing:Boolean = false;
      
      public function RoyalWeddingPartyDialog(view:BaseWidgetView)
      {
         super(view);
         m_friendSetCode = "FS05";
      }
      
      override protected function setupWindow() : void
      {
         var royalWeddingTents:Array = null;
         var royalWeddingTent:PartyBuilding = null;
         var onPartyOver:Function = null;
         var offboardingMessage:String = null;
         var config:GenericDialogConfig = null;
         super.setupWindow();
         if(m_partyDataObj.friendSet.pendingFriends.length > 0)
         {
            m_partyDataObj.friendSet.markSeen();
         }
         this.m_xml = Global.farmGameSettingsManager.getFriendSetXMLByCode(m_friendSetCode);
         this.setShortcutListener("level1BuyButton",WidgetControllerEvent.BUTTON_PRESSED,this.onBuyLevel);
         this.setShortcutListener("level2BuyButton",WidgetControllerEvent.BUTTON_PRESSED,this.onBuyLevel);
         this.setShortcutListener("level3BuyButton",WidgetControllerEvent.BUTTON_PRESSED,this.onBuyLevel);
         this.setShortcutListener("level4BuyButton",WidgetControllerEvent.BUTTON_PRESSED,this.onBuyLevel);
         this.setShortcutAttribute("whatIsThisText",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","WhatIsThis"));
         this.setShortcutListener("whatIsThisButton",WidgetControllerEvent.BUTTON_PRESSED,this.onWhatIsThis);
         this.setupGuestInfo();
         this.setupProgress();
         this.setupTooltips();
         if(this.m_partyDataObj.isPartyOver())
         {
            this.setShortcutAttribute("InviteButton",ButtonController.ATTRIBUTE_DISABLED,true);
            royalWeddingTents = Global.world.getObjectsByName("royalweddingtent");
            if(royalWeddingTents.length > 0)
            {
               royalWeddingTent = royalWeddingTents[0];
               if(royalWeddingTent is PartyBuilding)
               {
                  onPartyOver = function(event:WidgetControllerEvent):void
                  {
                     m_offboardingDialog.destroy();
                     m_offboardingDialog = null;
                     royalWeddingTent.transformBuilding();
                  };
                  offboardingMessage = ZLocUtils.t("Dialogs","RoyalWedding_Offboarding_Body");
                  config = new GenericDialogConfig();
                  config.setImageUrl("assets/dialogs/4d_elements/RoyalWedding/RW_motd_onboard.png");
                  config.setBodyText(offboardingMessage);
                  config.setCenteredText(true);
                  config.addButton(ZLocUtils.t("Dialogs","OkButton"),GenericDialogConfig.COLOR_GREEN,onPartyOver);
                  config.showCloseButton(false);
                  this.m_offboardingDialog = GenericDialog.createFromConfig(config);
                  this.m_offboardingDialog.show();
               }
            }
         }
      }
      
      override public function show(addToQueue:Boolean = false, popupName:String = "", checkDuplicates:Boolean = false) : void
      {
         super.show(addToQueue,popupName,checkDuplicates);
         this.m_isShowing = true;
      }
      
      override protected function onContentLoaded(controller:BaseWidgetController) : void
      {
         if(controller.getName() == "mainPartyView")
         {
            this.setupAvatarView(controller);
         }
      }
      
      private function setupProgress() : void
      {
         var guestCnt:int = 0;
         var guestsStr:String = null;
         var textStyle:BaseStyle = null;
         var levelCount:int = m_partyDataObj.goal.getHighestGoalLevel();
         var currentLevel:int = this.m_partyDataObj.goal.currentLevel;
         var levelCost:int = 0;
         for(var levelIndex:int = 1; levelIndex <= levelCount; levelIndex++)
         {
            guestCnt = this.m_partyDataObj.goal.getNumFriendsNeededForLevel(levelIndex);
            guestsStr = ZLocUtils.t("Dialogs","GuestsPlain",{
               "quantity":guestCnt,
               "guestword":ZLocUtils.tk("Dialogs","guest_word","",guestCnt)
            });
            this.setShortcutAttribute("level" + levelIndex + "Text",TextFieldView.ATTRIBUTE_TEXT,guestsStr);
            if(levelIndex <= currentLevel)
            {
               this.toggleVisibleAndObstruct("level" + levelIndex + "DoneView",true);
               this.toggleVisibleAndObstruct("level" + levelIndex + "BuyButton",false);
               textStyle = MT4DManager.getInstance().getStyle(STYLE_GREEN_BOX);
               this.setShortcutAttribute("level" + levelIndex + "Box",BaseWidgetView.ATTRIBUTE_STYLE,textStyle);
            }
            else
            {
               this.setShortcutAttribute("level" + levelIndex + "BuyButton",ButtonController.ATTRIBUTE_DISABLED,false);
               this.setShortcutAttribute("level" + levelIndex + "BuyButtonCostText",TextFieldView.ATTRIBUTE_TEXT,m_partyDataObj.goal.getCostToCompleteLevel(levelIndex).toString());
            }
         }
      }
      
      public function onBuyLevel(event:WidgetControllerEvent) : void
      {
         var name:String = null;
         var controller:ButtonController = event.target as ButtonController;
         if(null != controller)
         {
            name = controller.getName();
            switch(name)
            {
               case "level1BuyButton":
                  this.m_levelHandler = 1;
                  break;
               case "level2BuyButton":
                  this.m_levelHandler = 2;
                  break;
               case "level3BuyButton":
                  this.m_levelHandler = 3;
                  break;
               case "level4BuyButton":
                  this.m_levelHandler = 4;
                  break;
               default:
                  this.m_levelHandler = 0;
            }
            if(this.m_levelHandler > 0 && null == this.m_confirmBuy)
            {
               m_cashAmountToSkip = m_partyDataObj.goal.getCostToCompleteLevel(this.m_levelHandler);
               if(Global.player.canBuyCash(m_cashAmountToSkip))
               {
                  this.m_confirmBuy = UI.showMessage(ZLocUtils.t("Dialogs","RoyalWeddingLevelUnlockConfirm",{"quantity":m_cashAmountToSkip}),UI.BUTTON_LAYOUT_YES_NO,null,null,false,this.onBuyConfirm);
                  this.m_confirmBuy.listen(WidgetControllerEvent.DIALOG_DESTROY,this.onBuyCancel);
               }
            }
         }
      }
      
      private function onBuyConfirm(event:WidgetControllerEvent) : void
      {
         var currentLevel:int = 0;
         var levelIndex:* = 0;
         var transaction:TFriendSetBuyLevel = null;
         if(this.m_levelHandler > 0)
         {
            this.m_confirmBuy.destroy();
            this.m_confirmBuy = null;
            currentLevel = this.m_partyDataObj.goal.currentLevel;
            for(levelIndex = this.m_levelHandler; levelIndex > currentLevel; levelIndex--)
            {
               this.setShortcutAttribute("level" + levelIndex + "BuyButton",ButtonController.ATTRIBUTE_DISABLED,true);
            }
            transaction = transaction = new TFriendSetBuyLevel(this.m_partyDataObj.friendSet,this.m_levelHandler,this.onBuyLevelComplete);
            TransactionManager.addTransaction(transaction);
         }
      }
      
      private function onBuyCancel(event:WidgetControllerEvent) : void
      {
         this.m_confirmBuy = null;
      }
      
      private function onBuyLevelComplete() : void
      {
         if(this.m_isShowing)
         {
            setup();
         }
      }
      
      override public function destroy() : void
      {
         this.m_isShowing = false;
         if(m_whatsThisDialog != null)
         {
            m_whatsThisDialog.destroy();
         }
         super.destroy();
      }
      
      private function onWhatIsThis(event:WidgetControllerEvent) : void
      {
         var config:GenericDialogConfig = null;
         if(m_whatsThisDialog == null)
         {
            config = new GenericDialogConfig();
            config.setTitleText(ZLocUtils.t("Dialogs","RoyalWeddingPartyWhatsThisTitle"));
            config.setImageUrl("assets/buildings/bldg_royalweddingtent_icon.png");
            config.setBodyText(ZLocUtils.t("Dialogs","RoyalWeddingPartyWhatsThisText"));
            config.setCenteredText(true);
            config.addButton(ZLocUtils.t("Dialogs","OkButton"),GenericDialogConfig.COLOR_GREEN,this.onWhatIsThisClose);
            config.showCloseButton(false);
            m_whatsThisDialog = GenericDialog.createFromConfig(config);
            m_whatsThisDialog.show();
         }
         else
         {
            m_whatsThisDialog.setVisibility(true);
         }
      }
      
      private function onWhatIsThisClose(event:WidgetControllerEvent) : void
      {
         this.setVisibility(true);
         m_whatsThisDialog.setVisibility(false);
      }
      
      private function setupTooltips() : void
      {
         var rewardName:String = null;
         var rewardXml:XML = null;
         var levelCount:int = m_partyDataObj.goal.getHighestGoalLevel();
         var rewardItems:Array = [];
         var item:FarmItem = null;
         for(var levelIndex:int = 1; levelIndex <= levelCount; levelIndex++)
         {
            rewardName = "";
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               rewardName = m_partyDataObj.goal.getRewardNameForLevel(levelIndex);
            }
            else
            {
               rewardXml = m_partyDataObj.goal.getRewardForLevel(levelIndex);
               if(rewardXml)
               {
                  rewardName = rewardXml.@name;
               }
            }
            if(rewardName)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               rewardItems.push(item);
               if(levelIndex <= this.m_partyDataObj.goal.currentLevel)
               {
                  this.setShortcutAttribute("level" + levelIndex + "Check",BaseWidgetView.ATTRIBUTE_VISIBLE,true);
               }
            }
         }
         var controller:BaseWidgetController = null;
         for(var level:int = 1; level <= rewardItems.length; level++)
         {
            controller = this.getShortcutController("level" + level + "BoxTooltip");
            this.setupToolTip(controller,rewardItems[level - 1],level);
         }
      }
      
      private function setupToolTip(controller:BaseWidgetController, item:FarmItem, levelIndex:int) : void
      {
         if(item)
         {
            controller.getAttribute(TooltipController.ATTRIBUTE_DISPLAY_VIEW).getChildController("body.pos.prizeNameText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.tk_pk_asTitle(item.friendlyName));
            controller.getAttribute(TooltipController.ATTRIBUTE_DISPLAY_VIEW).getChildController("body.prizeMessageText").setAttribute(TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","RoyalWeddingReward" + levelIndex));
         }
      }
   }
}


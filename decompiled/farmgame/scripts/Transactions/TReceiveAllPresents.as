package Transactions
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.Dialogs.GenericDialogConfig;
   import Display.QueuedIcon;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureConfigManager;
   import Managers.NPCManager;
   import Widgets.Windows.MarketplaceGiftingEarlyAccessReceipt;
   import Widgets.Windows.MarketplaceGiftingReceipt;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.CloseButtonController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.TextFieldView;
   
   public class TReceiveAllPresents extends TFarmTransaction
   {
      
      protected var m_allPresentData:Array = null;
      
      protected var m_activePresentData:Object = null;
      
      protected var m_activePresent:FarmItem = null;
      
      private var m_activeReturn:FarmItem = null;
      
      protected var m_senderUID:String = "-1";
      
      protected var m_presentXp:int = 0;
      
      private var m_genericDialog:GenericDialog = null;
      
      public function TReceiveAllPresents()
      {
         super();
      }
      
      public static function get giftingV2Enabled() : Boolean
      {
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_GIFTING_V2);
         return variant > 1;
      }
      
      public static function ReceiveAll(sendNow:Boolean = true) : void
      {
         if(giftingV2Enabled)
         {
            TransactionManager.addTransaction(new TReceiveAllPresents(),sendNow);
         }
         else
         {
            UI.pumpPendingPresentsQueue();
         }
      }
      
      override public function perform() : void
      {
         signedCall("PresentService.receiveAllPresents");
      }
      
      private function processLimitedPresent(presentData:Object) : void
      {
         var recipientFeatureConfig:FeatureConfigManager = null;
         var icon:QueuedIcon = null;
         var senders:Array = null;
         var isMultiGift:Boolean = false;
         var extraData:Object = null;
         var previousExtraData:Array = null;
         var sUID:String = null;
         if(presentData.extraData)
         {
            recipientFeatureConfig = FeatureConfigManager.getFeatureConfiguration(presentData.extraData.featureName + "Recipient");
            icon = Global.hud.rightSideIconQueue.getIconByName("limitedGiftingRecipient");
            senders = new Array();
            isMultiGift = presentData.hasOwnProperty("itemCodes");
            if(isMultiGift)
            {
               senders = presentData.senders;
            }
            else
            {
               if(Boolean(icon) && Boolean(icon.extraData) && icon.extraData.hasOwnProperty("senders"))
               {
                  previousExtraData = icon.extraData.senders as Array;
                  for each(sUID in previousExtraData)
                  {
                     if(sUID != this.m_senderUID)
                     {
                        if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CONVERT_ICON_SENDER_ID_TO_STRING))
                        {
                           senders.push(sUID.toString());
                        }
                        else
                        {
                           senders.push(sUID);
                        }
                     }
                  }
               }
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CONVERT_ICON_SENDER_ID_TO_STRING))
               {
                  senders.push(this.m_senderUID.toString());
               }
               else
               {
                  senders.push(this.m_senderUID);
               }
            }
            extraData = new Object();
            extraData["senders"] = senders;
            extraData["featureName"] = presentData.extraData.featureName;
            extraData["itemName"] = presentData.itemName;
            extraData["itemCodes"] = presentData.itemCodes;
            extraData["itemCodeAmounts"] = presentData.extraData.itemCodeAmounts;
            if(icon == null)
            {
               Global.hud.rightSideIconQueue.addIconToTop("limitedGiftingRecipient",recipientFeatureConfig.getStringConstant("hudIconUrl"),extraData,true);
            }
            else
            {
               icon.extraData = extraData;
               Global.hud.rightSideIconQueue.saveIcons();
            }
         }
      }
      
      private function processModelfarmPresent(presentData:Object) : void
      {
         var senderName:String = Global.friendManager.getFriendName(this.m_senderUID);
         var senderGender:String = Global.friendManager.getFriendGender(this.m_senderUID);
         var msg:String = ZLocUtils.t("Dialogs","ModelFarm_PresentReceive",{
            "user":ZLocUtils.tn(senderName,ZLocUtils.tg(senderGender)),
            "item":ZLocUtils.tk_pk(this.m_activePresent.friendlyName),
            "quantity":this.m_presentXp
         });
         var presentIcon:String = this.m_activePresent.icon;
         var config:GenericDialogConfig = new GenericDialogConfig();
         config.setBodyText(msg);
         config.setImageUrl(presentIcon);
         config.showCloseButton(true);
         config.addButton(ZLocUtils.t("Dialogs","ModelFarm_PresentReceiveButtonVisitModelFarm"),GenericDialogConfig.COLOR_GREEN,this.onModelFarmReceiveDialogButton);
         config.addButton(ZLocUtils.t("Dialogs","ModelFarm_PresentReceiveButtonOpenGiftbox"),GenericDialogConfig.COLOR_GREEN,this.onModelFarmReceiveDialogButton);
         this.m_genericDialog = GenericDialog.createFromConfig(config);
         this.m_genericDialog.setShortcutListener("CloseButtonView",WidgetControllerEvent.BUTTON_PRESSED,this.onModelFarmReceiveDialogButton);
         if(this.m_genericDialog)
         {
            this.m_genericDialog.show();
         }
      }
      
      private function processNormalPresent(altGiftingStatsCounter:String = null) : void
      {
         UI.displayPopup(new MarketplaceGiftingReceipt(this.m_senderUID,this.m_activePresent,this.m_activeReturn,this.onNextPresent,altGiftingStatsCounter),false);
      }
      
      private function processEarlyAccessPresent() : void
      {
         UI.displayPopup(new MarketplaceGiftingEarlyAccessReceipt(this.m_senderUID,this.m_activePresent,this.m_activeReturn,this.onNextPresent),false);
      }
      
      private function processPresent(presentData:Object) : void
      {
         this.m_activePresentData = presentData;
         this.m_activePresent = Global.farmGameSettingsManager.getFarmItemByName(presentData.itemName);
         this.m_senderUID = presentData.senderUID;
         this.m_presentXp = presentData.presentXp;
         this.m_activeReturn = Global.farmGameSettingsManager.getFarmItemByCode(presentData.regiftItemCode);
         if(!presentData.itemContext || presentData.itemContext == null)
         {
            presentData.itemContext = TBuyAndSendPresent.ITEMCONTEXT_NORMAL;
         }
         switch(presentData.itemContext)
         {
            case TBuyAndSendPresent.ITEMCONTEXT_LIMITEDGIFT:
               this.processLimitedPresent(presentData);
               break;
            case TBuyAndSendPresent.ITEMCONTEXT_MODELFARM:
               this.processModelfarmPresent(presentData);
               break;
            case TBuyAndSendPresent.ITEMCONTEXT_NEIGHBORFARM:
               this.processNormalPresent();
               break;
            case TBuyAndSendPresent.ITEMCONTEXT_EARLYACCESS:
               this.processEarlyAccessPresent();
               break;
            case TBuyAndSendPresent.ITEMCONTEXT_PAID_GIFTING_ON_IDLE:
               this.processNormalPresent(StatsTrackingConstants.PAID_GIFTING_ON_IDLE);
               break;
            case TBuyAndSendPresent.ITEMCONTEXT_NORMAL:
            default:
               this.processNormalPresent();
         }
      }
      
      private function onNextPresent() : void
      {
         this.processNextPresent();
      }
      
      private function processNextPresent() : void
      {
         var nextPresent:Object = null;
         if(this.m_allPresentData.length > 0)
         {
            nextPresent = this.m_allPresentData[0];
            this.m_allPresentData.splice(0,1);
            if(nextPresent.complete)
            {
               this.processPresent(nextPresent);
            }
            else
            {
               this.processNextPresent();
            }
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         var presentData:Object = null;
         var senderUid:String = null;
         var activePresent:FarmItem = null;
         var itemCode:String = null;
         var i:Number = NaN;
         if(result != null)
         {
            if(result.presents)
            {
               this.m_allPresentData = result.presents;
               for each(presentData in this.m_allPresentData)
               {
                  if(presentData.complete)
                  {
                     Global.player.xp += presentData.presentXp;
                     senderUid = presentData.senderUID;
                     activePresent = Global.farmGameSettingsManager.getFarmItemByName(presentData.itemName);
                     if(activePresent is IUGCItem)
                     {
                        Global.player.addUgcItemToGiftbox(presentData.itemName,senderUid,presentData.presentUuid,presentData.extraData);
                     }
                     else if(presentData.hasOwnProperty("itemName"))
                     {
                        Global.player.addGift(presentData.itemName,senderUid);
                     }
                     else if(presentData.hasOwnProperty("itemCodes"))
                     {
                        for each(itemCode in presentData.itemCodes)
                        {
                           for(i = 0; i < presentData.extraData.itemCodeAmounts[itemCode]; i++)
                           {
                              Global.player.addGift(Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode),senderUid);
                           }
                        }
                     }
                  }
               }
               this.processNextPresent();
            }
         }
      }
      
      private function presentGenericDialogCloseAndContinue(keepProcessing:Boolean = true) : void
      {
         if(this.m_genericDialog != null)
         {
            this.m_genericDialog.destroy();
            this.m_genericDialog = null;
         }
         if(keepProcessing)
         {
            this.processNextPresent();
         }
      }
      
      protected function onModelFarmReceiveDialogButton(event:WidgetControllerEvent) : void
      {
         var modelFarmId:String = null;
         var controller:BaseWidgetController = event.getController();
         var buttonText:String = controller.getAttribute(TextFieldView.ATTRIBUTE_TEXT);
         if(controller is CloseButtonController)
         {
            UI.refreshGiftBoxWindow();
            this.presentGenericDialogCloseAndContinue();
         }
         else if(buttonText == ZLocUtils.t("Dialogs","ModelFarm_PresentReceiveButtonVisitModelFarm"))
         {
            this.presentGenericDialogCloseAndContinue(false);
            modelFarmId = NPCManager.getInstance().getModelFarmVisitId();
            if(modelFarmId != null)
            {
               NPCManager.getInstance().visitFarm(modelFarmId);
            }
            else
            {
               UI.showMessage(ZLocUtils.t("Dialogs","ModelFarm_VisitNotAvailable"));
            }
         }
         else if(buttonText == ZLocUtils.t("Dialogs","ModelFarm_PresentReceiveButtonOpenGiftbox"))
         {
            this.presentGenericDialogCloseAndContinue();
            if(!UI.refreshGiftBoxWindow())
            {
               UI.displayGiftBoxWindow();
            }
         }
      }
   }
}


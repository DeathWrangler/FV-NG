package Transactions
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.Dialogs.GenericDialogConfig;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.QueuedIcon;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FeatureConfigManager;
   import Managers.NPCManager;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.CloseButtonController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.TextFieldView;
   
   public class TReceivePresent extends TFarmTransaction
   {
      
      protected const DIAMOND_RING:String = "DV";
      
      protected var m_present:FarmItem = null;
      
      protected var m_senderUID:String = "-1";
      
      protected var m_presentXp:int = 0;
      
      protected var m_receivePresentPopup:GenericIconPopup = null;
      
      protected var m_returnFavorPopup:GenericPopup = null;
      
      private var m_genericDialog:GenericDialog = null;
      
      public function TReceivePresent()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("PresentService.receivePresent");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var senderName:String = null;
         var senderGender:String = null;
         var msg:String = null;
         var presentIcon:String = null;
         var config:GenericDialogConfig = null;
         var recipientFeatureConfig:FeatureConfigManager = null;
         var icon:QueuedIcon = null;
         var senders:Array = null;
         var extraData:Object = null;
         var previousExtraData:Array = null;
         var sUID:String = null;
         if(result != null)
         {
            if(result.complete)
            {
               this.m_present = Global.farmGameSettingsManager.getFarmItemByName(result.itemName);
               this.m_senderUID = result.senderUID;
               this.m_presentXp = result.presentXp;
               senderName = Global.friendManager.getFriendName(this.m_senderUID);
               if(this.m_present is IUGCItem)
               {
                  Global.player.addUgcItemToGiftbox(result.itemName,this.m_senderUID,result.presentUuid,result.extraData);
               }
               else
               {
                  Global.player.addGift(result.itemName,this.m_senderUID);
               }
               --Global.pendingPresents;
               if(!result.itemContext || result.itemContext == null)
               {
                  result.itemContext = TBuyAndSendPresent.ITEMCONTEXT_NORMAL;
               }
               senderGender = Global.friendManager.getFriendGender(this.m_senderUID);
               msg = null;
               presentIcon = null;
               if(result.itemContext == TBuyAndSendPresent.ITEMCONTEXT_MODELFARM)
               {
                  msg = ZLocUtils.t("Dialogs","ModelFarm_PresentReceive",{
                     "user":ZLocUtils.tn(senderName,ZLocUtils.tg(senderGender)),
                     "item":ZLocUtils.tk_pk(this.m_present.friendlyName),
                     "quantity":Global.player.calculateXp(this.m_presentXp)
                  });
                  presentIcon = this.m_present.icon;
                  config = new GenericDialogConfig();
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
               else if(result.itemContext == TBuyAndSendPresent.ITEMCONTEXT_NORMAL || result.itemContext == TBuyAndSendPresent.ITEMCONTEXT_NEIGHBORFARM)
               {
                  msg = ZLocUtils.t("Dialogs","PresentReceive",{
                     "user":ZLocUtils.tn(senderName,ZLocUtils.tg(senderGender)),
                     "item":ZLocUtils.tk_pk(this.m_present.friendlyName),
                     "quantity":Global.player.calculateXp(this.m_presentXp)
                  });
                  presentIcon = Global.getAssetURL("assets/presents/presentIconPopup.png");
                  if(this.m_present.code == this.DIAMOND_RING)
                  {
                     if(!senderName)
                     {
                        senderName = ZLocUtils.t("Dialogs","ValentinePresentNameDefault");
                     }
                     msg = ZLocUtils.t("Dialogs","ValentinePresentReceive",{"user":ZLocUtils.tn(senderName,ZLocUtils.tg(senderGender))});
                     presentIcon = Global.getAssetURL("assets/decorations/valentine_mysterybox_icon.png");
                  }
                  this.m_receivePresentPopup = new GenericIconPopup(msg,GenericPopup.TYPE_OK,this.onReceiveClose,presentIcon);
                  UI.displayPopup(this.m_receivePresentPopup);
               }
               else if(result.itemContext == TBuyAndSendPresent.ITEMCONTEXT_LIMITEDGIFT)
               {
                  if(result.extraData)
                  {
                     recipientFeatureConfig = FeatureConfigManager.getFeatureConfiguration(result.extraData.featureName + "Recipient");
                     icon = Global.hud.rightSideIconQueue.getIconByName("limitedGiftingRecipient");
                     senders = new Array();
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
                     extraData = new Object();
                     extraData["senders"] = senders;
                     extraData["featureName"] = result.extraData.featureName;
                     extraData["itemName"] = result.itemName;
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
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","PresentRecieveFailSorry"));
            }
         }
      }
      
      private function presentDialogRecieveAndClose(pumpQueue:Boolean = true) : Boolean
      {
         var result:Boolean = false;
         if(Global.pendingPresents > 0)
         {
            if(pumpQueue)
            {
               UI.pumpPendingPresentsQueue();
            }
            result = true;
         }
         Global.player.xp += this.m_presentXp;
         this.m_receivePresentPopup = null;
         if(this.m_genericDialog != null)
         {
            this.m_genericDialog.destroy();
            this.m_genericDialog = null;
         }
         return result;
      }
      
      protected function onReceiveClose(event:GenericPopupEvent) : void
      {
         var msg:String = null;
         var isPendingPresents:Boolean = this.presentDialogRecieveAndClose();
         UI.refreshGiftBoxWindow();
         if(!isPendingPresents && Global.featureBuyableGifts && Global.pendingPresents == 0)
         {
            msg = ZLocUtils.t("Dialogs","PresentReturnFavor");
            this.m_returnFavorPopup = new GenericPopup(msg,GenericPopup.TYPE_ACCEPTCANCEL,this.onReturnFavorClose);
            this.m_returnFavorPopup.setAcceptTextName("Market");
            UI.displayPopup(this.m_returnFavorPopup);
         }
      }
      
      protected function onModelFarmReceiveDialogButton(event:WidgetControllerEvent) : void
      {
         var modelFarmId:String = null;
         var controller:BaseWidgetController = event.getController();
         var buttonText:String = controller.getAttribute(TextFieldView.ATTRIBUTE_TEXT);
         if(controller is CloseButtonController)
         {
            this.presentDialogRecieveAndClose();
            UI.refreshGiftBoxWindow();
         }
         else if(buttonText == ZLocUtils.t("Dialogs","ModelFarm_PresentReceiveButtonVisitModelFarm"))
         {
            this.presentDialogRecieveAndClose(false);
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
            this.presentDialogRecieveAndClose();
            if(!UI.refreshGiftBoxWindow())
            {
               UI.displayGiftBoxWindow();
            }
         }
      }
      
      protected function onReturnFavorClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            UI.displayMarketDialog("receivePresent","decoration");
         }
         this.m_returnFavorPopup = null;
      }
   }
}


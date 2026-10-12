package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.Toggles.ZwToggle;
   import Widgets.Frames.MFSFreeGiftsRadioButtonFrame;
   import com.adobe.serialization.json.JSON;
   
   public class MFSSendGiftBase extends MFSWindow
   {
      
      private static const ABSTRACT_CLASS_ERROR:String = "MFSSendGift is an abstract class! Extend it and override required methods.";
      
      public static const STATS_FLOW_NAME:String = "gift";
      
      protected var m_giftsToggleManager:ZwToggleManager = null;
      
      protected var m_giftItems:Array = null;
      
      protected var m_limitFriends:Boolean;
      
      protected var m_altCornerWidget:ZwWidget;
      
      public function MFSSendGiftBase(giftItem:FarmItem, source:String, limitFriends:Boolean, completeCallback:Function, mfsType:String, friendSpec:Object = null, friendTabOrder:Array = null, assetSwf:String = null)
      {
         if(friendSpec == null)
         {
            friendSpec = {"NO_TABS":[MFSConstants.NO_TABS]};
         }
         super(friendSpec,friendTabOrder,giftItem,completeCallback,mfsType,source,this.getStatsFlowName(),assetSwf);
         this.m_limitFriends = limitFriends;
         this.m_giftsToggleManager = new ZwToggleManager();
      }
      
      protected function addGiftSelector(giftItems:Array) : void
      {
         var slotName:String = null;
         var radioFrame:MFSFreeGiftsRadioButtonFrame = null;
         var sendGiftsFrame:ZwFrame = new ZwFrame(m_window.mc_sendgifts);
         for(var giftCount:int = 0; giftCount < giftItems.length; giftCount++)
         {
            slotName = "mc_gift_slot" + giftCount;
            if(!sendGiftsFrame.element.hasOwnProperty(slotName))
            {
               break;
            }
            radioFrame = sendGiftsFrame.addWidget(new MFSFreeGiftsRadioButtonFrame(sendGiftsFrame.element[slotName],giftItems[giftCount],this.onRadioSelected)) as MFSFreeGiftsRadioButtonFrame;
            this.m_giftsToggleManager.addToggle(new ZwToggle(radioFrame.radioButton),giftCount == 0);
         }
         m_cornerWidget = addWidget(sendGiftsFrame) as ZwWidget;
      }
      
      private function onRadioSelected(selectedItem:FarmItem) : void
      {
         if(selectedItem != null)
         {
            m_item = selectedItem;
         }
      }
      
      override protected function getRequestData() : String
      {
         var requestData:Array = [];
         m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_GIFT);
         requestData.push(m_item.code);
         requestData.push(m_serverTime);
         requestData.push(m_source);
         requestData.push(MFSConstants.VALUE_NOT_SET);
         requestData.push(MFSConstants.VALUE_NOT_SET);
         requestData.push(MFSConstants.GAME_NAME_FARMVILLE);
         requestData.push(MFSConstants.IS_WISH);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      override protected function getRequestMessage(currentTabName:String) : String
      {
         return ZLocUtils.t_pk("Gifts","request_text_nodate",{
            "GIFT_NAME":m_item.friendlyTitle,
            "APP_NAME":MFSConstants.GAME_NAME_FARMVILLE
         });
      }
      
      override protected function getRequestTitle() : String
      {
         return ZLocUtils.t_pk("Gifts","GiftRequestTitle");
      }
      
      override protected function addWindowSubtitle() : void
      {
      }
      
      override protected function getProgressBarText(sentCount:int, friendCount:int) : String
      {
         var result:String = ZLocUtils.t("Dialogs","mfs_Progress_generic",{
            "sentCount":sentCount,
            "friendCount":friendCount
         });
         if(ZLocUtils.hasString("Dialogs",m_MFSTypeString + "_Progress"))
         {
            result = ZLocUtils.t("Dialogs",m_MFSTypeString + "_Progress",{
               "sentCount":sentCount,
               "friendCount":friendCount
            });
         }
         return result;
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         throw new Error(ABSTRACT_CLASS_ERROR);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         throw new Error(ABSTRACT_CLASS_ERROR);
      }
      
      protected function getStatsFlowName() : String
      {
         throw new Error(ABSTRACT_CLASS_ERROR);
      }
      
      protected function setFeedInterstitialExperiment(flowName:String) : void
      {
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FEED_INTERSTITIAL);
         switch(variant)
         {
            case 0:
            case 1:
               break;
            case 2:
               m_feedDialogQueued = true;
               m_feedStatsFlowName = flowName + "_feed";
               break;
            case 3:
               m_showFeedDialog = true;
               m_feedStatsFlowName = "feed_" + flowName;
         }
      }
      
      override protected function switchFromFeedToMFS() : void
      {
         m_item = m_cachedItem;
         m_cornerWidget.visible = false;
         m_shareButton.visible = false;
         m_noFriendsClip.visible = false;
         m_loadingSpinner.visible = true;
         this.m_altCornerWidget.visible = true;
         m_descriptionTextField.text = ZLocUtils.t("Dialogs",m_MFSTypeString + "_Loading");
         m_titleTextField.text = ZLocUtils.t("Dialogs",m_MFSTypeString + "_Title");
      }
      
      protected function switchFromMFSToFeedHelper() : void
      {
         FarmStatsManager.count(m_source,m_feedStatsFlowName,"dialog_impression");
         m_descriptionTextField.text = ZLocUtils.t("Dialogs",m_MFSTypeString + "_FeedMessage");
         if(m_MFSDialogQueued)
         {
            m_titleTextField.text = ZLocUtils.t("Dialogs",m_MFSTypeString + "_FeedTitle");
            m_windowBgTextField.text = ZLocUtils.t("Dialogs",m_MFSTypeString + "_FeedDescription");
         }
         else
         {
            m_titleTextField.text = ZLocUtils.t("Dialogs",m_MFSTypeString + "_FeedAfterMFSTitle");
            m_windowBgTextField.text = ZLocUtils.t("Dialogs",m_MFSTypeString + "_FeedAfterMFSDescription",{"sentCount":m_numItemsSentTotal});
         }
         m_loadingSpinner.visible = false;
         m_progressAnimation.visible = false;
         m_progressBar.visible = false;
         m_progressMeter.visible = false;
         m_progressTextField.visible = false;
         m_sendButton.visible = false;
         m_friendsSlotFrame.visible = false;
         setVisibleChild(m_nextButton,false);
         setVisibleChild(m_backButton,false);
         setVisibleChild(m_selectAllCheckBox,false);
         m_cornerWidget.visible = false;
         m_noFriendsClip.visible = true;
         m_shareButton.visible = true;
         this.m_altCornerWidget = m_cornerWidget;
         m_cachedItem = m_item;
         if(m_tabOneButton != null)
         {
            m_tabOneButton.visible = false;
         }
         if(m_tabTwoButton != null)
         {
            m_tabTwoButton.visible = false;
         }
         if(m_tabThreeButton != null)
         {
            m_tabThreeButton.visible = false;
         }
         if(m_tabFourButton != null)
         {
            m_tabFourButton.visible = false;
         }
         if(m_tabFiveButton != null)
         {
            m_tabFiveButton.visible = false;
         }
      }
   }
}


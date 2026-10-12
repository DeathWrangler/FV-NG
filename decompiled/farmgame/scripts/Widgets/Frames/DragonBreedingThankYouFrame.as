package Widgets.Frames
{
   import Classes.Constants.MFSConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.DragonBreedingManager;
   import Managers.FarmStatsManager;
   import Managers.Requests2Manager;
   import Managers.ToasterManager;
   import Transactions.TSendRequest2Gifts;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.CustomFreeGiftSelectionWindow;
   import Widgets.Windows.FeedPostCompleteToasterWindow;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class DragonBreedingThankYouFrame extends FarmSlotContainerFrame
   {
      
      private var m_thank_tf:FarmTextField;
      
      private var m_ignore_bt:FarmAnimatedTextButton;
      
      private var m_share_bt:FarmAnimatedTextButton;
      
      private var THANK_TEXT:String = "thank_tf";
      
      private var IGNORE_BUTTON:String = "nothanks_bt";
      
      private var THANK_BUTTON:String = "thanks_bt";
      
      private var m_senderId:String;
      
      private var m_maleSenderId:String;
      
      private var m_femaleSenderId:String;
      
      private var m_featureName:String;
      
      private var m_requestSentServerTime:Number;
      
      private var m_item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(DragonBreedingManager.LOVE_POTION_ITEM_CODE);
      
      public function DragonBreedingThankYouFrame(element:DisplayObject, featureName:String, senderId:String)
      {
         this.m_senderId = senderId;
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty(this.THANK_TEXT))
         {
            this.m_thank_tf = addWidget(new FarmTextField(m_element[this.THANK_TEXT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"dragon_pen_finished_thank_you_card")),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty(this.IGNORE_BUTTON))
         {
            this.m_ignore_bt = addWidget(new FarmAnimatedTextButton(m_element[this.IGNORE_BUTTON],"Ignore",this.onIgnoreClick),true) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty(this.THANK_BUTTON))
         {
            this.m_share_bt = addWidget(new FarmAnimatedTextButton(m_element[this.THANK_BUTTON],"Send Herb",this.onSendHerbClick),true) as FarmAnimatedTextButton;
         }
      }
      
      public function set maleSenderId(value:String) : void
      {
         this.m_maleSenderId = value;
      }
      
      public function set femaleSenderId(value:String) : void
      {
         this.m_femaleSenderId = value;
      }
      
      public function set senderId(value:String) : void
      {
         this.m_senderId = value;
      }
      
      private function onIgnoreClick(event:Event) : void
      {
         if(Boolean(this.m_maleSenderId) && Boolean(this.m_femaleSenderId))
         {
            this.visible = false;
            this.m_maleSenderId = "";
            this.m_senderId = this.m_femaleSenderId;
            this.visible = true;
         }
         else
         {
            this.hide();
         }
         FarmStatsManager.count(this.m_featureName,"vd_response","ignore");
      }
      
      private function onSendHerbClick(event:Event) : void
      {
         var requestText:String = ZLocUtils.t_pk("Gifts","request_text_nodate",{
            "GIFT_NAME":this.m_item.friendlyTitle,
            "APP_NAME":MFSConstants.GAME_NAME_FARMVILLE
         });
         var requestTitle:String = ZLocUtils.t_pk("Gifts","GiftRequestTitle");
         var requestData:String = this.getRequestData();
         if(Boolean(this.m_maleSenderId) && Boolean(this.m_femaleSenderId))
         {
            this.m_senderId = this.m_maleSenderId;
            Requests2Manager.sendGift(requestData,requestText,requestTitle,[this.m_senderId.toString()],"free_gift_selection",this.fbResponse);
            this.m_senderId = this.m_femaleSenderId;
         }
         else
         {
            if(Boolean(this.m_maleSenderId) && this.m_maleSenderId != "")
            {
               this.m_senderId = this.m_maleSenderId;
            }
            if(Boolean(this.m_femaleSenderId) && this.m_femaleSenderId != "")
            {
               this.m_senderId = this.m_femaleSenderId;
            }
            Requests2Manager.sendGift(requestData,requestText,requestTitle,[this.m_senderId.toString()],"free_gift_selection",this.fbResponse);
         }
      }
      
      private function getRequestData() : String
      {
         var requestData:Array = [];
         this.m_requestSentServerTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_GIFT);
         requestData.push(this.m_item.code);
         requestData.push(this.m_requestSentServerTime);
         requestData.push("free_gift_selection");
         requestData.push(MFSConstants.VALUE_NOT_SET);
         requestData.push(MFSConstants.VALUE_NOT_SET);
         requestData.push(MFSConstants.GAME_NAME_FARMVILLE);
         requestData.push(MFSConstants.IS_WISH);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      private function fbResponse(response:Object) : void
      {
         var requestIds:Array = response["request_ids"] as Array;
         if(Boolean(requestIds) && requestIds.length > 0)
         {
            TransactionManager.addTransaction(new TSendRequest2Gifts(this.m_item.code,requestIds,CustomFreeGiftSelectionWindow.SEND_FREE_GIFT,"free_gift_selection",this.m_requestSentServerTime,function(result:Object):void
            {
               ToasterManager.getInstance().add(new FeedPostCompleteToasterWindow(ZLocUtils.t("Dialogs","GiftSent"),m_item.iconUrl,new Point(0,0)));
            }),true);
            if(Boolean(this.m_maleSenderId) && Boolean(this.m_femaleSenderId))
            {
               this.m_maleSenderId = null;
               this.visible = false;
            }
            else
            {
               this.hide();
            }
         }
         FarmStatsManager.count(this.m_featureName,"vd_response","thankyou");
      }
      
      private function hide() : void
      {
         this.visible = false;
         DragonBreedingManager.getInstance(this.m_featureName).saveSessionForThankYouCard(null);
      }
   }
}


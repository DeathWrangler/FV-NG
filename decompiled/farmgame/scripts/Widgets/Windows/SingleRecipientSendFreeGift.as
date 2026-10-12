package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TSendRequest2Gifts;
   import com.adobe.serialization.json.JSON;
   import flash.external.ExternalInterface;
   
   public class SingleRecipientSendFreeGift
   {
      
      protected var m_recipientId:String = "";
      
      protected var m_item:FarmItem = null;
      
      protected var m_source:String = "";
      
      protected var m_ref:String = "";
      
      protected var m_requestMessage:String = "";
      
      protected var m_serverTime:int = 0;
      
      public function SingleRecipientSendFreeGift(recipientId:String, giftItem:FarmItem, source:String, requestMessage:String = "")
      {
         super();
         this.m_item = giftItem;
         this.m_source = source;
         this.m_recipientId = recipientId;
         this.m_requestMessage = requestMessage;
         this.m_ref = CustomFreeGiftSelectionWindow.SEND_FREE_GIFT;
      }
      
      protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendRequest2Gifts(this.m_item.code,requestIds,this.m_ref,this.getStatsFlowName(),this.m_serverTime),true);
      }
      
      protected function getStatsFlowName() : String
      {
         return this.m_source;
      }
      
      protected function getRequestTitle() : String
      {
         return ZLocUtils.t_pk("Gifts","GiftRequestTitle");
      }
      
      public function sendRequest() : void
      {
         var uids:Array = null;
         var requestData:String = null;
         var requestMessage:String = null;
         var requestTitle:String = null;
         if(ExternalInterface.available)
         {
            uids = [this.m_recipientId];
            requestData = this.getRequestData();
            requestMessage = this.getRequestMessage();
            requestTitle = this.getRequestTitle();
            ExternalInterface.addCallback("fbresponseHandler",this.fbResponseHandler);
            ExternalInterface.call("FarmNS.Request2Manager.sendRequestsFromFlash",requestData,requestMessage,requestTitle,uids,this.m_source);
         }
      }
      
      public function fbResponseHandler(response:Object) : void
      {
         var requestIds:Array = null;
         if(Boolean(response) && response.hasOwnProperty("request_ids"))
         {
            requestIds = response["request_ids"] as Array;
            if(Boolean(requestIds) && requestIds.length > 0)
            {
               this.fbResponseAction(requestIds);
            }
         }
      }
      
      protected function getRequestMessage() : String
      {
         return this.m_requestMessage;
      }
      
      protected function getRequestData() : String
      {
         var requestData:Array = [];
         this.m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_GIFT);
         requestData.push(this.m_item.code);
         requestData.push(this.m_serverTime);
         requestData.push(this.m_source);
         requestData.push(MFSConstants.VALUE_NOT_SET);
         requestData.push(MFSConstants.VALUE_NOT_SET);
         requestData.push(MFSConstants.GAME_NAME_FARMVILLE);
         requestData.push(MFSConstants.IS_WISH);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
   }
}


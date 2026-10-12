package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetSendFlashGiftFriends;
   import Transactions.TSendRequest2Gifts;
   import com.adobe.serialization.json.JSON;
   
   public class MFSSendFlashGifts extends MFSWindow
   {
      
      public static const REF_FLASH_GIFT:String = "flashGiftHUD";
      
      private static const TTL_ONE_DAY:int = 86400;
      
      public static const MFS_TYPE:String = "MFSSendFlashGifts";
      
      private var m_featureName:String;
      
      public function MFSSendFlashGifts(friendSpec:Object, friendTabOrder:Array, giftRequestItem:FarmItem, featureName:String, source:String, completeCallback:Function)
      {
         m_friendSpec = friendSpec;
         this.m_featureName = featureName;
         m_requestItem = giftRequestItem;
         super(m_friendSpec,friendTabOrder,giftRequestItem,completeCallback,MFS_TYPE,source,featureName);
      }
      
      override protected function getRequestData() : String
      {
         var requestData:Array = null;
         requestData = [];
         m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_GIFT);
         requestData.push(m_requestItem.code);
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
         var result:String = null;
         var giftFriendlyName:String = m_requestItem.friendlyName;
         if(ZLocUtils.hasString("Gifts",m_requestItem.name + "_request_text_nodate"))
         {
            result = ZLocUtils.t_pk("Gifts",m_requestItem.name + "_request_text_nodate",{"GIFT_NAME":ZLocUtils.tk_pk(giftFriendlyName)});
         }
         else
         {
            result = ZLocUtils.t_pk("Gifts","request_text_nodate",{
               "GIFT_NAME":ZLocUtils.tk_pk(giftFriendlyName),
               "APP_NAME":ZLocUtils.tk_pk_asTitle("FarmVille:FarmvilleText")
            });
         }
         return result;
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetSendFlashGiftFriends(m_requestItem.name,convertToUniqueValuesArray(m_friendSpec),onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendRequest2Gifts(m_requestItem.code,requestIds,REF_FLASH_GIFT,m_source,m_serverTime),true);
      }
   }
}


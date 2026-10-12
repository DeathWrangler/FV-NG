package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetSendRequestGiftsFriendsList;
   import Transactions.TSendRequest2RequestGifts;
   import com.adobe.serialization.json.JSON;
   
   public class MFSSendRequestGifts extends MFSWindow
   {
      
      protected var m_ref:String = "";
      
      protected var m_featureName:String;
      
      public function MFSSendRequestGifts(giftItem:FarmItem, featureName:String, source:String, completeCallback:Function, ref:String = "free_gifts_full_mfs")
      {
         var friendSpec:Object = {"tabNameRequest":["RequestGifts"]};
         this.m_ref = ref;
         this.m_featureName = featureName;
         super(friendSpec,null,giftItem,completeCallback,"RequestGifts",source,featureName);
      }
      
      override protected function getRequestData() : String
      {
         var requestData:Array = [];
         m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_ASKITEMS);
         requestData.push(this.m_featureName);
         requestData.push(m_item.name);
         requestData.push(m_serverTime);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      override protected function getRequestMessage(currentTabName:String) : String
      {
         var result:String = null;
         var featureFriendlyName:String = "Items:" + this.m_featureName + "_friendlyName";
         var requestTextKey:String = "_request_gift_text";
         if(ZLocUtils.hasString("Gifts",this.m_featureName + requestTextKey))
         {
            result = ZLocUtils.t_pk("Gifts",this.m_featureName + requestTextKey,{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
         }
         else
         {
            result = ZLocUtils.t_pk("Gifts","RequestGifts" + requestTextKey,{
               "item":ZLocUtils.tk_pk(m_item.friendlyName),
               "building":ZLocUtils.tk_pk(featureFriendlyName)
            });
         }
         return result;
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetSendRequestGiftsFriendsList(convertToUniqueValuesArray(friendSpec),m_item.name,onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendRequest2RequestGifts(m_item.name,this.m_featureName,requestIds,m_source,"",m_view,m_serverTime,m_completeCallback),true);
      }
   }
}


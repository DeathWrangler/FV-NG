package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetAskItemFriends;
   import Transactions.TSendAskItemsRequest;
   import com.adobe.serialization.json.JSON;
   
   public class MFSAskItems extends MFSWindow
   {
      
      protected var m_MFSType:String = "MFSAskItems";
      
      protected var m_featureName:String;
      
      public function MFSAskItems(friendSpec:Object, friendTabOrder:Array, requestItem:FarmItem, featureName:String, source:String, completeCallback:Function)
      {
         m_friendSpec = friendSpec;
         this.m_featureName = featureName;
         m_requestItem = requestItem;
         if(!this.m_MFSType)
         {
            this.m_MFSType = "MFSAskItems";
         }
         super(m_friendSpec,friendTabOrder,requestItem,completeCallback,this.m_MFSType,source,featureName);
      }
      
      override protected function getRequestData() : String
      {
         var requestData:Array = null;
         requestData = [];
         m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_ASKITEMS);
         requestData.push(this.m_featureName);
         requestData.push(m_requestItem.name);
         requestData.push(m_serverTime);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      override protected function getRequestMessage(currentTabName:String) : String
      {
         var result:String = null;
         var requestTextKey:String = null;
         var featureFriendlyName:String = "Items:" + this.m_featureName + "_friendlyName";
         if(currentTabName == MFSConstants.TAB_NAME_TRIPLE_PARTS)
         {
            requestTextKey = "_ask_request_text_newuser";
         }
         else if(currentTabName == MFSConstants.TAB_NAME_SINGLE_PARTS)
         {
            requestTextKey = "_ask_request_text_olduser";
         }
         if(requestTextKey == null)
         {
            requestTextKey = "_" + currentTabName;
         }
         if(ZLocUtils.hasString("Gifts",this.m_featureName + requestTextKey))
         {
            result = ZLocUtils.t_pk("Gifts",this.m_featureName + requestTextKey,{
               "item":ZLocUtils.tk_pk(m_requestItem.friendlyName),
               "APP_NAME":ZLocUtils.tk_pk_asTitle("FarmVille:FarmvilleText")
            });
         }
         else
         {
            result = ZLocUtils.t_pk("Gifts","R4R" + requestTextKey,{
               "item":ZLocUtils.tk_pk(m_requestItem.friendlyName),
               "building":ZLocUtils.tk_pk(featureFriendlyName),
               "APP_NAME":ZLocUtils.tk_pk_asTitle("FarmVille:FarmvilleText")
            });
         }
         return result;
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetAskItemFriends(MFSConstants.FB_REQ2_REQUESTTYPE_ASKITEMS,this.m_featureName,m_requestItem.name,convertToUniqueValuesArray(m_friendSpec),onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendAskItemsRequest(m_requestItem.name,this.m_featureName,requestIds,m_source,"",m_view,m_serverTime,m_completeCallback),true);
      }
   }
}


package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetAskItemFriends;
   import Transactions.TSendAskMatsRequest;
   import com.adobe.serialization.json.JSON;
   
   public class MFSAskMats extends MFSWindow
   {
      
      public static const MFS_TYPE:String = "MFSAskMats";
      
      private var m_featureName:String;
      
      public function MFSAskMats(friendSpec:Object, friendTabOrder:Array, requestItem:FarmItem, featureName:String, source:String, completeCallback:Function)
      {
         this.m_featureName = featureName;
         m_requestItem = requestItem;
         m_friendSpec = friendSpec;
         super(friendSpec,friendTabOrder,requestItem,completeCallback,MFS_TYPE,source,featureName);
      }
      
      override protected function getRequestData() : String
      {
         var requestData:Array = [];
         m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_ASKMATS);
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
         TransactionManager.addTransaction(new TGetAskItemFriends(MFSConstants.FB_REQ2_REQUESTTYPE_ASKMATS,this.m_featureName,m_requestItem.name,convertToUniqueValuesArray(m_friendSpec),onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendAskMatsRequest(m_requestItem.name,this.m_featureName,requestIds,m_source,"",m_view,m_serverTime,m_completeCallback),true);
      }
   }
}


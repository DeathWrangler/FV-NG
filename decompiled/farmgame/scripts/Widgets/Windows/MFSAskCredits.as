package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.RewardCreditsBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetAskItemFriends;
   import Transactions.TSendAskCreditsRequest;
   import com.adobe.serialization.json.JSON;
   
   public class MFSAskCredits extends MFSWindow
   {
      
      public static const MFS_TYPE:String = "MFSAskCredits";
      
      private var m_featureName:String;
      
      public function MFSAskCredits(friendSpec:Object, friendTabOrder:Array, requestItem:FarmItem, featureName:String, source:String, completeCallback:Function)
      {
         m_friendSpec = friendSpec;
         this.m_featureName = featureName;
         m_requestItem = requestItem;
         super(m_friendSpec,friendTabOrder,requestItem,completeCallback,MFS_TYPE,source,featureName);
      }
      
      override protected function getRequestData() : String
      {
         var requestData:Array = [];
         m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_ASKCREDITS);
         requestData.push(this.m_featureName);
         requestData.push(m_requestItem.name);
         requestData.push(m_serverTime);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      override protected function getRequestMessage(currentTabName:String) : String
      {
         var result:String = null;
         var requestTextKey:String = null;
         if(currentTabName == MFSConstants.TAB_NAME_TRIPLE_PARTS)
         {
            requestTextKey = "_ask_request_text_newuser";
         }
         else if(currentTabName == MFSConstants.TAB_NAME_SINGLE_PARTS)
         {
            requestTextKey = "_ask_request_text_olduser";
         }
         var strPK:String = RewardCreditsBuilding.getLocalizedKey(this.m_featureName,requestTextKey);
         var itemPK:String = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_featureName);
         var itemFriendlyName:String = m_requestItem.friendlyName;
         if(strPK.length > 0 && ZLocUtils.hasString(strPK))
         {
            if(itemPK.length > 0 && ZLocUtils.isObject(itemPK))
            {
               result = ZLocUtils.t_pk(strPK,"",{
                  "item":ZLocUtils.tk_pk(itemPK),
                  "item_same":ZLocUtils.tk_pk(itemPK),
                  "APP_NAME":ZLocUtils.tk_pk_asTitle("FarmVille:FarmvilleText")
               });
            }
            else if(itemFriendlyName.length > 0 && ZLocUtils.isObject(itemFriendlyName))
            {
               result = ZLocUtils.t_pk(strPK,"",{
                  "item":ZLocUtils.tk_pk(itemFriendlyName),
                  "item_same":ZLocUtils.tk_pk(itemFriendlyName),
                  "APP_NAME":ZLocUtils.tk_pk_asTitle("FarmVille:FarmvilleText")
               });
            }
            else
            {
               result = ZLocUtils.t_pk(strPK);
            }
         }
         return result;
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetAskItemFriends(MFSConstants.FB_REQ2_REQUESTTYPE_ASKCREDITS,this.m_featureName,m_requestItem.name,convertToUniqueValuesArray(m_friendSpec),onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendAskCreditsRequest(m_requestItem.name,this.m_featureName,requestIds,m_source,"",m_view,m_serverTime,m_completeCallback),true);
      }
   }
}


package Transactions.Voting
{
   import Engine.Transactions.TPublishUserAction;
   
   public class TAskForVotePublish extends TPublishUserAction
   {
      
      protected var m_onFailure:Function;
      
      protected var m_onSuccess:Function;
      
      public function TAskForVotePublish(action:String, bundleData:Object, targetIds:Array, oneLine:Boolean, onSuccess:Function, onFailure:Function)
      {
         this.m_onFailure = onFailure;
         this.m_onSuccess = onSuccess;
         super(action,bundleData,targetIds,oneLine,null,0,false,false,"");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.published))
         {
            GlobalEngine.socialNetwork.feedPostConfirmation(result);
            this.m_onSuccess();
         }
         else if(Boolean(result) && Boolean(result.shareAsLink))
         {
            GlobalEngine.socialNetwork.shareAsLink(result);
         }
         else if(Boolean(result.showFeedDialog) && m_oneLine == false)
         {
            if(m_askPermissions && !GlobalEngine.socialNetwork.userHasStreamPermissions())
            {
               GlobalEngine.socialNetwork.showStreamPermissions(onFinishStreamPermissions);
            }
            else
            {
               m_category = result.category;
               m_subcategory = result.subcategory;
               m_creative = result.creative;
               this.streamPublish();
            }
         }
      }
      
      override protected function streamPublish() : void
      {
         var targetId:String = null;
         if(m_strTargetIds.length > 0)
         {
            targetId = m_strTargetIds[0].toString();
         }
         var d:Object = new Object();
         d.attachment = m_rawResult.data.attachment;
         d.actionLink = m_rawResult.data.actionLink;
         d.userMessagePrompt = m_rawResult.data.userMessagePrompt;
         d.showFeedDialog = true;
         GlobalEngine.socialNetwork.streamPublishV2(d,this.handleStreamCallback);
      }
      
      protected function handleStreamCallback(data:Object) : void
      {
         if(data.hasOwnProperty("postId") && (data["postId"] == "undefined" && !(data.hasOwnProperty("result") && data["result"] == "posted")))
         {
            this.m_onFailure();
         }
         else
         {
            this.m_onSuccess();
         }
      }
   }
}


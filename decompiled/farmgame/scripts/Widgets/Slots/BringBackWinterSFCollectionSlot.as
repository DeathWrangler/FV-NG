package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Managers.BringBackWinterManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import by.blooddy.crypto.MD5;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   
   public class BringBackWinterSFCollectionSlot extends ZwFrame
   {
      
      private static const X:String = "x";
      
      private var m_sfType:String;
      
      private var m_sfItemCode:String;
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private var rewardcount_tf:FarmTextField;
      
      private var m_postBtn:FarmAnimatedTextButton;
      
      private var m_timeRequestedAt:String;
      
      public function BringBackWinterSFCollectionSlot(element:DisplayObject, featureName:String, sfType:String)
      {
         var timeRemaining:Array = null;
         super(element);
         this.m_sfType = sfType;
         this.m_featureName = featureName;
         var itemName:String = BringBackWinterManager.getSfTypeToItemName(this.m_sfType);
         this.m_sfItemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
         if(element.hasOwnProperty("rewardcount_tf"))
         {
            addWidget(this.rewardcount_tf = new FarmTextField(element["rewardcount_tf"],X + this.getSfCollectionCount()),true) as FarmTextField;
         }
         if(element.hasOwnProperty("post_mc") && !BringBackWinterManager.getInstance(this.m_featureName).isFeatureEnd())
         {
            addWidget(this.m_postBtn = new FarmAnimatedTextButton(element["post_mc"],ZLocUtils.t("Dialogs","Ask"),this.onPostSnowFlake));
            if(BringBackWinterManager.getInstance(this.m_featureName).canPostSnowFlake(this.m_sfItemCode))
            {
               this.m_postBtn.enabled = true;
            }
            else
            {
               this.disableAskButton();
            }
         }
         else if(!BringBackWinterManager.getInstance(this.m_featureName).isFeatureEnd())
         {
            timeRemaining = BringBackWinterManager.getInstance(this.m_featureName).timeForNextDailyCollect();
            if(element.hasOwnProperty("timeleft_tf"))
            {
               addWidget(new FarmTextField(element["timeleft_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"pinksnowflake_timeleft",{
                  "hrs":timeRemaining[1],
                  "min":FarmGameUtil.numberToStringPadZeros(timeRemaining[2])
               })),true);
               this.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"pinksnowflake_tooltip")));
            }
         }
      }
      
      private function onPostSnowFlake(event:Event) : void
      {
         if(!BringBackWinterManager.getInstance(this.m_featureName).isFeatureEnd())
         {
            BringBackWinterManager.getInstance(this.m_featureName).postSf(this.m_sfItemCode,this.postFeed);
            this.m_postBtn.enabled = false;
         }
      }
      
      private function getSfCollectionCount() : int
      {
         return BringBackWinterManager.getInstance(this.m_featureName).getSfCollectionCount(this.m_sfType);
      }
      
      public function refreshCollectionCount() : void
      {
         if(this.rewardcount_tf)
         {
            this.rewardcount_tf.text = X + this.getSfCollectionCount();
         }
      }
      
      private function postFeed(result:Object) : void
      {
         var callBackName:String = null;
         var data:Object = result.data;
         var actionCountKey:String = BringBackWinterManager.getInstance(this.m_featureName).getActionCountKey(result.itemCode);
         if(Boolean(data) && Boolean(data.showFeedDialog))
         {
            if(Boolean(data.attachment) && Boolean(data.actionLink) && Boolean(data.userMessagePrompt))
            {
               this.m_timeRequestedAt = result.ts;
               callBackName = "feedPostCallback";
               try
               {
                  callBackName = "feedPostCallback_" + MD5.hash(data.actionLink[0].href);
               }
               catch(error:Error)
               {
               }
               ExternalInterface.addCallback(callBackName,this.feedPostCallback);
               GlobalEngine.socialNetwork.streamPublish(data.attachment,data.actionLink,null,data.userMessagePrompt);
            }
            else if(Config.DEBUG_MODE)
            {
               ErrorManager.addError("UserMessagePrompt, actionLink or attachment is missing for: " + actionCountKey);
            }
         }
         else if(Boolean(data) && Boolean(data.published))
         {
            BringBackWinterManager.getInstance(this.m_featureName).registerFeedPublishSuccess(this.m_sfItemCode);
            GlobalEngine.socialNetwork.feedPostConfirmation(data);
         }
      }
      
      public function feedPostCallback(result:Object) : void
      {
         var postSuccess:Boolean = false;
         if(Boolean(result.result) && Boolean(result.postId) && Boolean(result.callBackName))
         {
            if(result.result == "posted")
            {
               TransactionManager.addTransaction(new TGenericTransaction(BringBackWinterManager.SERVICE_CLASS,BringBackWinterManager.ACTION_RECORD_SNOWFLAKE_ITEM_REQUEST,null,[this.m_sfItemCode,this.m_timeRequestedAt]));
               BringBackWinterManager.getInstance(this.m_featureName).registerFeedPublishSuccess(this.m_sfItemCode);
            }
            postSuccess = true;
            ExternalInterface.addCallback(result.callBackName,null);
         }
      }
      
      private function disableAskButton() : void
      {
         var timeRemaining:Array = null;
         if(this.m_postBtn)
         {
            this.m_postBtn.enabled = false;
            this.m_postBtn.setToggleMode(ZwToggleMode.SINGLE_SELECT);
            this.m_postBtn.setToggleState(ZwToggleState.SELECTED);
            this.m_postBtn.applyGrayOut = true;
            this.m_postBtn.element.buttonMode = false;
            timeRemaining = BringBackWinterManager.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled(this.m_sfItemCode);
            this.m_postBtn.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
               "hrs":timeRemaining[1],
               "min":timeRemaining[2]
            })));
         }
      }
   }
}


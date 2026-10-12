package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.events.Event;
   
   public class XMASRedeemRewardWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const ICON_MC:String = "icon_mc";
      
      private const ITEM_TF:String = "item_tf";
      
      private const ACCEPT_BT:String = "accept_bt";
      
      private const TEXT_TITLE:String = "_RedeemWindow_Title";
      
      private const TEXT_BODY:String = "_RedeemWindow_Body";
      
      private const TEXT_ACCEPT_BUTTON:String = "_RedeemWindow_Button_Text";
      
      private var m_featureName:String = null;
      
      private var m_rewardItem:FarmItem = null;
      
      private var m_callBackOnClose:Function = null;
      
      public function XMASRedeemRewardWindow(assetPath:String, featureName:String, rewardItem:FarmItem, callBackOnClose:Function = null)
      {
         this.m_featureName = featureName;
         this.m_rewardItem = rewardItem;
         this.m_callBackOnClose = callBackOnClose;
         super(assetPath,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var desc:ZwTextField = null;
         var itemPreview:ObjectPreviewFrame = null;
         var acceptBt:FarmAnimatedTextButton = null;
         var itemDesc:ZwTextField = null;
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window.hasOwnProperty(this.TITLE_TF))
            {
               desc = new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE));
               addWidget(desc,true);
            }
            if(m_window.hasOwnProperty(this.ICON_MC))
            {
               itemPreview = new ObjectPreviewFrame(m_window[this.ICON_MC],this.m_rewardItem,null,null,[200]);
               addWidget(itemPreview,true);
            }
            if(m_window.hasOwnProperty(this.ACCEPT_BT))
            {
               acceptBt = new FarmAnimatedTextButton(m_window[this.ACCEPT_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_ACCEPT_BUTTON),this.onAccept);
               addWidget(acceptBt,true);
            }
            if(m_window.hasOwnProperty(this.ITEM_TF))
            {
               itemDesc = new ZwTextField(m_window[this.ITEM_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY,{"reward":this.m_rewardItem.friendlyTitle}));
               addWidget(itemDesc,true);
            }
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      private function onAccept(event:Event) : void
      {
         this.onClose(event);
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
   }
}


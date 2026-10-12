package Widgets.Windows.Subscriptions
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class SubscriptionsClickTestPopUp extends FarmWindow
   {
      
      private var m_okButton:FarmAnimatedTextButton;
      
      private var m_noButton:FarmAnimatedTextButton;
      
      private var m_closeCallBack:Function;
      
      public function SubscriptionsClickTestPopUp(dialogAsset:String, closeCallBack:Function = null)
      {
         super(dialogAsset);
         this.m_closeCallBack = closeCallBack;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(this.m_okButton = new FarmAnimatedTextButton(m_window.no_btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Interested"),this.onOkButtonClicked),true);
         addWidget(this.m_noButton = new FarmAnimatedTextButton(m_window.yes_btn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"NotInterested"),this.onNoButtonClicked),true);
         this.m_okButton.visible = true;
         this.m_noButton.visible = true;
      }
      
      private function onOkButtonClicked(event:Event) : void
      {
         this.callCallBack(true);
         this.onClose(event);
      }
      
      private function onNoButtonClicked(event:Event) : void
      {
         this.callCallBack(false);
         this.onClose(event);
      }
      
      override protected function release() : void
      {
         this.m_okButton = null;
         this.m_noButton = null;
         super.release();
      }
      
      private function callCallBack(okClicked:Boolean) : void
      {
         if(this.m_closeCallBack != null)
         {
            this.m_closeCallBack(okClicked);
            this.m_closeCallBack = null;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
   }
}


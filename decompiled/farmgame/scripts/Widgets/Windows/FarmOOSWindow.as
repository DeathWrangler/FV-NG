package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class FarmOOSWindow extends FarmWindow
   {
      
      public static const ASSET_DETAILS:String = "assets/dialogs/FV_OOSPopUp.swf";
      
      private var m_acceptCallback:Function = null;
      
      private var m_cancelCallback:Function = null;
      
      private var m_showMultipleIntanceMessage:Boolean = false;
      
      public function FarmOOSWindow(acceptCallback:Function = null, cancelCallback:Function = null, showMultipleIntanceMessage:Boolean = false)
      {
         super(ASSET_DETAILS,true);
         this.m_acceptCallback = acceptCallback;
         this.m_cancelCallback = cancelCallback;
         this.m_showMultipleIntanceMessage = showMultipleIntanceMessage;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.accept_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("FarmGame","OK"),this.acceptPrompt));
         }
         if(m_window.cancel_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t("Dialogs","FarmOOSWindow_noReloadMessage"),this.cancelPrompt));
         }
         if(m_window.link_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.link_bt,ZLocUtils.t("Dialogs","FarmOOSWindow_learnMoreButtonText"),this.learnMorePrompt));
         }
         if(m_window.link_tf)
         {
            addWidget(new ZwTextField(m_window.link_tf,ZLocUtils.t("Dialogs","FarmOOSWindow_learnMoreMessage"),true));
         }
         if(this.m_showMultipleIntanceMessage)
         {
            if(m_window.popupBox_tf)
            {
               addWidget(new ZwTextField(m_window.popupBox_tf,ZLocUtils.t("Dialogs","FarmOOSWindow_multipleInstanceMessage")));
            }
         }
         else if(m_window.popupBox_tf)
         {
            addWidget(new ZwTextField(m_window.popupBox_tf,ZLocUtils.t("Dialogs","FarmOOSWindow_mainMessage")));
         }
         if(m_window.title_tf)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","FarmOOSWindow_Title")));
         }
      }
      
      private function acceptPrompt(event:Event) : void
      {
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback();
         }
         super.onClose(event);
      }
      
      private function cancelPrompt(event:Event) : void
      {
         if(this.m_cancelCallback != null)
         {
            this.m_cancelCallback();
         }
         super.onClose(event);
      }
      
      private function learnMorePrompt(event:Event) : void
      {
         UI.showMessage(ZLocUtils.t("Dialogs","FarmOOSWindow_details"));
      }
   }
}


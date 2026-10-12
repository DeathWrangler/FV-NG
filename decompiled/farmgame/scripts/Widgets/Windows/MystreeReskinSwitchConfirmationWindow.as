package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class MystreeReskinSwitchConfirmationWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var m_yes_bt:FarmAnimatedButton;
      
      private var m_no_bt:FarmAnimatedButton;
      
      private var m_callBack:Function;
      
      private var m_bodyText:String;
      
      private var m_acceptButtonText:String;
      
      private var m_cancelButtonText:String;
      
      public function MystreeReskinSwitchConfirmationWindow(windowURL:String, featureName:String, callBack:Function = null, bodyText:String = null, acceptButtonText:String = null, cancelButtonText:String = null)
      {
         this.m_featureName = featureName;
         this.m_callBack = callBack;
         this.m_bodyText = bodyText;
         this.m_acceptButtonText = acceptButtonText;
         this.m_cancelButtonText = cancelButtonText;
         super(windowURL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.body_tf)
         {
            addWidget(new ZwTextField(m_window.body_tf,this.m_bodyText));
         }
         if(m_window.yes_bt)
         {
            addWidget(this.m_yes_bt = new FarmAnimatedTextButton(m_window.yes_bt,this.m_acceptButtonText,this.onAccept));
         }
         if(m_window.no_bt)
         {
            if(this.m_cancelButtonText == null)
            {
               this.m_cancelButtonText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Cancel");
            }
            addWidget(this.m_no_bt = new FarmAnimatedTextButton(m_window.no_bt,this.m_cancelButtonText,this.onCancel));
         }
      }
      
      private function onAccept(e:Event) : void
      {
         if(this.m_callBack != null)
         {
            this.m_callBack();
         }
         close();
      }
      
      private function onCancel(e:Event) : void
      {
         close();
      }
   }
}


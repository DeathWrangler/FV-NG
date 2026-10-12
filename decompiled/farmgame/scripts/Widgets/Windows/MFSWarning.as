package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class MFSWarning extends FarmWindow
   {
      
      private var m_callbackSend:Function;
      
      private var m_callbackContinue:Function;
      
      private var m_continueParamOne:Boolean;
      
      private var m_continueParamTwo:int;
      
      private var m_statsFlowName:String;
      
      private var m_textKey:String = "MFSWarning";
      
      public function MFSWarning(callbackSend:Function, callbackContinue:Function, continueParamOne:Boolean, continueParamTwo:int, statsFlowName:String, displayTextKey:String = "MFSWarning")
      {
         super("assets/dialogs/FV_R4R_alert.swf");
         this.m_callbackSend = callbackSend;
         this.m_callbackContinue = callbackContinue;
         this.m_continueParamOne = continueParamOne;
         this.m_continueParamTwo = continueParamTwo;
         this.m_statsFlowName = statsFlowName;
         this.m_textKey = displayTextKey;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs",this.m_textKey + "_Main"))) as ZwTextField;
         addWidget(new FarmAnimatedTextButton(m_window.bt_cancel,ZLocUtils.t("Dialogs",this.m_textKey + "_Continue"),this.onClickContinue));
         addWidget(new FarmAnimatedTextButton(m_window.bt_sendgifts,ZLocUtils.t("Dialogs",this.m_textKey + "_Send"),this.onClickSend));
         m_window.visible = true;
      }
      
      private function onClickContinue(e:MouseEvent) : void
      {
         if(this.m_callbackContinue != null)
         {
            this.m_callbackContinue(this.m_continueParamOne,this.m_continueParamTwo);
         }
         close();
      }
      
      private function onClickSend(e:MouseEvent) : void
      {
         if(this.m_callbackSend != null)
         {
            this.m_callbackSend();
         }
         close();
      }
   }
}


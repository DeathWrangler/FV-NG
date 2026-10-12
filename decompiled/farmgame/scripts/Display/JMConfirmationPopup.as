package Display
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class JMConfirmationPopup extends GenericPopup
   {
      
      protected var m_counterText:String = "10/10";
      
      protected var m_counter:ZwTextField;
      
      public function JMConfirmationPopup(message:String, type:int = 0, closeCallback:Function = null, dialogAsset:String = "assets/dialogs/FV_GenericPopUp.swf", counterText:String = "", acceptTextKey:String = "Yes", rejectTextKey:String = "No")
      {
         this.m_counterText = counterText;
         setAcceptTextName(acceptTextKey);
         setCancelTextName(rejectTextKey);
         super(message,type,closeCallback,dialogAsset,"",false,false,true);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         if(Boolean(m_window) && Boolean(m_window["counter_tf"]))
         {
            this.m_counter = new ZwTextField(m_window.counter_tf,this.m_counterText);
            this.m_counter.visible = true;
         }
         if(m_reject)
         {
            m_reject.text = ZLocUtils.t("Dialogs","No");
         }
         if(m_accept)
         {
            m_accept.text = ZLocUtils.t("Dialogs","Yes");
         }
      }
   }
}


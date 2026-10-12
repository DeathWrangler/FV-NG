package Display
{
   import Classes.util.ZLocUtils;
   
   public class MiniDartsPopup extends GenericPopup
   {
      
      public function MiniDartsPopup(message:String, type:int = 0, closeCallback:Function = null, dialogAsset:String = "assets/dialogs/FV_GenericPopUp.swf", rewardUrl:String = "", useHtmlText:Boolean = false, bAddClickBlocker:Boolean = false, showX:Boolean = false)
      {
         super(message,type,closeCallback,dialogAsset,rewardUrl,useHtmlText,bAddClickBlocker,showX);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         if(Boolean(m_window) && Boolean(m_window.accept_bt) && Boolean(m_window.accept_bt.generic_tf))
         {
            m_window.accept_bt.generic_tf.text = ZLocUtils.t("Dialogs","minidarts_revamp_finish_cta");
         }
         if(Boolean(m_window) && Boolean(m_window.body_txt))
         {
            m_window.body_txt.text = m_message;
         }
      }
   }
}


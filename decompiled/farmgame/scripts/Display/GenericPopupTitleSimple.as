package Display
{
   import Classes.util.ZLocUtils;
   
   public class GenericPopupTitleSimple extends GenericPopup
   {
      
      protected var m_sTitleTextLocaleToken:String = null;
      
      public function GenericPopupTitleSimple(message:String, sTitleToken:String = "SetTitle", type:int = 0, closeCallback:Function = null, dialogAsset:String = "assets/dialogs/FV_GenPopUpGold.swf", rewardUrl:String = "", useHtmlText:Boolean = false, bAddClickBlocker:Boolean = true)
      {
         this.m_sTitleTextLocaleToken = sTitleToken;
         super(message,type,closeCallback,dialogAsset,rewardUrl,useHtmlText,bAddClickBlocker);
         setAcceptTextName("Okay");
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         if(m_window.popupBox_mc.goldTitle_tf)
         {
            m_window.popupBox_mc.goldTitle_tf.text = ZLocUtils.t("Dialogs",this.m_sTitleTextLocaleToken);
         }
      }
   }
}


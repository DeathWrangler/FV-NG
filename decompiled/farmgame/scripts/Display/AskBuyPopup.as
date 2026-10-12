package Display
{
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import Managers.SmartPopupManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class AskBuyPopup extends GenericIconPopup
   {
      
      public static const ASK:int = 1;
      
      public static const BUY:int = 2;
      
      private const ASKBUY_DIALOG_ASSET:String = "assets/dialogs/FV_GenericPopUp_FV_GenericPopUp_GreenBlueX_btns.swf";
      
      public function AskBuyPopup(message:String, type:int = 6, closeCallback:Function = null, icon:Object = null, disableIconResize:Boolean = false, showX:Boolean = true, additionalText:String = "", useHtmlText:Boolean = false, dialogAsset:String = "assets/dialogs/FV_GenericPopUp_FV_GenericPopUp_GreenBlueX_btns.swf", iconFilter:Array = null, forceSize:Boolean = false)
      {
         super(message,type,closeCallback,icon,disableIconResize,showX,additionalText,useHtmlText,dialogAsset,iconFilter,forceSize);
         if(m_type == GenericPopup.TYPE_ASKBUY)
         {
            m_acceptTextName = "Buy";
            m_cancelTextName = "GenericAsk";
         }
      }
      
      override protected function onLoadComplete() : void
      {
         var rg:TextField = null;
         m_window = m_loader.content as MovieClip;
         hideExtras();
         setMessage();
         if(m_window)
         {
            if(m_window.popupBox_mc)
            {
               if(m_window.popupBox_mc.free_tf)
               {
                  if(m_additionalText != "")
                  {
                     m_window.free_tf.textColor = 16711680;
                     m_window.free_tf.text = m_additionalText;
                     m_window.free_tf.visible = true;
                  }
                  else
                  {
                     m_window.popupBox_mc.free_tf.visible = false;
                  }
               }
            }
         }
         if(m_type == TYPE_ASKBUY)
         {
            if(m_window.popupBox_mc.accept_bt)
            {
               m_window.popupBox_mc.accept_bt.visible = true;
               m_accept = new GenericButton(m_window.popupBox_mc.accept_bt,this.onBuy);
            }
            if(m_window.popupBox_mc.save_bt)
            {
               m_window.popupBox_mc.save_bt.visible = true;
               m_reject = new GenericButton(m_window.popupBox_mc.save_bt,this.onAsk);
               m_reject.text = ZLocUtils.t("Dialogs",m_cancelTextName);
            }
         }
         m_accept.text = ZLocUtils.t("Dialogs",m_acceptTextName);
         setupCloseButton();
         setIcon();
         addChild(m_window);
      }
      
      protected function onAsk(event:MouseEvent) : void
      {
         if(getTrackerEnabled())
         {
            SmartPopupManager.getInstance().popupAccepted(m_trackerKey,m_acceptTextName);
         }
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,ASK));
         close();
      }
      
      protected function onBuy(event:MouseEvent) : void
      {
         if(getTrackerEnabled())
         {
            SmartPopupManager.getInstance().popupAccepted(m_trackerKey,m_cancelTextName);
         }
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BUY));
         close();
      }
   }
}


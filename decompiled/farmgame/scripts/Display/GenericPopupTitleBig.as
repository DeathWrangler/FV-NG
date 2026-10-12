package Display
{
   import Classes.util.ZLocUtils;
   import Events.GenericPopupTitleBigEvent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class GenericPopupTitleBig extends GenericPopupTitle
   {
      
      protected var m_itemName:String;
      
      protected var m_isCashItem:Boolean;
      
      public function GenericPopupTitleBig(title:String, message:String, type:Number, closeCallback:Function = null, dialogAsset:String = "assets/dialogs/FV_Pets_PopUp_Feed.swf", itemName:String = "", isCash:Boolean = false)
      {
         super(title,message,false,type,closeCallback,dialogAsset);
         if(closeCallback != null)
         {
            m_closeCallback = closeCallback;
            addEventListener(GenericPopupTitleBigEvent.SELECTED,closeCallback);
         }
         this.m_itemName = itemName;
         this.m_isCashItem = isCash;
      }
      
      override protected function onLoadComplete() : void
      {
         m_window = m_loader.content as MovieClip;
         this.initDialog();
         addChild(m_window);
      }
      
      private function initDialog() : void
      {
         switch(m_type)
         {
            case TYPE_OK:
               m_window.goldPopUp_mc.ask_bt.visible = false;
               m_window.goldPopUp_mc.cancel_bt.visible = false;
               m_window.goldPopUp_mc.okay_bt.visible = true;
               m_accept = new GenericButton(m_window.goldPopUp_mc.okay_bt,this.onAccept);
               break;
            case TYPE_ACCEPTCANCEL:
               m_window.goldPopUp_mc.ask_bt.visible = true;
               m_window.goldPopUp_mc.cancel_bt.visible = true;
               m_window.goldPopUp_mc.okay_bt.visible = false;
               m_accept = new GenericButton(m_window.goldPopUp_mc.ask_bt,this.onAccept);
               m_accept.text = ZLocUtils.t("Dialogs",m_acceptTextName);
               m_reject = new GenericButton(m_window.goldPopUp_mc.cancel_bt,this.onCancel);
               m_reject.text = ZLocUtils.t("Dialogs",m_cancelTextName);
         }
         ZLocUtils.setText(m_window,"goldPopUp_mc.goldTitle_tf","Dialogs",m_title);
         m_window.goldPopUp_mc.popupBox_tf.text = m_message;
         ZLocUtils.autoFormatSize(m_window.goldPopUp_mc.popupBox_tf);
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupTitleBigEvent(GenericPopupTitleBigEvent.SELECTED,GenericPopup.YES,this.m_itemName));
         if(m_closeCallback != null)
         {
            removeEventListener(GenericPopupTitleBigEvent.SELECTED,m_closeCallback);
         }
         close();
      }
      
      override protected function onCancel(event:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupTitleBigEvent(GenericPopupTitleBigEvent.SELECTED,GenericPopup.NO));
         if(m_closeCallback != null)
         {
            removeEventListener(GenericPopupTitleBigEvent.SELECTED,m_closeCallback);
         }
         close();
      }
   }
}


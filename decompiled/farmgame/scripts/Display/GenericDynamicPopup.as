package Display
{
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import Widgets.View.Dialogs.DataDrivenDialogView;
   import flash.display.Loader;
   import flash.events.Event;
   
   public class GenericDynamicPopup extends Dialog
   {
      
      public static const YES:int = 1;
      
      public static const NO:int = 0;
      
      protected var m_iconLoader:Loader;
      
      protected var m_message:String;
      
      protected var m_closeCallback:Function;
      
      protected var m_accept:GenericButton;
      
      protected var m_reject:GenericButton;
      
      protected var m_acceptTextID:String = "OK";
      
      public function GenericDynamicPopup(sDialogAsset:String, dialogParams:Array, closeCallback:Function = null, nDialogAssetType:Number = 101)
      {
         if(closeCallback != null)
         {
            this.m_closeCallback = closeCallback;
            addEventListener(GenericPopupEvent.SELECTED,closeCallback);
         }
         m_dialogAsset = sDialogAsset;
         super(true,true,nDialogAssetType,dialogParams);
      }
      
      public function setAcceptTextID(acceptTextID:String) : void
      {
         this.m_acceptTextID = acceptTextID;
         if(Boolean(m_window) && Boolean(this.m_accept))
         {
            this.m_accept.text = ZLocUtils.t("Dialogs",this.m_acceptTextID);
         }
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         var data:Array = [];
         var ddd:DataDrivenDialogView = getDataDrivenDialogView();
         if(ddd != null)
         {
            ddd.addEventListener("click_confirm_bt",this.onAccept,false,0,true);
            ddd.addEventListener("click_cancel_bt",this.onCancel,false,0,true);
            ddd.addEventListener("click_xbutton",this.onCancel,false,0,true);
         }
      }
      
      protected function getAcceptButtonText() : String
      {
         var text:String = ZLocUtils.t("Dialogs",this.m_acceptTextID);
         if(this.m_closeCallback == null)
         {
            text = ZLocUtils.t("Dialogs","OkButton");
         }
         return text;
      }
      
      protected function onAccept(event:Event) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,YES));
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         this.close();
      }
      
      protected function onCancel(event:Event) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,NO));
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         this.close();
      }
      
      override public function close() : void
      {
         var ddd:DataDrivenDialogView = getDataDrivenDialogView();
         if(ddd != null)
         {
            ddd.removeEventListener("click_confirm_bt",this.onAccept);
            ddd.removeEventListener("click_cancel_bt",this.onCancel);
            ddd.removeEventListener("click_xbutton",this.onCancel);
         }
         super.close();
      }
   }
}


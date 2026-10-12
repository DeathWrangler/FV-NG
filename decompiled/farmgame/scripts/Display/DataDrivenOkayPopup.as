package Display
{
   import Widgets.View.Dialogs.DataDrivenDialogView;
   import flash.events.Event;
   
   public class DataDrivenOkayPopup extends Dialog
   {
      
      private var m_dialogParams:Array = [];
      
      protected var m_acceptCallback:Function = null;
      
      protected var m_cancelCallback:Function = null;
      
      protected var m_infoCallback:Function = null;
      
      public function DataDrivenOkayPopup(dialogName:String, dialogParameters:Array, acceptCallback:Function = null, cancelCallback:Function = null, infoCallback:Function = null)
      {
         m_dialogAsset = dialogName;
         this.m_acceptCallback = acceptCallback;
         this.m_cancelCallback = cancelCallback;
         this.m_infoCallback = infoCallback;
         super(true,true,Dialog.DIALOG_ASSET_TYPE_DDD,dialogParameters);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         var ddd:DataDrivenDialogView = getDataDrivenDialogView();
         if(ddd != null)
         {
            ddd.addButtonEventListener(GenericXMLDialog.STR_BUTTON_NAME_CONFIRM,this.onAccept);
            ddd.addButtonEventListener(GenericXMLDialog.STR_BUTTON_NAME_XBUTTON,this.onClose);
            ddd.addButtonEventListener(GenericXMLDialog.STR_BUTTON_NAME_CANCEL,this.onClose);
            ddd.addButtonEventListener(GenericXMLDialog.STR_BUTTON_NAME_MOREINFO,this.onMoreInfo);
         }
      }
      
      protected function onAccept(event:Event) : void
      {
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback();
         }
         this.m_acceptCallback = null;
         close();
      }
      
      protected function onClose(event:Event) : void
      {
         if(this.m_cancelCallback != null)
         {
            this.m_cancelCallback();
         }
         this.m_cancelCallback = null;
         close();
      }
      
      protected function onMoreInfo(event:Event) : void
      {
         if(this.m_infoCallback != null)
         {
            this.m_infoCallback();
         }
         this.m_infoCallback = null;
         close();
      }
   }
}


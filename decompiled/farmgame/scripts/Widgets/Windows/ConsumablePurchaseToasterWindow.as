package Widgets.Windows
{
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ConsumablePurchaseToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const CLOSE_CALLBACK_EVENT:String = "ConsumablePurchase_Close";
      
      private static const DEFAULT_TIME_TO_LIVE_MILLISEC:Number = 3000;
      
      protected var m_title:String;
      
      protected var m_itemName:String;
      
      protected var m_clickCallback:Function = null;
      
      protected var m_closeCallback:Function;
      
      public function ConsumablePurchaseToasterWindow(title:String, itemName:String, windowAssetPath:String = "assets/dialogs/FV_postPurchase_Toaster.swf", clickCallback:Function = null, closeCallback:Function = null, toasterTTL:Number = 3000)
      {
         super(windowAssetPath);
         this.m_title = title;
         this.m_itemName = itemName;
         this.m_clickCallback = clickCallback;
         m_timeToLive = toasterTTL;
         if(closeCallback != null)
         {
            this.m_closeCallback = closeCallback;
            addEventListener(CLOSE_CALLBACK_EVENT,this.m_closeCallback);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.title_tf)
         {
            addWidget(new ZwTextField(m_window.title_tf,this.m_title));
         }
         if(m_window.description_tf)
         {
            addWidget(new ZwTextField(m_window.description_tf,this.m_itemName));
         }
         if(this.m_clickCallback != null)
         {
            addEventListener(MouseEvent.CLICK,this.m_clickCallback);
         }
      }
      
      override public function close() : void
      {
         if(this.m_clickCallback != null)
         {
            removeEventListener(MouseEvent.CLICK,this.m_clickCallback);
         }
         if(m_showTween)
         {
            hideTween(function():void
            {
               if(m_closeCallback != null)
               {
                  dispatchEvent(new Event(CLOSE_CALLBACK_EVENT));
                  removeEventListener(CLOSE_CALLBACK_EVENT,m_closeCallback);
               }
               releaseAndDispatchEvent();
            });
            onHide();
         }
         else
         {
            onHide();
            this.releaseAndDispatchEvent();
         }
      }
      
      protected function releaseAndDispatchEvent() : void
      {
         release();
         dispatchEvent(new Event(Event.CLOSE));
      }
   }
}


package Widgets.Windows
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class PurchaseContestToasterWindow extends FeedPostCompleteToasterWindow
   {
      
      private static const DEFAULT_XOFFSET:int = -100;
      
      private const DEFAULT_TIMEOUT:int = 12000;
      
      private const TOASTER_ASSET:String = "assets/dialogs/FV_1000Customer_Toaster.swf";
      
      private var m_callback:Function;
      
      public function PurchaseContestToasterWindow(text:String, iconUrl:String = null, iconOffset:Point = null, callback:Function = null)
      {
         this.m_callback = callback;
         super(text,iconUrl,iconOffset,this.TOASTER_ASSET);
      }
      
      override protected function postLoadComplete() : void
      {
         var frame:ZwFrame = null;
         var icon:FarmIcon = null;
         frame = new ZwFrame(m_window);
         m_timeToLive = this.DEFAULT_TIMEOUT;
         frame.addWidget(new ZwTextField(m_window.body_tf,m_text));
         if(m_iconUrl != null && m_iconUrl != "")
         {
            icon = new FarmIcon(m_window.loader_mc,m_iconUrl);
            icon.setIconSize(55,55);
            frame.addWidget(icon);
         }
         if(m_iconOffset != null)
         {
            m_window.loader_mc.x += m_iconOffset.x;
            m_window.loader_mc.y += m_iconOffset.y;
         }
         m_window.addEventListener(MouseEvent.CLICK,this.onMouseClick);
         addWidget(frame);
      }
      
      override protected function get xOffset() : int
      {
         return DEFAULT_XOFFSET;
      }
      
      private function onMouseClick(evt:MouseEvent) : void
      {
         m_window.removeEventListener(MouseEvent.CLICK,this.onMouseClick);
         close();
         this.postClose();
      }
      
      override protected function postClose() : void
      {
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
   }
}


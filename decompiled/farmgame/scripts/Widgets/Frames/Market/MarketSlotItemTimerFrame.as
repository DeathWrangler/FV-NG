package Widgets.Frames.Market
{
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MarketSlotItemTimerFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 30;
      
      private var m_timerTextField:ZwTextField;
      
      private var m_timerTextTab:ZwWidget;
      
      private var m_icon:FarmIcon;
      
      private var m_mouseOverCallback:Function = null;
      
      private var m_mouseOutCallback:Function = null;
      
      public function MarketSlotItemTimerFrame(element:MovieClip, onMouseOverCallback:Function, onMouseOutCallback:Function)
      {
         super(element);
         this.m_timerTextTab = addWidget(new ZwWidget(m_element.expirationTab_mc)) as ZwWidget;
         this.m_timerTextField = addWidget(new ZwTextField(m_element.expirationTab_mc.timer_tf)) as ZwTextField;
         this.m_icon = addWidget(new FarmIcon(m_element.expireIcon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         m_element.addEventListener(MouseEvent.MOUSE_OVER,onMouseOverCallback,false,0,true);
         m_element.addEventListener(MouseEvent.MOUSE_OUT,onMouseOutCallback,false,0,true);
         this.m_mouseOverCallback = onMouseOverCallback;
         this.m_mouseOutCallback = onMouseOutCallback;
      }
      
      public function set text(value:String) : void
      {
         this.m_timerTextField.text = value;
      }
      
      override public function release() : void
      {
         this.m_timerTextField = null;
         this.m_icon = null;
         this.m_timerTextTab = null;
         m_element.removeEventListener(MouseEvent.MOUSE_OVER,this.m_mouseOverCallback);
         m_element.removeEventListener(MouseEvent.MOUSE_OUT,this.m_mouseOutCallback);
         super.release();
      }
      
      public function loadIcon(iconUrl:String) : void
      {
         this.m_icon.loadIcon(iconUrl);
      }
      
      public function toggleTextVisibility(isVisible:Boolean) : void
      {
         this.m_timerTextTab.visible = isVisible;
      }
      
      public function toggleIconVisibility(isVisible:Boolean) : void
      {
         this.m_icon.visible = isVisible;
      }
   }
}


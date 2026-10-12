package Widgets.Frames
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Base.ZwEventWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.TieredQuestWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   
   public class TieredQuestStageIndicator extends ZwFrame
   {
      
      private var m_generic_tf:FarmTextField;
      
      private var m_icon_mc:FarmIcon;
      
      private var m_lock_mc:ZwWidget;
      
      private var m_taskCompleteIcon:ZwWidget;
      
      private var m_isHighlighted:Boolean;
      
      public function TieredQuestStageIndicator(element:DisplayObject, stage:int, item:FarmItem, parentWindow:TieredQuestWindow)
      {
         var glowFilter:GlowFilter = null;
         super(element);
         if(m_element.hasOwnProperty("generic_tf"))
         {
            this.m_generic_tf = addWidget(new ZwTextField(m_element.generic_tf,String(stage)),true) as FarmTextField;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_icon_mc = addWidget(new FarmIcon(m_element.icon_mc,item.iconUrl),true) as FarmIcon;
            this.m_icon_mc.addEventListener(ZwEventWidget.ICON_PREVIEW_EVENT_LISTENER,this.onIconLoaded);
         }
         if(m_element.hasOwnProperty("lock_mc"))
         {
            this.m_lock_mc = addWidget(new ZwWidget(m_element.lock_mc),true) as ZwWidget;
         }
         if(m_element.hasOwnProperty("completeIcon_mc"))
         {
            this.m_taskCompleteIcon = addWidget(new ZwWidget(m_element.completeIcon_mc),false) as ZwWidget;
            glowFilter = new GlowFilter(16777215,1,2,2,10,5);
            (this.m_taskCompleteIcon.element as DisplayObject).filters = [glowFilter];
         }
      }
      
      public function set locked(value:Boolean) : void
      {
         if(this.m_lock_mc)
         {
            this.m_lock_mc.visible = value;
         }
      }
      
      public function set complete(value:Boolean) : void
      {
         if(this.m_taskCompleteIcon)
         {
            this.m_taskCompleteIcon.visible = value;
         }
      }
      
      public function set currentTaskHighlighted(value:Boolean) : void
      {
         this.m_isHighlighted = value;
      }
      
      private function onIconLoaded(ev:Event) : void
      {
         var glowFilter:GlowFilter = null;
         if(Boolean(this.m_icon_mc) && Boolean(this.m_icon_mc.icon))
         {
            this.m_icon_mc.icon.filters = [];
            if(this.m_isHighlighted)
            {
               glowFilter = new GlowFilter(16763904,1,2,2,10,5);
               this.m_icon_mc.icon.filters = [glowFilter];
            }
         }
      }
      
      override public function release() : void
      {
         if(this.m_icon_mc)
         {
            this.m_icon_mc.removeEventListener(ZwEventWidget.ICON_PREVIEW_EVENT_LISTENER,this.onIconLoaded);
         }
         super.release();
      }
   }
}


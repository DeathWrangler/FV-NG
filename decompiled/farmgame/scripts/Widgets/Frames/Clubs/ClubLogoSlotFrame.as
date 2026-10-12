package Widgets.Frames.Clubs
{
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ClubLogoSlotFrame extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_logo:FarmIcon;
      
      private var m_logoId:String;
      
      private var m_callback:Function = null;
      
      private var m_highlight:ZwWidget = null;
      
      private var m_isSelected:Boolean = false;
      
      public function ClubLogoSlotFrame(element:DisplayObject, callback:Function = null)
      {
         super(element);
         this.m_callback = callback;
         this.m_logo = addWidget(new FarmIcon(m_element.logo_mc)) as FarmIcon;
         this.m_logo.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_highlight = addWidget(new ZwWidget(m_element.selected_mc)) as ZwWidget;
         this.m_highlight.visible = false;
         (m_element as MovieClip).buttonMode = true;
         this.registerEventListener(MouseEvent.CLICK,this.onMouseEvent);
         this.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseEvent);
         this.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseEvent);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_logoId = data.id;
         this.m_logo.loadIcon(FarmClubUtility.getBackgroundLogoPathFromId(parseInt(this.m_logoId)));
         this.m_logo.visible = true;
         this.m_isSelected = false;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_callback = null;
         this.m_highlight = null;
         this.unregisterEventListener(MouseEvent.CLICK,this.onMouseEvent);
         this.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onMouseEvent);
         this.unregisterEventListener(MouseEvent.MOUSE_OUT,this.onMouseEvent);
      }
      
      public function get logoId() : String
      {
         return this.m_logoId;
      }
      
      public function onMouseEvent(event:MouseEvent) : void
      {
         switch(event.type)
         {
            case MouseEvent.CLICK:
               if(this.m_callback != null)
               {
                  this.m_callback(this.m_logoId);
               }
               break;
            case MouseEvent.MOUSE_OVER:
               this.m_highlight.visible = true;
               break;
            case MouseEvent.MOUSE_OUT:
               if(!this.m_isSelected)
               {
                  this.m_highlight.visible = false;
               }
         }
      }
      
      public function highlight(toggle:Boolean) : void
      {
         this.m_isSelected = toggle;
         this.m_highlight.visible = toggle;
      }
   }
}


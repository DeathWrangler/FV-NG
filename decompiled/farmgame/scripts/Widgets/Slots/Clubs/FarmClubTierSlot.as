package Widgets.Slots.Clubs
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Clubs.FarmClubWindow2;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmClubTierSlot extends ZwSlotFrame
   {
      
      private var m_parentWindow:FarmClubWindow2 = null;
      
      private var m_tierNum:int = 0;
      
      private var m_tierNumField:ZwTextField = null;
      
      private var m_itemIcon:FarmIcon = null;
      
      private var m_lockIcon:ZwWidget = null;
      
      private var m_background:ZwWidget = null;
      
      public function FarmClubTierSlot(element:DisplayObject, parentWindow:FarmClubWindow2)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_tierNumField = addWidget(new ZwTextField(m_element.rank_tf)) as ZwTextField;
         this.m_itemIcon = addWidget(new FarmIcon(m_element.clubPic_mc)) as FarmIcon;
         this.m_lockIcon = addWidget(new ZwWidget(m_element.lock_mc)) as ZwWidget;
         this.m_background = addWidget(new ZwWidget(m_element.activeBG_mc)) as ZwWidget;
         (this.m_background.element as MovieClip).gotoAndStop(1);
         this.element.addEventListener(MouseEvent.CLICK,this.onClick);
         this.element.addEventListener(MouseEvent.MOUSE_OVER,this.onMouse);
         this.element.addEventListener(MouseEvent.MOUSE_OUT,this.onMouse);
         this.element.buttonMode = true;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_tierNum = data.tierNum;
         this.m_tierNumField.text = this.m_tierNum.toString();
         this.m_tierNumField.visible = true;
         var tierItem:FarmItem = data.tierItem as FarmItem;
         this.m_itemIcon.loadIcon(tierItem.iconUrl);
         this.m_itemIcon.setIconSize(60,60);
         this.m_itemIcon.visible = true;
         if(!tierItem.canPurchase)
         {
            this.m_lockIcon.visible = true;
         }
         this.m_background.visible = true;
      }
      
      private function onClick(event:MouseEvent) : void
      {
         this.m_parentWindow.onTierSlotClick(this.m_tierNum);
      }
      
      private function onMouse(event:MouseEvent) : void
      {
         if(event.type == MouseEvent.MOUSE_OVER)
         {
            (this.m_background.element as MovieClip).gotoAndStop(2);
         }
         else
         {
            (this.m_background.element as MovieClip).gotoAndStop(1);
         }
      }
   }
}


package Widgets.Slots.LimitedGifting
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class LimitedGiftingItemSlot extends ZwSlotFrame
   {
      
      private var m_checkbox:ZwWidget;
      
      private var m_selected:Boolean = false;
      
      private var m_clickCallback:Function;
      
      private var m_cash:Number = 0;
      
      private var m_itemName:String;
      
      private var m_text:ZwTextField;
      
      private var m_item:FarmItem;
      
      private var m_price_tf:ZwTextField;
      
      private var m_itemPreview:ObjectPreviewFrame;
      
      public function LimitedGiftingItemSlot(element:DisplayObject, clickCallback:Function)
      {
         super(element);
         if(m_element.hasOwnProperty("selected_mc"))
         {
            this.m_checkbox = addWidget(new ZwWidget(m_element.selected_mc)) as ZwWidget;
         }
         this.m_clickCallback = clickCallback;
         (m_element as MovieClip).addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         (m_element as MovieClip).buttonMode = true;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_item = data as FarmItem;
         var sizeScale:Number = Math.min(2,7 / (this.m_item.sizeX + this.m_item.sizeY) / this.m_item.imageScale);
         this.m_itemPreview = new ObjectPreviewFrame(m_element.staticPreview_mc,this.m_item,null,[sizeScale],null,"","",null,new Point(40,45));
         addWidget(this.m_itemPreview);
         this.m_cash = data.cash;
         this.m_price_tf = new ZwTextField(m_element.price_tf,this.m_cash.toString());
         addWidget(this.m_price_tf);
         this.m_itemName = data.name;
         this.m_text = new ZwTextField(m_element.name_tf,data.friendlyTitle);
         addWidget(this.m_text);
      }
      
      private function onClick(evt:MouseEvent) : void
      {
         this.toggleCheckbox();
         if(this.m_clickCallback != null)
         {
            this.m_clickCallback();
         }
      }
      
      private function toggleCheckbox() : void
      {
         if(this.m_checkbox)
         {
            this.m_checkbox.visible = this.m_selected = !this.m_selected;
         }
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      public function set selected(selected:Boolean) : void
      {
         this.m_selected = selected;
         if(this.m_checkbox)
         {
            this.m_checkbox.visible = this.m_selected;
         }
      }
      
      public function get cash() : Number
      {
         return this.m_cash;
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function get item() : FarmItem
      {
         return this.m_item;
      }
      
      override public function release() : void
      {
         this.m_checkbox = null;
         this.m_text = null;
         this.m_price_tf = null;
         this.m_itemPreview = null;
         super.release();
      }
   }
}


package Widgets.Slots
{
   import Classes.EmbeddedArt;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmItemIcon;
   import Widgets.Windows.ScratchCardWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public final class ScratchCardTileSlot extends ZwSlotFrame
   {
      
      protected static const UNINITIALIZED_CURSOR_ID:int = -1;
      
      protected static const START_WIN_ANIM_FRAME:int = 2;
      
      protected static const IDLE_WIN_ANIM_FRAME:int = 1;
      
      protected static const START_SCRATCH_ANIM_FRAME:int = 1;
      
      protected var m_icon:FarmItemIcon = null;
      
      private var m_quantityTf:ZwTextField = null;
      
      private var m_overMc:ZwFrame = null;
      
      private var m_backMc:ZwFrame = null;
      
      private var m_effectMc:ZwFrame = null;
      
      private var m_matchedMc:ZwFrame = null;
      
      private var m_scratchMc:ZwFrame = null;
      
      private var m_data:Object = null;
      
      private var m_cursorId:int = -1;
      
      private var m_callback:Function = null;
      
      public function ScratchCardTileSlot(element:DisplayObject)
      {
         super(element);
         var elementMc:MovieClip = element as MovieClip;
         if(elementMc.icon_mc != null)
         {
            this.m_icon = new FarmItemIcon(this,elementMc.icon_mc as MovieClip);
         }
         if(elementMc.quantity_tf != null)
         {
            this.m_quantityTf = addWidget(new ZwTextField(elementMc.quantity_tf)) as ZwTextField;
         }
         if(elementMc.hit_mc != null)
         {
            (elementMc.hit_mc as MovieClip).addEventListener(MouseEvent.MOUSE_UP,this.onClick);
            (elementMc.hit_mc as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            (elementMc.hit_mc as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
         if(elementMc.over_mc != null)
         {
            this.m_overMc = addWidget(new ZwFrame(elementMc.over_mc)) as ZwFrame;
         }
         if(elementMc.back_mc != null)
         {
            this.m_backMc = addWidget(new ZwFrame(elementMc.back_mc)) as ZwFrame;
         }
         if(elementMc.effect_mc != null)
         {
            this.m_effectMc = addWidget(new ZwFrame(elementMc.effect_mc)) as ZwFrame;
         }
         if(elementMc.scratch_mc != null)
         {
            this.m_scratchMc = addWidget(new ZwFrame(elementMc.scratch_mc)) as ZwFrame;
         }
         if(elementMc.matched_mc != null)
         {
            this.m_matchedMc = addWidget(new ZwFrame(elementMc.matched_mc),false) as ZwFrame;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.m_overMc.visible = true;
         this.m_backMc.visible = true;
         this.populateFields();
      }
      
      protected function populateFields() : void
      {
         var quantity:int = 0;
         quantity = ScratchCardWindow.loadItemIconWithScratchData(this.m_icon,this.m_data,true);
         if(this.m_quantityTf != null)
         {
            if(quantity > 1)
            {
               this.m_quantityTf.text = ZLocUtils.t("Dialogs","GiftAmount",{"quantity":quantity.toString()});
               this.m_quantityTf.visible = true;
            }
            else
            {
               this.m_quantityTf.visible = false;
            }
         }
      }
      
      protected function onMouseOver(event:MouseEvent = null) : void
      {
         this.m_cursorId = UI.setCursor(EmbeddedArt.cursor_scratch_coin);
      }
      
      protected function onMouseOut(event:MouseEvent = null) : void
      {
         if(this.m_cursorId != UNINITIALIZED_CURSOR_ID)
         {
            UI.removeCursor(this.m_cursorId);
            this.m_cursorId = UNINITIALIZED_CURSOR_ID;
         }
      }
      
      public function setSlotClickCallback(callback:Function) : void
      {
         this.m_callback = callback;
      }
      
      public function onClick(event:MouseEvent) : void
      {
         if(this.isScratched() == false)
         {
            this.scratchTile();
            if(this.m_callback != null)
            {
               this.m_callback(event);
            }
         }
      }
      
      public function resetTile() : void
      {
         this.m_scratchMc.visible = false;
         this.m_effectMc.visible = false;
         (this.m_effectMc.element as MovieClip).gotoAndStop(IDLE_WIN_ANIM_FRAME);
         this.m_matchedMc.visible = false;
         this.m_overMc.visible = true;
      }
      
      public function scratchTile() : void
      {
         if(this.isScratched() == false)
         {
            this.m_scratchMc.visible = true;
            this.m_effectMc.visible = true;
            this.m_overMc.visible = false;
            if(this.m_scratchMc != null)
            {
               this.m_scratchMc.element.gotoAndPlay(START_SCRATCH_ANIM_FRAME);
            }
         }
      }
      
      public function isScratched() : Boolean
      {
         return this.m_scratchMc.visible == true;
      }
      
      public function playWinAnimation() : void
      {
         if(this.m_effectMc != null)
         {
            (this.m_effectMc.element as MovieClip).gotoAndPlay(START_WIN_ANIM_FRAME);
         }
      }
      
      public function toggleMatchedBorder(visible:Boolean) : void
      {
         if(this.m_matchedMc != null)
         {
            this.m_matchedMc.visible = visible;
         }
      }
   }
}


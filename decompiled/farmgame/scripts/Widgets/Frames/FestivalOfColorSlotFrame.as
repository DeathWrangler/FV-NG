package Widgets.Frames
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.FestivalOfColorSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class FestivalOfColorSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "colorSlot_";
      
      protected var m_object:MapResource;
      
      protected var m_item:FarmItem;
      
      protected var m_window:FarmWindow;
      
      public function FestivalOfColorSlotFrame(element:DisplayObject, obj:MapResource, window:FarmWindow)
      {
         this.m_object = obj;
         this.m_item = obj.getItem();
         this.m_window = window;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FestivalOfColorSlot(slotElement,this.m_object,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
      
      public function playFireworksForSlot(overlayName:String) : void
      {
         var altGraphicsArray:Array = null;
         var i:int = 0;
         if(Boolean(overlayName) && Boolean(this.m_item))
         {
            altGraphicsArray = this.m_item.getAltGraphics();
            for(i = 0; i < altGraphicsArray.length; i++)
            {
               if(altGraphicsArray[i] == overlayName)
               {
                  (slots[i] as FestivalOfColorSlot).enableFireworks();
               }
            }
         }
      }
      
      override protected function setupData() : void
      {
         var slotItem:Object = null;
         m_slotData = new Array();
         var altGraphicsArray:Array = this.m_item.getAltGraphics();
         for(var i:int = 0; i < altGraphicsArray.length; i++)
         {
            slotItem = new Object();
            slotItem.applyEnabled = Global.player.hasUnlimitedCredits(this.m_item.name + "_" + altGraphicsArray[i]) && this.m_object.altGraphic != altGraphicsArray[i];
            slotItem.colorName = altGraphicsArray[i];
            slotItem.glowEnabled = this.m_object.altGraphic == altGraphicsArray[i];
            slotItem.locked = !Global.player.hasUnlimitedCredits(this.m_item.name + "_" + altGraphicsArray[i]);
            m_slotData.push(slotItem);
         }
      }
      
      override public function release() : void
      {
         this.m_object = null;
         this.m_item = null;
         this.m_window = null;
         super.release();
      }
   }
}


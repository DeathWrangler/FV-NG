package Widgets.Slots.LESlotMachine
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public final class LESlotMachineDiscountPanel extends ZwSlotFrame
   {
      
      protected var m_textTf:ZwTextField = null;
      
      protected var m_freeMc:ZwFrame = null;
      
      public function LESlotMachineDiscountPanel(element:DisplayObject)
      {
         super(element);
         var elementMc:MovieClip = element as MovieClip;
         if(elementMc.amount_tf)
         {
            this.m_textTf = addWidget(new ZwTextField(elementMc.amount_tf)) as ZwTextField;
         }
         if(elementMc.free_mc)
         {
            this.m_freeMc = addWidget(new ZwFrame(elementMc.free_mc)) as ZwFrame;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         if(data is int && this.m_textTf != null)
         {
            if(data as int == 100 && this.m_freeMc != null)
            {
               this.m_freeMc.visible = true;
               this.m_textTf.visible = false;
            }
            else
            {
               this.m_textTf.text = (data as int).toString();
               this.m_textTf.visible = true;
               if(this.m_freeMc != null)
               {
                  this.m_freeMc.visible = false;
               }
            }
         }
      }
   }
}


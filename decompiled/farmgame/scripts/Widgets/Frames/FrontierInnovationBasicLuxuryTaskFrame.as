package Widgets.Frames
{
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FrontierInnovationBasicLuxuryTaskSlot;
   import Widgets.Windows.FrontierInnovationBarnWindow;
   import flash.display.DisplayObject;
   
   public class FrontierInnovationBasicLuxuryTaskFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String;
      
      private var m_frameName:String;
      
      private var m_titleTf:ZwTextField;
      
      private const BASICTASK_MC:String = "basic_mc";
      
      private const LUXURYTASK_MC:String = "luxury_mc";
      
      private var m_window:FrontierInnovationBarnWindow;
      
      internal var manager:FrontierInnovationManager;
      
      public function FrontierInnovationBasicLuxuryTaskFrame(element:DisplayObject, featureName:String, window:FrontierInnovationBarnWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = this.manager = FrontierInnovationManager.getInstance(featureName);
         this.m_frameName = element.name;
         super(element);
         if(m_element.hasOwnProperty("title_tf"))
         {
            this.m_titleTf = new ZwTextField(m_element["title_tf"]);
            if(this.m_frameName == this.BASICTASK_MC)
            {
               this.m_titleTf.text = "Basic Resources";
            }
            if(this.m_frameName == this.LUXURYTASK_MC)
            {
               this.m_titleTf.text = "Luxury Resources";
            }
            this.m_titleTf.visible = true;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FrontierInnovationBasicLuxuryTaskSlot(this.m_featureName,slotElement,this.m_window);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "item";
      }
      
      override protected function setupData() : void
      {
         var data:Array = null;
         var temp:Object = null;
         m_slotData = [];
         if(this.m_frameName == this.BASICTASK_MC)
         {
            data = this.manager.getSortedBasicFrameData();
         }
         else if(this.m_frameName == this.LUXURYTASK_MC)
         {
            data = this.manager.getSortedLuxuryFrameData();
         }
         for(var i:int = 0; i < data.length; i++)
         {
            temp = data[i];
            m_slotData.push({
               "Count":temp["value"],
               "resourceCode":temp["key"]
            });
         }
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}


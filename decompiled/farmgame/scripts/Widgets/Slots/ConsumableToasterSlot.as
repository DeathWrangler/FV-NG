package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.AntiqueMuseumV2Manager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ConsumableToasterFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.ConsumableToasterWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ConsumableToasterSlot extends ZwSlotFrame
   {
      
      private static const SERVICE_NAME:String = "AntiqueMuseumV2Service";
      
      private var m_window:ConsumableToasterWindow;
      
      private var m_frame:ConsumableToasterFrame;
      
      private const FEATURE_NAME:String = "AntiqueMuseumV2";
      
      private const ICON_PATH_PREFIX:String = "assets/dialogs/JulySideCarFeature_CanadianMuseum/";
      
      private const ICON_PATH_SUFFIX:String = "_175.png";
      
      private var m_stage_tf:ZwTextField;
      
      private var m_complete1_tf:ZwTextField;
      
      private var m_complete2_tf:ZwTextField;
      
      private var m_addParts_bt:FarmAnimatedTextButton;
      
      private var m_buyParts_bt:FarmAnimatedCashButton;
      
      private var m_progressBar_mc:MovieClip;
      
      private var m_antiqueIcon:FarmIcon;
      
      private var m_currentSlot_mc:MovieClip;
      
      private var m_bar_mc:MovieClip;
      
      private var m_consumableIcon:FarmIcon;
      
      private var m_farmItem:FarmItem;
      
      private var m_pieceItemName:String;
      
      private var m_slotNumber:Number;
      
      private var m_progress:int;
      
      private var m_countTf:ZwTextField;
      
      public function ConsumableToasterSlot(element:DisplayObject, window:ConsumableToasterWindow, frame:ConsumableToasterFrame)
      {
         super(element);
         this.m_window = window;
         this.m_frame = frame;
         this.visible = true;
         this.m_currentSlot_mc = element as MovieClip;
         if(this.m_currentSlot_mc)
         {
            this.m_currentSlot_mc.visible = true;
         }
         if(m_element.hasOwnProperty("consumablecount_tf"))
         {
            this.m_countTf = new ZwTextField(m_element["consumablecount_tf"]);
            this.m_countTf.visible = true;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         if(data)
         {
            if(data.hasOwnProperty("pieceName"))
            {
               this.m_pieceItemName = data["pieceName"];
            }
            if(data.hasOwnProperty("pieceProgress"))
            {
               this.m_progress = data["pieceProgress"];
               this.m_countTf.text = data["pieceProgress"].toString();
               this.m_countTf.visible = true;
            }
            this.m_consumableIcon = new FarmIcon(m_element["c_icon"],this.ICON_PATH_PREFIX + this.manager.m_consumableCodeMapping[this.m_pieceItemName] + "1" + this.ICON_PATH_SUFFIX);
            this.m_consumableIcon.setIconSize(50,50);
            this.m_consumableIcon.visible = true;
         }
      }
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance(this.FEATURE_NAME);
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}


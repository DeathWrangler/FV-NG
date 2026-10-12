package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.AntiqueMuseumManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AntiqueMuseumConsumableFoundFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.AntiqueMuseumConsumableFoundWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class AntiqueMuseumConsumableFoundSlot extends ZwSlotFrame
   {
      
      private static const SERVICE_NAME:String = "AntiqueMuseumService";
      
      private var m_window:AntiqueMuseumConsumableFoundWindow;
      
      private var m_frame:AntiqueMuseumConsumableFoundFrame;
      
      private const FEATURE_NAME:String = "AntiqueMuseum";
      
      private const ICON_PATH_PREFIX:String = "assets/dialogs/AntiqueMuseum/AntiqueMuseum_Icons/";
      
      private const ICON_PATH_SUFFIX:String = "_icon_200.png";
      
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
      
      public function AntiqueMuseumConsumableFoundSlot(element:DisplayObject, window:AntiqueMuseumConsumableFoundWindow, frame:AntiqueMuseumConsumableFoundFrame)
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
            this.m_countTf = new ZwTextField(m_element["consumablecount_tf"],"0");
            this.m_countTf.visible = true;
         }
      }
      
      public function markAntiqueCompleted() : *
      {
         this.m_complete1_tf.text = "Completed";
         this.m_complete2_tf.text = "Keep harvesting  to find the next Antique";
         this.m_complete1_tf.visible = true;
         this.m_complete2_tf.visible = false;
         this.m_addParts_bt.visible = false;
         this.m_buyParts_bt.visible = false;
         this.m_stage_tf.visible = false;
         this.m_consumableIcon.visible = false;
         this.m_progressBar_mc.visible = false;
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
               this.m_countTf.text = data["pieceProgress"];
               this.m_countTf.visible = true;
            }
            this.m_consumableIcon = new FarmIcon(m_element["icon_mc"],this.ICON_PATH_PREFIX + this.m_pieceItemName + "_0" + this.ICON_PATH_SUFFIX);
            this.m_consumableIcon.setIconSize(100,100);
            this.m_consumableIcon.visible = true;
         }
      }
      
      private function get manager() : AntiqueMuseumManager
      {
         return AntiqueMuseumManager.getInstance(this.FEATURE_NAME);
      }
      
      private function onBuyPartDone(result:Object = null) : void
      {
         if(result)
         {
            this.m_addParts_bt.visible = true;
            this.m_buyParts_bt.visible = false;
            this.m_buyParts_bt.enabled = true;
         }
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}


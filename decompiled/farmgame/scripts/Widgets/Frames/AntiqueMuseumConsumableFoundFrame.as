package Widgets.Frames
{
   import Managers.AntiqueMuseumManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.AntiqueMuseumConsumableFoundSlot;
   import Widgets.Windows.AntiqueMuseumConsumableFoundWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class AntiqueMuseumConsumableFoundFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "consumable_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:AntiqueMuseumConsumableFoundWindow;
      
      private var m_featureName:String = "AntiqueMuseum";
      
      private var m_pieces:Array;
      
      public function AntiqueMuseumConsumableFoundFrame(element:DisplayObject, parentWindow:AntiqueMuseumConsumableFoundWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty("consumable_header_tf"))
         {
            addWidget(new ZwTextField(m_element["consumable_header_tf"],featureName));
            m_element["consumable_header_tf"].visible = true;
         }
      }
      
      public function onGoHarvestButtonClick(e:Event) : *
      {
         this.manager.openCropMiniMarket();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new AntiqueMuseumConsumableFoundSlot(slotElement,this.m_window,this);
      }
      
      override protected function setupData() : void
      {
         var i:int = 0;
         m_slotData = [];
         this.setData();
         if(this.m_pieces)
         {
            for(i = 0; i < m_slots.length; i++)
            {
               m_slotData.push({
                  "pieceNumber":i,
                  "pieceName":this.m_pieces[i]["pieceName"],
                  "pieceProgress":this.m_pieces[i]["pieceProgress"]
               });
            }
         }
      }
      
      public function setData() : void
      {
         var pieceData:Array = null;
         var progress:int = 0;
         var curr:int = 0;
         this.m_pieces = [];
         var featureData:* = this.manager.getFeatureData();
         var pphGrantData:Array = featureData[this.manager.KEY_PPH_GRANT_ONLY];
         for(var index:* = 0; index < pphGrantData.length; index++)
         {
            pieceData = this.manager.getActivePieces();
            progress = int(pphGrantData[index]);
            if(progress > 0)
            {
               curr = this.manager.getTempPartsRequiredToComplete(pieceData[index]) + pphGrantData[index];
               if(progress > curr)
               {
                  progress = curr;
               }
            }
            curr = 0;
            if(curr)
            {
               progress = 0;
            }
            this.m_pieces[index] = {
               "pieceName":pieceData[index],
               "pieceProgress":progress
            };
         }
      }
      
      private function get manager() : AntiqueMuseumManager
      {
         return AntiqueMuseumManager.getInstance(this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}


package Widgets.Frames
{
   import Managers.AntiqueMuseumManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.AntiqueMuseumPieceSlot;
   import Widgets.Windows.AntiqueMuseumMainWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class AntiqueMuseumPiecesFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:AntiqueMuseumMainWindow;
      
      private var m_featureName:String = "AntiqueMuseum";
      
      private var m_pieces:Array;
      
      public var m_PlantBt:FarmAnimatedTextButton;
      
      public function AntiqueMuseumPiecesFrame(element:DisplayObject, parentWindow:AntiqueMuseumMainWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty("go_harvest_bt"))
         {
            addWidget(this.m_PlantBt = new FarmAnimatedTextButton(m_element["go_harvest_bt"],"Plant",this.onGoHarvestButtonClick));
            m_element["go_harvest_bt"].visible = true;
            if(Boolean(this.manager) && this.manager.isFeatureCompleted())
            {
               m_element["go_harvest_bt"].visible = false;
            }
         }
      }
      
      public function onGoHarvestButtonClick(e:Event) : *
      {
         this.manager.closeMainWindow(e);
         this.manager.openCropMiniMarket();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new AntiqueMuseumPieceSlot(slotElement,this.m_window,this);
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
                  "pieceItemName":this.m_pieces[i]["pieceItemName"]
               });
            }
         }
      }
      
      public function setData() : void
      {
         var pieceData:XML = null;
         this.m_pieces = [];
         var featureData:* = this.manager.getFeatureData();
         var piecesList:Array = featureData[this.manager.KEY_SAVED_ACTIVE_PIECES];
         for(var index:* = 0; index < piecesList.length; index++)
         {
            pieceData = this.manager.getPiecesData(piecesList[index]);
            this.m_pieces[index] = {
               "pieceItemName":pieceData.@name,
               "pieceIndex":pieceData.@count,
               "pieceName":pieceData.@friendlyname
            };
         }
      }
      
      public function enableAdd(slotNumber:*) : *
      {
         (m_slots[slotNumber] as AntiqueMuseumPieceSlot).enableAddButton();
         this.refresh();
      }
      
      public function showGlow(slotNumber:*) : *
      {
         (m_slots[slotNumber] as AntiqueMuseumPieceSlot).showGlowAnimation();
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


package Widgets.Frames
{
   import Managers.AntiqueMuseumV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.AntiqueMuseumV2PieceSlot;
   import Widgets.Windows.AntiqueMuseumV2MainWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class AntiqueMuseumV2PiecesFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:AntiqueMuseumV2MainWindow;
      
      private var m_featureName:String = "AntiqueMuseumV2";
      
      private var m_pieces:Array;
      
      public var m_PlantBt:FarmAnimatedTextButton;
      
      public function AntiqueMuseumV2PiecesFrame(element:DisplayObject, parentWindow:AntiqueMuseumV2MainWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty("go_harvest_bt"))
         {
            addWidget(this.m_PlantBt = new FarmAnimatedTextButton(m_element["go_harvest_bt"],"Go Harvest",this.onGoHarvestButtonClick));
            m_element["go_harvest_bt"].visible = true;
            if(Boolean(this.manager) && this.manager.isFeatureCompleted())
            {
               m_element["go_harvest_bt"].visible = false;
            }
         }
      }
      
      public function onGoHarvestButtonClick(e:Event) : void
      {
         this.manager.closeMainWindow(e);
         this.manager.openCropMiniMarket();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new AntiqueMuseumV2PieceSlot(slotElement,this.m_window,this);
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
                  "pieceItemName":this.m_pieces[i]["pieceItemName"],
                  "pieceImageName":this.m_pieces[i]["pieceImageName"],
                  "showPiece":this.manager.getCurrentPieceIndex() == i
               });
            }
         }
      }
      
      public function setData() : void
      {
         var pieceData:XML = null;
         this.m_pieces = [];
         var featureData:Object = this.manager.getFeatureData();
         var piecesList:Array = featureData[this.manager.KEY_SAVED_ACTIVE_PIECES];
         for(var index:int = 0; index < piecesList.length; index++)
         {
            pieceData = this.manager.getPiecesData(piecesList[index]);
            this.m_pieces[index] = {
               "pieceItemName":pieceData.@name,
               "pieceImageName":pieceData.@imageName,
               "pieceIndex":pieceData.@count,
               "pieceName":pieceData.@friendlyname
            };
         }
      }
      
      public function enableAdd(slotNumber:int) : void
      {
         (m_slots[slotNumber] as AntiqueMuseumV2PieceSlot).enableAddButton();
         this.refresh();
      }
      
      public function showGlow(slotNumber:int) : void
      {
         (m_slots[slotNumber] as AntiqueMuseumV2PieceSlot).showGlowAnimation();
      }
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance();
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


package Widgets.Frames
{
   import Managers.AntiqueMuseumV2Manager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.AntiqueMuseumV2CollectionSlot;
   import Widgets.Windows.AntiqueMuseumV2CollectionWindow;
   import flash.display.DisplayObject;
   
   public class AntiqueMuseumV2CollectionsFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "antique";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:AntiqueMuseumV2CollectionWindow;
      
      private var m_featureName:String = "AntiqueMuseumV2";
      
      private var m_pieces:Array;
      
      public function AntiqueMuseumV2CollectionsFrame(element:DisplayObject, parentWindow:AntiqueMuseumV2CollectionWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new AntiqueMuseumV2CollectionSlot(slotElement,this.m_window,this);
      }
      
      override protected function setupData() : void
      {
         m_slotData = [];
         this.setData();
         for(var index:int = 0; index < m_slots.length; index++)
         {
            m_slotData.push({
               "tileSlotNumber":index,
               "pieceName":this.m_pieces[index]["pieceName"],
               "pieceItemName":this.m_pieces[index]["pieceItemName"],
               "pieceImageName":this.m_pieces[index]["pieceImageName"]
            });
         }
      }
      
      public function setData() : void
      {
         var piece:String = null;
         var pieceData:Object = null;
         this.m_pieces = [];
         var piecesList:Array = this.manager.getAllPiecesInOrder();
         var index:int = 0;
         for each(piece in piecesList)
         {
            pieceData = this.manager.getPiecesData(piece);
            this.m_pieces[index] = {
               "pieceItemName":pieceData.@name,
               "pieceImageName":pieceData.@imageName,
               "pieceName":pieceData.@friendlyname
            };
            index++;
         }
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


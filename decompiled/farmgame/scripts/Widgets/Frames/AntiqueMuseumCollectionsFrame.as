package Widgets.Frames
{
   import Managers.AntiqueMuseumManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.AntiqueMuseumCollectionSlot;
   import Widgets.Windows.AntiqueMuseumCollectionWindow;
   import flash.display.DisplayObject;
   
   public class AntiqueMuseumCollectionsFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "antique";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:AntiqueMuseumCollectionWindow;
      
      private var m_featureName:String = "AntiqueMuseum";
      
      private var m_pieces:Array;
      
      public function AntiqueMuseumCollectionsFrame(element:DisplayObject, parentWindow:AntiqueMuseumCollectionWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new AntiqueMuseumCollectionSlot(slotElement,this.m_window,this);
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
               "pieceItemName":this.m_pieces[index]["pieceItemName"]
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
               "pieceName":pieceData.@friendlyname
            };
            index++;
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


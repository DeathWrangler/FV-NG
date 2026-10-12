package Widgets.Slots
{
   import Managers.AntiqueMuseumManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AntiqueMuseumCollectionsFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.AntiqueMuseumCollectionWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class AntiqueMuseumCollectionSlot extends ZwSlotFrame
   {
      
      private var m_window:AntiqueMuseumCollectionWindow;
      
      private var m_frame:AntiqueMuseumCollectionsFrame;
      
      private const FEATURE_NAME:String = "AntiqueMuseum";
      
      private const ICON_PATH_PREFIX:String = "assets/dialogs/AntiqueMuseum/AntiqueMuseum_Icons/";
      
      private const ICON_PATH_SUFFIX:String = "_icon_200.png";
      
      private var m_currentElement_mc:MovieClip;
      
      private var m_currentSlot:MovieClip;
      
      private var m_pieceItemName:String;
      
      private var m_pieceName:String;
      
      private var m_title_tf:ZwTextField;
      
      private var m_antiqueIcon:FarmIcon;
      
      private var m_progress:int;
      
      private var m_slotNumber:Number;
      
      public function AntiqueMuseumCollectionSlot(element:DisplayObject, window:AntiqueMuseumCollectionWindow, frame:AntiqueMuseumCollectionsFrame)
      {
         super(element);
         this.m_window = window;
         this.m_frame = frame;
         this.visible = true;
         this.m_currentElement_mc = element as MovieClip;
         if(this.m_currentElement_mc)
         {
            this.m_currentElement_mc.visible = true;
         }
         if(m_element.hasOwnProperty("antiquename_tf"))
         {
            this.m_title_tf = new ZwTextField(m_element["antiquename_tf"],"");
         }
         if(m_element.hasOwnProperty("antique_icon"))
         {
            this.m_antiqueIcon = new FarmIcon(m_element["antique_icon"],"");
         }
      }
      
      override public function populate(data:Object) : void
      {
         var activePiecesList:Array = null;
         var completedPiecesList:Array = null;
         var isPieceActive:Boolean = false;
         var isPieceCompleted:Boolean = false;
         if(data)
         {
            if(data.hasOwnProperty("tileSlotNumber"))
            {
               this.m_slotNumber = data["tileSlotNumber"];
            }
            if(data.hasOwnProperty("pieceItemName"))
            {
               this.m_pieceItemName = data["pieceItemName"];
            }
            if(data.hasOwnProperty("pieceName"))
            {
               this.m_pieceName = data["pieceName"];
               this.m_title_tf.text = this.m_pieceName;
               this.m_title_tf.visible = true;
            }
            this.m_progress = this.manager.getCurrentStage(this.m_pieceItemName);
            this.m_antiqueIcon = new FarmIcon(m_element["antique_icon"],this.ICON_PATH_PREFIX + this.m_pieceItemName + (this.m_progress + 1 <= 6 ? "_0" + (this.m_progress + 1).toString() : "") + this.ICON_PATH_SUFFIX);
            this.m_antiqueIcon.setIconSize(80,80);
            this.m_antiqueIcon.visible = true;
            activePiecesList = this.manager.getActivePieces();
            completedPiecesList = this.manager.getCompletedPiecesList();
            isPieceActive = activePiecesList.indexOf(this.m_pieceItemName) != -1;
            isPieceCompleted = completedPiecesList.indexOf(this.m_pieceItemName) != -1;
            if(isPieceCompleted)
            {
               this.m_title_tf.text = this.m_pieceName;
            }
            else if(isPieceActive)
            {
               this.m_title_tf.text = "Restoring..";
            }
            else
            {
               this.m_title_tf.text = "?";
            }
         }
      }
      
      private function get manager() : AntiqueMuseumManager
      {
         return AntiqueMuseumManager.getInstance(this.FEATURE_NAME);
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}


package Widgets.Slots
{
   import Managers.AntiqueMuseumV2Manager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AntiqueMuseumV2CollectionsFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.AntiqueMuseumV2CollectionWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class AntiqueMuseumV2CollectionSlot extends ZwSlotFrame
   {
      
      private var m_window:AntiqueMuseumV2CollectionWindow;
      
      private var m_frame:AntiqueMuseumV2CollectionsFrame;
      
      private const FEATURE_NAME:String = "AntiqueMuseumV2";
      
      private const ICON_PATH_PREFIX:String = "assets/dialogs/JulySideCarFeature_CanadianMuseum/";
      
      private const ICON_PATH_SUFFIX:String = "_175.png";
      
      private var m_currentElement_mc:MovieClip;
      
      private var m_currentSlot:MovieClip;
      
      private var m_pieceItemName:String;
      
      private var m_pieceName:String;
      
      private var m_title_tf:ZwTextField;
      
      private var m_antiqueIcon:FarmIcon;
      
      private var m_progress:int;
      
      private var m_slotNumber:Number;
      
      private var m_pieceImageName:String;
      
      private var m_grayedOverlay:FarmIcon;
      
      public function AntiqueMuseumV2CollectionSlot(element:DisplayObject, window:AntiqueMuseumV2CollectionWindow, frame:AntiqueMuseumV2CollectionsFrame)
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
            this.m_antiqueIcon.visible = false;
         }
         if(m_element.hasOwnProperty("gradeoutantique_icon"))
         {
            this.m_grayedOverlay = new FarmIcon(m_element["gradeoutantique_icon"]);
            this.m_grayedOverlay.visible = false;
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
            if(data.hasOwnProperty("pieceImageName"))
            {
               this.m_pieceImageName = data["pieceImageName"];
            }
            if(data.hasOwnProperty("pieceName"))
            {
               this.m_pieceName = data["pieceName"];
               this.m_title_tf.text = this.m_pieceName;
               this.m_title_tf.visible = true;
            }
            this.m_progress = this.manager.getCurrentStage(this.m_pieceItemName);
            activePiecesList = this.manager.getActivePieces();
            completedPiecesList = this.manager.getCompletedPiecesList();
            isPieceActive = activePiecesList.indexOf(this.m_pieceItemName) != -1;
            isPieceCompleted = completedPiecesList.indexOf(this.m_pieceItemName) != -1;
            if(isPieceCompleted)
            {
               this.m_title_tf.text = this.m_pieceName;
               this.m_antiqueIcon = new FarmIcon(m_element["antique_icon"],this.ICON_PATH_PREFIX + this.m_pieceImageName + (this.m_progress + 1 <= 6 ? (this.m_progress + 1).toString() : "6") + this.ICON_PATH_SUFFIX);
               this.m_antiqueIcon.setIconSize(80,80);
               this.m_antiqueIcon.visible = true;
               if(this.m_grayedOverlay)
               {
                  this.m_grayedOverlay.visible = false;
               }
            }
            else if(isPieceActive && this.getCurrentConsumables() == this.m_pieceItemName)
            {
               this.m_title_tf.text = "Restoring..";
               this.m_antiqueIcon = new FarmIcon(m_element["antique_icon"],this.ICON_PATH_PREFIX + this.m_pieceImageName + (this.m_progress + 1 <= 6 ? (this.m_progress + 1).toString() : "6") + this.ICON_PATH_SUFFIX);
               this.m_antiqueIcon.setIconSize(80,80);
               this.m_antiqueIcon.visible = true;
               if(this.m_grayedOverlay)
               {
                  this.m_grayedOverlay.visible = false;
               }
            }
            else
            {
               this.m_title_tf.text = "Yet to Start";
               this.m_grayedOverlay = new FarmIcon(m_element["gradeoutantique_icon"],this.ICON_PATH_PREFIX + this.m_pieceImageName + (this.m_progress + 1 <= 6 ? (this.m_progress + 1).toString() : "6") + this.ICON_PATH_SUFFIX);
               this.m_grayedOverlay.setIconSize(80,80);
               this.m_grayedOverlay.visible = true;
               if(this.m_antiqueIcon)
               {
                  this.m_antiqueIcon.visible = false;
               }
            }
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
      
      private function getCurrentConsumables() : String
      {
         var curr:int = 0;
         var featureData:* = this.manager.getFeatureData();
         var pphGrantData:Array = featureData[this.manager.KEY_PPH_GRANT_ONLY];
         var index:int = this.manager.getCurrentPieceIndex();
         var pieceData:Array = this.manager.getActivePieces();
         var progress:int = int(pphGrantData[index]);
         if(progress > 0)
         {
            curr = this.manager.getTempPartsRequiredToComplete(pieceData[index]) + pphGrantData[index];
            if(progress > curr)
            {
               progress = curr;
            }
         }
         if(curr == 0)
         {
            progress = 0;
         }
         return pieceData[index];
      }
   }
}


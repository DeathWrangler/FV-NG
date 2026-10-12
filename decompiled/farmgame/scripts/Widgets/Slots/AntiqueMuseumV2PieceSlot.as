package Widgets.Slots
{
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.AntiqueMuseumV2Manager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AntiqueMuseumV2PiecesFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.AntiqueMuseumV2MainWindow;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AntiqueMuseumV2PieceSlot extends ZwSlotFrame
   {
      
      private static const SERVICE_NAME:String = "AntiqueMuseumV2Service";
      
      private var m_window:AntiqueMuseumV2MainWindow;
      
      private var m_frame:AntiqueMuseumV2PiecesFrame;
      
      private const FEATURE_NAME:String = "AntiqueMuseumV2";
      
      private const ICON_PATH_PREFIX:String = "assets/dialogs/JulySideCarFeature_CanadianMuseum/";
      
      private const ICON_PATH_SUFFIX:String = "_175.png";
      
      private const GLOW_FRAME_COUNT:* = 15;
      
      private var m_title_tf:ZwTextField;
      
      private var m_stage_tf:ZwTextField;
      
      private var m_subparts_tf:ZwTextField;
      
      private var m_complete1_tf:ZwTextField;
      
      private var m_complete2_tf:ZwTextField;
      
      private var m_addParts_bt:FarmAnimatedTextButton;
      
      public var m_glow_mc:MovieClip;
      
      private var m_buyParts_bt:FarmAnimatedCashButton;
      
      private var m_count_tf:ZwTextField;
      
      private var m_progressBar_mc:MovieClip;
      
      private var m_antiqueIcon:FarmIcon;
      
      private var m_currentSlot_mc:MovieClip;
      
      private var m_bar_mc:MovieClip;
      
      private var m_consumableIcon:FarmIcon;
      
      private var m_consumablePartMc:MovieClip;
      
      private var m_pieceName:String;
      
      private var m_pieceItemName:String;
      
      private var m_slotNumber:Number;
      
      private var m_progress:int;
      
      private var m_subparts_progress:int;
      
      private var m_pieceImageName:String;
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_lockMc:MovieClip;
      
      public function AntiqueMuseumV2PieceSlot(element:DisplayObject, window:AntiqueMuseumV2MainWindow, frame:AntiqueMuseumV2PiecesFrame)
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
         if(m_element.hasOwnProperty("slotmc_tittle_tf"))
         {
            this.m_title_tf = new ZwTextField(m_element["slotmc_tittle_tf"],"TITLE");
         }
         if(m_element.hasOwnProperty("stage_tf"))
         {
            this.m_stage_tf = new ZwTextField(m_element["stage_tf"],"");
         }
         if(m_element.hasOwnProperty("partscount_tf"))
         {
            this.m_subparts_tf = new ZwTextField(m_element["partscount_tf"],"");
         }
         if(m_element.hasOwnProperty("antiquecomplete1_tf"))
         {
            this.m_complete1_tf = new ZwTextField(m_element["antiquecomplete1_tf"],"");
            this.m_complete1_tf.visible = false;
         }
         if(m_element.hasOwnProperty("antiquecomplete2_tf"))
         {
            this.m_complete2_tf = new ZwTextField(m_element["antiquecomplete2_tf"]);
         }
         if(m_element.hasOwnProperty("animation_mc"))
         {
            this.m_glow_mc = m_element["animation_mc"] as MovieClip;
            this.m_glow_mc.visible = false;
         }
         if(m_element.hasOwnProperty("addparts_bt"))
         {
            this.m_addParts_bt = new FarmAnimatedTextButton(m_element["addparts_bt"],"Add",this.onAddPartButtonClick);
         }
         if(m_element.hasOwnProperty("antique_icon"))
         {
            this.m_antiqueIcon = new FarmIcon(m_element["antique_icon"],"");
         }
         if(m_element.hasOwnProperty("consumable_part"))
         {
            this.m_consumablePartMc = m_element["consumable_part"] as MovieClip;
            this.m_consumablePartMc.visible = true;
            if(this.m_consumablePartMc.hasOwnProperty("consumablepart_icon"))
            {
               this.m_consumableIcon = new FarmIcon(this.m_consumablePartMc["consumablepart_icon"]);
               this.m_consumableIcon.setIconSize(30,30);
               this.m_consumableIcon.visible = false;
            }
         }
         if(m_element.hasOwnProperty("slotmc_progressbar"))
         {
            this.m_progressBar_mc = m_element["slotmc_progressbar"] as MovieClip;
            this.m_progressBar_mc.visible = true;
            if(this.m_progressBar_mc.hasOwnProperty("bar_fill_mc"))
            {
               this.m_bar_mc = this.m_progressBar_mc["bar_fill_mc"] as MovieClip;
               this.m_bar_mc.visible = true;
            }
         }
         if(m_element.hasOwnProperty("buyparts_bt"))
         {
            this.m_buyParts_bt = new FarmAnimatedCashButton(m_element["buyparts_bt"],"Buy " + this.manager.GRANT_PARTS_ON_BUY + " Parts",this.manager.COST_PER_PACK.toString(),this.onBuyPartButtonClick);
         }
         if(this.m_complete1_tf)
         {
            this.m_complete1_tf.visible = false;
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkmarkMc = m_element["checkmark_mc"] as MovieClip;
            this.m_checkmarkMc.visible = false;
         }
         if(m_element.hasOwnProperty("lock_mc"))
         {
            this.m_lockMc = m_element["lock_mc"] as MovieClip;
            this.m_lockMc.visible = false;
         }
      }
      
      public function markAntiqueCompleted() : *
      {
         this.m_addParts_bt.visible = false;
         this.m_buyParts_bt.text = "Buy 5 Parts";
         this.m_buyParts_bt.visible = false;
         this.m_stage_tf.visible = false;
         this.m_subparts_tf.visible = false;
         this.m_consumableIcon.visible = false;
         if(this.manager.getNumberofCompletedPieces() >= 5)
         {
            this.m_consumablePartMc.visible = false;
         }
         else
         {
            this.m_consumablePartMc.visible = true;
         }
         this.m_progressBar_mc.visible = false;
      }
      
      override public function populate(data:Object) : void
      {
         var currentPieceIndex:int = 0;
         super.populate(data);
         if(data)
         {
            if(data.hasOwnProperty("pieceNumber"))
            {
               this.m_slotNumber = data["pieceNumber"];
            }
            if(data.hasOwnProperty("pieceName"))
            {
               this.m_pieceName = data["pieceName"];
               this.m_title_tf.text = this.m_pieceName;
               this.m_title_tf.visible = true;
            }
            if(data.hasOwnProperty("pieceItemName"))
            {
               this.m_pieceItemName = data["pieceItemName"];
            }
            if(data.hasOwnProperty("pieceImageName"))
            {
               this.m_pieceImageName = data["pieceImageName"];
            }
            this.m_progress = this.manager.getCurrentStage(this.m_pieceItemName);
            this.m_subparts_progress = this.manager.getSubpartsProgress(this.m_pieceItemName) % this.manager.PARTS_PER_PIECE;
            TweenMax.to(this.m_bar_mc,2,{"width":this.m_subparts_progress * 7});
            this.m_antiqueIcon = new FarmIcon(m_element["antique_icon"],this.ICON_PATH_PREFIX + this.m_pieceImageName + (this.m_progress + 1 <= 6 ? (this.m_progress + 1).toString() : "6") + this.ICON_PATH_SUFFIX);
            if(this.m_consumableIcon)
            {
               this.m_consumableIcon.loadIcon(this.ICON_PATH_PREFIX + this.manager.m_consumableMapping[this.m_pieceImageName]);
               this.m_consumableIcon.visible = true;
            }
            this.m_progressBar_mc.visible = true;
            this.m_antiqueIcon.visible = true;
            this.m_buyParts_bt.visible = true;
            this.m_stage_tf.text = "Stage " + this.m_progress.toString() + "/5";
            this.m_stage_tf.visible = true;
            this.m_subparts_tf.text = this.m_subparts_progress.toString() + "/20";
            this.m_subparts_tf.visible = true;
            if(this.manager.getNumberOfPartsGranted(this.m_slotNumber) > 0)
            {
               this.enableAddButton(this.manager.getNumberOfPartsGranted(this.m_slotNumber));
            }
            currentPieceIndex = this.manager.getCurrentPieceIndex();
            if(currentPieceIndex < this.m_slotNumber)
            {
               this.m_checkmarkMc.visible = false;
               this.m_lockMc.visible = true;
            }
            else if(currentPieceIndex > this.m_slotNumber)
            {
               this.m_checkmarkMc.visible = true;
               this.m_lockMc.visible = false;
               this.m_progressBar_mc.visible = false;
            }
            else
            {
               this.m_checkmarkMc.visible = false;
               this.m_lockMc.visible = false;
            }
            if(this.m_progress == 5)
            {
               this.m_buyParts_bt.visible = false;
               this.m_consumablePartMc.visible = false;
               this.m_consumableIcon.visible = false;
               this.m_progressBar_mc.visible = false;
               this.m_subparts_tf.visible = false;
               this.m_addParts_bt.visible = false;
               this.m_stage_tf.visible = false;
            }
         }
      }
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance(this.FEATURE_NAME);
      }
      
      private function onBuyPartButtonClick(e:Event) : void
      {
         this.m_buyParts_bt.enabled = false;
         UI.displayMessage(ZLocUtils.t("Dialogs","AntiqueMuseumV2BuyPartsPopup",{
            "cashQuantity":this.manager.COST_PER_PACK,
            "item":"antique piece"
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmCompletePopupClose,"",true);
      }
      
      private function onBuyPartDone(result:Object = null) : void
      {
         if(result)
         {
            StatsManager.count(this.FEATURE_NAME,"buypart","","7","","",5);
            this.enableAddButton(this.manager.getNumberOfPartsGranted(this.m_slotNumber));
         }
      }
      
      public function enableAddButton(count:int = 1) : void
      {
         if(count > 0)
         {
            if(count > this.manager.getSubpartsRequiredToComplete(this.m_pieceItemName))
            {
               count = this.manager.getSubpartsRequiredToComplete(this.m_pieceItemName);
            }
            this.m_addParts_bt.visible = true;
            this.m_addParts_bt.enabled = true;
            this.m_addParts_bt.text = "Add " + count + " Parts";
            this.m_buyParts_bt.visible = false;
            this.m_buyParts_bt.enabled = true;
         }
      }
      
      public function enableBuyButton() : void
      {
         this.m_buyParts_bt.visible = true;
         this.m_addParts_bt.visible = false;
         this.m_addParts_bt.enabled = true;
      }
      
      private function onAddPartButtonClick(e:Event) : void
      {
         this.m_addParts_bt.enabled = false;
         this.m_buyParts_bt.enabled = true;
         this.m_window.tintWindow();
         this.m_window.enableInput = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"addPart",this.onAddPartDone,[this.FEATURE_NAME,this.m_pieceItemName,this.m_slotNumber]),true);
      }
      
      public function onAddPartDone(result:Object) : void
      {
         if(result)
         {
            this.m_window.untintWindow();
            this.m_window.enableInput = true;
            this.manager.setCurrentPieceIndex(result);
            if(this.manager.getTempPieceProgress(this.m_pieceItemName) >= 100)
            {
               this.markAntiqueCompleted();
               this.manager.pushPieceToCompletedList(this.m_pieceItemName);
            }
            this.manager.updateAntiquePartProgress(this.m_pieceItemName);
            this.m_addParts_bt.visible = false;
            this.m_addParts_bt.enabled = true;
            this.m_buyParts_bt.visible = true;
         }
      }
      
      private function onConfirmCompletePopupClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            if(Global.player.canBuyCash(this.manager.COST_PER_PACK,true))
            {
               Global.player.cash -= this.manager.COST_PER_PACK;
               this.manager.incrementTempParts(this.m_pieceItemName,this.manager.GRANT_PARTS_ON_BUY);
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"buyPart",this.onBuyPartDone,[this.FEATURE_NAME,this.m_pieceItemName,this.m_slotNumber]),true);
            }
            else
            {
               this.m_buyParts_bt.enabled = true;
            }
         }
         else
         {
            this.m_buyParts_bt.enabled = true;
         }
      }
      
      public function showGlowAnimation() : void
      {
         if(this.m_glow_mc)
         {
            this.m_glow_mc.visible = true;
            MovieClipUtils.recursivePlay(this.m_glow_mc);
         }
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}


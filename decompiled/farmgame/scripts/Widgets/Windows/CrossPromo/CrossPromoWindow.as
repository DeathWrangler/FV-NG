package Widgets.Windows.CrossPromo
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.MapTrigger;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   
   public class CrossPromoWindow extends FarmWindow
   {
      
      protected var m_crossPromoName:String;
      
      protected var m_promoGameID:String = null;
      
      protected var m_billboard:MapTrigger = null;
      
      protected var m_showCheckbox:Boolean;
      
      protected var m_checkMark:ZwBaseWidget = null;
      
      protected var m_signItemName:String;
      
      public function CrossPromoWindow(assetPath:String, crossPromoName:String, crossPromoGameId:String, showCheckbox:Boolean = false, sign:MapTrigger = null, signItemName:String = null)
      {
         super(assetPath);
         this.m_showCheckbox = showCheckbox;
         this.m_billboard = sign;
         this.m_crossPromoName = crossPromoName;
         this.m_promoGameID = crossPromoGameId;
         this.m_signItemName = signItemName;
         this.doSupplementalStats(StatsTrackingConstants.DIALOG_STATS_VIEW_PHYLUM);
         FarmStatsManager.count("dialog","xpromo","view",this.promoGameID,crossPromoName);
      }
      
      protected function onCheckboxClick(event:Event) : void
      {
         this.m_checkMark.visible = !this.m_checkMark.visible;
      }
      
      protected function getAcceptButtonText() : String
      {
         return ZLocUtils.t("Dialogs","MysteryGameToaster_Button_Accept");
      }
      
      protected function getDialogBodyText() : String
      {
         return null;
      }
      
      override protected function postLoadComplete() : void
      {
         var checkBox:FarmAnimatedButton = null;
         var checkBoxText:FarmTextField = null;
         var mainWindowMc:MovieClip = null;
         addWidget(new ZwBaseWidget(m_window.mainWindow));
         if(m_window.mainWindow.hasOwnProperty("popupBox_tf"))
         {
            addWidget(new FarmTextField(m_window.mainWindow.popupBox_tf,ZLocUtils.t("Dialogs",this.m_crossPromoName + "_message")));
         }
         var dialogBodyText:String = this.getDialogBodyText();
         var acceptButtonText:String = this.getAcceptButtonText();
         if(Boolean(m_window.mainWindow.hasOwnProperty("body_tf")) && dialogBodyText != null)
         {
            addWidget(new FarmTextField(m_window.mainWindow.body_tf,dialogBodyText));
         }
         addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,acceptButtonText,this.onAcceptClick));
         if(m_window.mainWindow.hasOwnProperty("cancel_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.mainWindow.cancel_bt,ZLocUtils.t("Dialogs","city_xpromo_round2_cancel"),this.onCancelClick));
         }
         if(Boolean(m_window.mainWindow.hasOwnProperty("checkmark_mc")) && Boolean(m_window.mainWindow.hasOwnProperty("checkbox2_mc")) && Boolean(m_window.mainWindow.hasOwnProperty("checkBox_tf")))
         {
            this.m_checkMark = addWidget(new ZwBaseWidget(m_window.mainWindow.checkmark_mc)) as ZwBaseWidget;
            this.m_checkMark.visible = false;
            checkBox = addWidget(new FarmAnimatedButton(m_window.mainWindow.checkbox2_mc,this.onCheckboxClick)) as FarmAnimatedButton;
            checkBoxText = addWidget(new FarmTextField(m_window.mainWindow.checkBox_tf,ZLocUtils.t("Dialogs",this.m_crossPromoName + "_checkbox"))) as FarmTextField;
            if(!this.m_showCheckbox)
            {
               checkBox.visible = false;
               checkBoxText.visible = false;
            }
         }
         if(Boolean(m_window.mainWindow.hasOwnProperty("prize_mc")) && m_window.mainWindow.prize_mc != null)
         {
            addWidget(new ZwWidget(m_window.mainWindow.prize_mc));
            (m_window.mainWindow.prize_mc as MovieClip).play();
         }
         if(m_window.mainWindow.hasOwnProperty("popupBox_tf"))
         {
            mainWindowMc = m_window.mainWindow as MovieClip;
            this.swapZorders(mainWindowMc,mainWindowMc.popupBox_tf,mainWindowMc.checkbox2_mc);
            this.swapZorders(mainWindowMc,mainWindowMc.checkbox2_mc,mainWindowMc.checkmark_mc);
         }
      }
      
      private function swapZorders(parent:MovieClip, childBehind:DisplayObject, childInFront:DisplayObject) : void
      {
         if(parent.getChildIndex(childBehind) > parent.getChildIndex(childInFront))
         {
            parent.swapChildren(childBehind,childInFront);
         }
      }
      
      protected function get promoGameID() : String
      {
         return this.m_promoGameID;
      }
      
      protected function getPlayUrl() : String
      {
         return ZLocUtils.t("Dialogs",this.m_crossPromoName + "_url");
      }
      
      protected function onAcceptClick(event:Event) : void
      {
         FarmStatsManager.count("dialog","xpromo","accept",this.promoGameID,this.m_crossPromoName);
         this.doSupplementalStats(StatsTrackingConstants.DIALOG_STATS_ACCEPT_PHYLUM);
         var playUrl:String = this.getPlayUrl();
         if(ExternalInterface.available)
         {
            ExternalInterface.call("window.open",playUrl);
         }
         this.processBillboard();
         close();
      }
      
      protected function onCancelClick(event:Event) : void
      {
         FarmStatsManager.count("dialog","xpromo","cancel",this.promoGameID,this.m_crossPromoName);
         this.doSupplementalStats(StatsTrackingConstants.DIALOG_STATS_X_CLICK_PHYLUM);
         this.processBillboard();
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         this.onCancelClick(event);
      }
      
      protected function processBillboard() : void
      {
         var signs:Array = null;
         if(this.m_billboard == null)
         {
            signs = Global.world.getObjectsByName(this.m_signItemName);
            if(signs.length > 0)
            {
               this.m_billboard = signs[0] as MapTrigger;
            }
         }
         if(this.m_checkMark != null && this.m_checkMark.visible && Boolean(this.m_billboard))
         {
            this.setBillboardRemoveSeenFlag();
            this.m_billboard.setToolTip(null);
            this.m_billboard.detach();
         }
      }
      
      protected function setBillboardRemoveSeenFlag() : void
      {
         Global.player.setSeenFlag(this.m_crossPromoName + "_removeBillboard");
      }
      
      protected function doSupplementalStats(source:String) : void
      {
      }
   }
}


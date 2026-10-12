package Widgets.Windows.CrossPromo
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.FrontierPioneerSign;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FrontierPioneerCrossPromoWindow extends CrossPromoWindow
   {
      
      public function FrontierPioneerCrossPromoWindow(showCheckbox:Boolean = false, frontierSign:FrontierPioneerSign = null)
      {
         super("assets/dialogs/FV_xpromo_PioneerTrail.swf","pioneertrail_xpromo",null,showCheckbox,frontierSign,"ftpioneerxpromosign");
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new FarmTextField(m_window.subHead_1_txt,ZLocUtils.t("Dialogs",m_crossPromoName + "_message")));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","MysteryGameToaster_Button_Accept"),this.onAcceptClick));
         addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t("Dialogs","city_xpromo_round2_cancel"),this.onCancelClick));
         m_checkMark = addWidget(new ZwBaseWidget(m_window.checkmark_mc)) as ZwBaseWidget;
         m_checkMark.visible = false;
         m_checkMark.addEventListener(MouseEvent.MOUSE_DOWN,onCheckboxClick);
         addWidget(new FarmTextField(m_window.subHead_2_txt,ZLocUtils.t("Dialogs",m_crossPromoName + "_checkbox")));
         addWidget(new FarmAnimatedButton(m_window.checkbox2_mc,onCheckboxClick)) as FarmAnimatedButton;
      }
      
      override protected function onAcceptClick(event:Event) : void
      {
         super.onAcceptClick(event);
         Global.player.setSeenFlag(CrossPromoConstants.FRONTIERPIONEER_SEEN_TOASTER);
      }
      
      override protected function onCancelClick(event:Event) : void
      {
         Global.player.setSeenFlag(CrossPromoConstants.FRONTIERPIONEER_SEEN_TOASTER);
         super.onCancelClick(event);
      }
      
      override protected function onClose(event:Event) : void
      {
         this.onCancelClick(event);
      }
      
      override protected function setBillboardRemoveSeenFlag() : void
      {
         Global.player.setSeenFlag(CrossPromoConstants.FRONTIERPIONEER_REMOVE_BILLBOARD);
      }
   }
}


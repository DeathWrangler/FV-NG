package Widgets.Windows.DecoPoints
{
   import Classes.util.ZLocUtils;
   import GameMode.GameMode;
   import Managers.DecoPointsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmstamaticTakePhoto;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DecoPointsFarmstamaticDialog extends FarmstamaticTakePhoto
   {
      
      private var m_optOutText:FarmTextField;
      
      private var m_checkMark:MovieClip;
      
      private var m_checkBox:FarmAnimatedButton;
      
      private var m_decoPointsManager:DecoPointsManager;
      
      public function DecoPointsFarmstamaticDialog(gameMode:GameMode, decoPointsManager:DecoPointsManager = null)
      {
         this.m_decoPointsManager = decoPointsManager;
         super(gameMode,this.m_decoPointsManager,"assets/dialogs/FV_farmstamatic2.swf");
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         this.m_optOutText = new FarmTextField(m_mainAsset.optOut_mc.optOut_tf,ZLocUtils.t("Dialogs","photocontest_profileImageOptOut"));
         this.m_checkMark = m_mainAsset.optOut_mc.checkMark_mc;
         this.m_checkMark.enabled = false;
         this.m_checkMark.mouseEnabled = false;
         this.m_checkMark.mouseChildren = false;
         this.m_checkBox = new FarmAnimatedButton(m_mainAsset.optOut_mc.CheckBox_mc,this.onCheckBoxClick);
         this.m_checkMark.visible = this.m_decoPointsManager.allowShowProfileImage;
      }
      
      private function onCheckBoxClick(event:MouseEvent) : void
      {
         this.m_checkMark.visible = !this.m_checkMark.visible;
         this.m_decoPointsManager.allowShowProfileImage = this.m_checkMark.visible;
      }
      
      override public function onExitClick(event:MouseEvent) : void
      {
         this.m_optOutText.release();
         this.m_checkBox.release();
         this.m_optOutText = null;
         this.m_checkMark = null;
         this.m_checkBox = null;
         this.m_decoPointsManager = null;
         super.onExitClick(event);
      }
   }
}


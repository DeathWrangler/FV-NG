package Display
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class MasteryUnlockedPopup extends Dialog
   {
      
      private var m_level:int;
      
      private var m_ok:GenericButton;
      
      public function MasteryUnlockedPopup(level:int)
      {
         m_dialogAsset = "assets/dialogs/FV_CM_Announcement.swf";
         this.m_level = level;
         super(true);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_window.cropMasteryDia_mc.congratulations_tf.text = ZLocUtils.t("Dialogs","Congratulations");
         if(this.m_level > Global.farmGameSettingsManager.getAttribute("masteryStartLevel",15))
         {
            m_window.cropMasteryDia_mc.introduce_tf.text = ZLocUtils.t("Dialogs","MasteryAlready15");
         }
         else
         {
            m_window.cropMasteryDia_mc.introduce_tf.text = ZLocUtils.t("Dialogs","MasteryJustHit15");
         }
         m_window.cropMasteryDia_mc.cm_tf.text = ZLocUtils.t("Dialogs","CropMastery");
         m_window.cropMasteryDia_mc.cangift_tf.text = ZLocUtils.t("Dialogs","UnlockMasteryBody");
         this.m_ok = new GenericButton(m_window.cropMasteryDia_mc.ok_bt,this.onCloseClick);
         this.m_ok.text = ZLocUtils.t("Dialogs","OkButton");
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         m_window.cropMasteryDia_mc.ok_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         FarmStatsManager.count("crop_mastery","Unlocked_Mastery");
         event.stopPropagation();
         close();
      }
   }
}


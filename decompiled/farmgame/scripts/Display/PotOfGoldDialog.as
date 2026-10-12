package Display
{
   import Classes.PotOfGold;
   import Classes.util.ZLocUtils;
   import flash.display.MovieClip;
   
   public class PotOfGoldDialog extends RewardCreditsBuildingDialog
   {
      
      private static const NUM_METER_ANIM_FRAMES:uint = 20;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_StPattys.swf";
      
      private static const LOCKED_ITEM_ICON_URL:String = "assets/decorations/stpatty_locked_icon.png";
      
      public function PotOfGoldDialog(potOfGold:PotOfGold, showWhatIsThisOnLoad:Boolean = false)
      {
         super(potOfGold,"PotOfGold",DIALOG_ASSET,showWhatIsThisOnLoad);
      }
      
      override protected function getAskForCreditsFeatureName() : String
      {
         return PotOfGold.ASK_FOR_CREDITS_FEATURE_NAME;
      }
      
      override protected function getDialogSideIconUrl() : String
      {
         return PotOfGold.DIALOG_SIDE_ICON;
      }
      
      override protected function getLockedItemIconUrl() : String
      {
         return LOCKED_ITEM_ICON_URL;
      }
      
      override protected function getBuildingCreditsXml() : XML
      {
         return Global.farmGameSettingsManager.getBuildingCreditsXml("potOfGold");
      }
      
      override protected function getAskForCreditsButton() : MovieClip
      {
         return m_window.askForLove_mc;
      }
      
      override protected function disableAskForCreditsButton() : void
      {
         m_window.askForLove_mc.visible = false;
         m_window.askForLove_mc.enabled = false;
         m_window.sheen_mc.visible = false;
         m_window.clovers_mc.visible = false;
      }
      
      override protected function getAskSendDisableDate() : String
      {
         return Global.farmGameSettingsManager.getString("potOfGoldtAskSendDisableDate");
      }
      
      override protected function getCreditMeter() : MovieClip
      {
         return m_window.progress_mc.goldMeter_mc as MovieClip;
      }
      
      override protected function getMeterStack() : MovieClip
      {
         return m_window.progress_mc.goldMeter_mc.coinStack_mc as MovieClip;
      }
      
      override protected function getBuidingStateImage() : MovieClip
      {
         return m_window.progress_mc.goldMeter_mc.pot_mc as MovieClip;
      }
      
      override protected function setupCreditsText() : void
      {
         var creditMeter:MovieClip = this.getCreditMeter();
         if(creditMeter)
         {
            creditMeter.currentVal_tf.text = m_currentCredits.toString();
            creditMeter.goldCompletion_tf.text = m_totalCreditsReceived.toString();
            creditMeter.spendLabel_tf.text = ZLocUtils.t("Dialogs",m_buildingClassName + "_NumCreditsLabel");
            creditMeter.receivedLabel_tf.text = ZLocUtils.t("Dialogs",m_buildingClassName + "_TotalCreditsReceivedLabel");
         }
      }
      
      override protected function getNumMeterFrames() : Number
      {
         return NUM_METER_ANIM_FRAMES;
      }
   }
}


package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class IrrigationFTUECompleteWindow extends FarmWindow
   {
      
      private var m_dialogPath:String = "assets/dialogs/FV_irrigation_Prize.swf";
      
      public function IrrigationFTUECompleteWindow()
      {
         super(this.m_dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","Irrigation_FTUERewardTitle")));
         addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t("Dialogs","Irrigation_FTUERewardDescription")));
         addWidget(new FarmAnimatedTextButton(m_window.continue_bt,ZLocUtils.t("Dialogs","Irrigation_FTUERewardButton"),onClose));
         FarmStatsManager.count("water","FTUE","complete");
      }
   }
}


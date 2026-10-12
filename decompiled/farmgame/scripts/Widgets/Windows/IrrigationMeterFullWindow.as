package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class IrrigationMeterFullWindow extends FarmWindow
   {
      
      public function IrrigationMeterFullWindow()
      {
         var dialogPath:String = "assets/dialogs/FV_motd_irrigation_meterFull.swf";
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwFrame(m_window.mainWindow));
         addWidget(new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","Irrigation_MeterFull_Title")));
         addWidget(new ZwTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","Irrigation_MeterFull_Description")));
         addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","Irrigation_MeterFull_Button"),onClose));
         FarmStatsManager.count("water","dialog_view","water_meter_full");
      }
   }
}


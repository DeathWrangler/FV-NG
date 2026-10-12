package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   
   public class ContingencyBuildableTutorialWindow extends FarmWindow
   {
      
      protected var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_dialogConfig:Object;
      
      public function ContingencyBuildableTutorialWindow(dialogConfig:Object)
      {
         this.m_dialogConfig = dialogConfig;
         super(this.m_dialogConfig.tutorialDialog);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(Boolean(m_window.mainWindow["accept_bt"]) && this.m_dialogConfig.hasOwnProperty("tutorialButtonText"))
            {
               this.m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t_pk(this.m_dialogConfig["tutorialButtonText"]),onClose)) as FarmAnimatedTextButton;
            }
            if(Boolean(m_window.mainWindow["title_tf"]) && this.m_dialogConfig.hasOwnProperty("tutorialTitle"))
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t_pk(this.m_dialogConfig["tutorialTitle"])),true);
            }
            if(Boolean(m_window.mainWindow["body_tf"]) && this.m_dialogConfig.hasOwnProperty("tutorialText"))
            {
               addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t_pk(this.m_dialogConfig["tutorialText"])));
            }
            if(m_window.mainWindow["close_bt"])
            {
               addWidget(new FarmButton(m_window.mainWindow.close_bt,onClose),true);
            }
         }
      }
   }
}


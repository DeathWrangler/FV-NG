package Widgets.Windows
{
   import Managers.PumpkinPartyInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class PumpkinPartyInnovationFinalRewardWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_featureName:String;
      
      public const ProgressLevelTextArray:Array = ["Abandoned Plot","Decorated Halloween Hut","Spooky Celebration House","Pumpkin Bungalow","Grand Party Mansion"];
      
      private var m_icon_mc:MovieClip;
      
      private var m_acceptButton:FarmButton;
      
      private var m_titleTf:ZwTextField;
      
      public function PumpkinPartyInnovationFinalRewardWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var buildingLevel:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow.icon_mc)
            {
               this.m_icon_mc = m_window["mainWindow"]["icon_mc"] as MovieClip;
               buildingLevel = this.manager.getRewardLevel();
               if(buildingLevel >= 0 && buildingLevel <= 5)
               {
                  this.m_icon_mc.visible = true;
                  this.m_icon_mc.gotoAndStop(buildingLevel + 1);
               }
            }
            if(m_window.mainWindow.hasOwnProperty(this.TITLE_TF))
            {
               this.m_titleTf = addWidget(new ZwTextField(m_window.mainWindow.title_tf,"Pumpkin Party!")) as ZwTextField;
            }
            if(m_window.mainWindow.hasOwnProperty("close_bt"))
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,onClose)) as FarmButton;
            }
            if(m_window.mainWindow.hasOwnProperty("accept_bt"))
            {
               this.m_acceptButton = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Okay!",onClose)) as FarmAnimatedTextButton;
            }
         }
      }
      
      private function get manager() : PumpkinPartyInnovationManager
      {
         return PumpkinPartyInnovationManager.getInstance();
      }
      
      override public function close() : void
      {
         super.close();
      }
   }
}


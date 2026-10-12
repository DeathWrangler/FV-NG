package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Managers.JMInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   
   public class JMIOnClickTileWindow extends FarmWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODY_TF:String = "copy_tf";
      
      private static const INFOEA_MC:String = "infoEA_mc";
      
      private static const INFOGA_MC:String = "infoGA_mc";
      
      private static const ACCEPT_BT:String = "accept_bt";
      
      private static const CLOSE_BT:String = "close_bt";
      
      private var m_prereqName:String = "jungle_special_tile_prereq";
      
      private var m_featureBuilding:FeatureBuilding;
      
      private var m_clickedFromTile:Boolean;
      
      public function JMIOnClickTileWindow(building:FeatureBuilding, clickedFromTile:Boolean = false)
      {
         this.m_featureBuilding = building;
         this.m_clickedFromTile = clickedFromTile;
         var windowURL:String = "";
         if(this.m_featureBuilding.getItem().getDialogConfig("storage"))
         {
            windowURL = this.m_featureBuilding.getItem().getDialogConfig("storage").path;
         }
         super(windowURL,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow[ACCEPT_BT])
            {
               if(PrerequisiteUtility.checkPrereqByName(this.m_prereqName))
               {
                  addWidget(new FarmAnimatedTextButton(m_window.mainWindow[ACCEPT_BT],ZLocUtils.t_pk("Dialogs","Unlock"),this.unlockTileAndOpenUI));
               }
               else
               {
                  addWidget(new FarmAnimatedTextButton(m_window.mainWindow[ACCEPT_BT],ZLocUtils.t_pk("Dialogs","MOTD_JMInnovation_GA_ButtonText"),onClose));
               }
            }
            if(m_window.mainWindow[TITLE_TF])
            {
               addWidget(new FarmTextField(m_window.mainWindow[TITLE_TF],ZLocUtils.t_pk("Dialogs","MOTD_JMInnovation_GA_Title")));
            }
            if(m_window.mainWindow[BODY_TF])
            {
               addWidget(new FarmTextField(m_window.mainWindow[BODY_TF],ZLocUtils.t_pk("Dialogs","MOTD_JMInnovation_GA_Text")));
            }
            if(m_window.mainWindow[CLOSE_BT])
            {
               addWidget(new FarmButton(m_window.mainWindow[CLOSE_BT],onClose));
            }
            if(m_window.mainWindow[INFOEA_MC])
            {
               addWidget(new ZwBaseWidget(m_window.mainWindow[INFOEA_MC]),false);
            }
            if(m_window.mainWindow[INFOGA_MC])
            {
               addWidget(new ZwBaseWidget(m_window.mainWindow[INFOGA_MC]));
            }
         }
      }
      
      private function unlockTileAndOpenUI(e:Event = null) : void
      {
         JMInnovationManager.getInstance().UnlockTileAndPanToBuilding(null);
         super.close();
      }
   }
}


package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.util.ZLocUtils;
   import Managers.JMInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class JMInnovationGrantPopupWindow extends FarmWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODY_TF:String = "body_tf";
      
      private static const ACCEPT_BT:String = "accept_bt";
      
      private static const CLOSE_BT:String = "close_bt";
      
      private static const ANIMATION:String = "animation_mc";
      
      private static const INNOVATION_MC:String = "innovation_mc";
      
      private var m_featureName:String;
      
      private var m_animationMc:MovieClip;
      
      private var m_innovationMc:ZwFrame;
      
      private const TEXT_TITLE:String = "_title";
      
      private const TEXT_BODY:String = "_BodyText";
      
      public function JMInnovationGrantPopupWindow(windowAssetRelUrl:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var isEA:Boolean = false;
         var gemsCount:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow[ACCEPT_BT])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow[ACCEPT_BT],ZLocUtils.t_pk("Dialogs","CheckItOut"),this.unlockTileAndOpenUI));
            }
            if(m_window.mainWindow[TITLE_TF])
            {
               addWidget(new FarmTextField(m_window.mainWindow[TITLE_TF],ZLocUtils.t_pk("Dialogs",this.m_featureName + this.TEXT_TITLE)));
            }
            if(m_window.mainWindow[BODY_TF])
            {
               addWidget(new FarmTextField(m_window.mainWindow[BODY_TF],ZLocUtils.t_pk("Dialogs",this.m_featureName + this.TEXT_BODY)));
            }
            if(m_window.mainWindow[CLOSE_BT])
            {
               addWidget(new FarmButton(m_window.mainWindow[CLOSE_BT],onClose),false);
            }
            if(m_window.mainWindow[ANIMATION])
            {
               this.m_animationMc = m_window.mainWindow[ANIMATION] as MovieClip;
               this.m_animationMc.visible = true;
               this.m_animationMc.play();
            }
            if(m_window.mainWindow[INNOVATION_MC])
            {
               addWidget(this.m_innovationMc = new ZwFrame(m_window.mainWindow[INNOVATION_MC]),false);
               isEA = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_JUNGLE);
               if(!isEA)
               {
                  gemsCount = JMInnovationManager.getInstance().gemConsumableInInventory;
                  if(gemsCount)
                  {
                     this.m_innovationMc.visible = true;
                     this.m_innovationMc.element.count_tf.text = "x" + JMInnovationManager.getInstance().gemConsumableInInventory;
                  }
               }
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


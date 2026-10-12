package Widgets.Windows.CompletionPack
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.BuildableCompletionPackagesManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class BuildableCompletionPackIntermediateWindow extends FarmWindow
   {
      
      private static const XAU_COMPLETION_PACK_INTERMEDIATE_WINDOW_ASSET:String = "assets/dialogs/xau_completionPack_motd.swf";
      
      private static const COMPLETION_PACK_INTERMEDIATE_WINDOW_ASSET:String = "assets/dialogs/Candy/FV_xcw_motd_completionPack.swf";
      
      private var m_optionsInfo:Array = null;
      
      public function BuildableCompletionPackIntermediateWindow(optionsInfo:Array)
      {
         this.m_optionsInfo = optionsInfo;
         var currentTime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         Global.player.setFeatureLastShown(BuildableCompletionPackagesManager.COMPLETION_PACK_FEATURE_NAME,currentTime,true);
         FarmStatsManager.count("MOTD","impressions",BuildableCompletionPackagesManager.INTERMEDIATE_WINDOW_STAT);
         super(COMPLETION_PACK_INTERMEDIATE_WINDOW_ASSET);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window)
         {
            if(m_window.hasOwnProperty("mainWindow"))
            {
               addWidget(new ZwBaseWidget(m_window.mainWindow));
               if(m_window.mainWindow.hasOwnProperty("accept_bt"))
               {
                  addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t_pk("Dialogs","LearnMore"),this.onAccept));
               }
               if(m_window.mainWindow.hasOwnProperty("title_tf"))
               {
                  addWidget(new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","completion_pack_intermediate_window_title")));
               }
               if(m_window.mainWindow.hasOwnProperty("body_tf"))
               {
                  addWidget(new ZwTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","completion_pack_intermediate_window_body")));
               }
            }
         }
         super.postLoadComplete();
      }
      
      private function onAccept(event:MouseEvent) : void
      {
         FarmStatsManager.count("MOTD","clicks",BuildableCompletionPackagesManager.INTERMEDIATE_WINDOW_STAT);
         close();
         BuildableCompletionPackagesManager.getInstance().displayMainWindow();
      }
   }
}


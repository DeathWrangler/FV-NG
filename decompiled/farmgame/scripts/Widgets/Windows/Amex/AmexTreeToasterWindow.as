package Widgets.Windows.Amex
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.AutoCloseToasterWindow;
   import flash.events.MouseEvent;
   
   public class AmexTreeToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_SERVEtree_Toaster.swf";
      
      public function AmexTreeToasterWindow()
      {
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         FarmStatsManager.count("serve_tree","harvest_custom_toaster","view");
         addWidget(new ZwButton(m_window.hitbox_mc,this.onHitBoxClick));
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","amextree_toaster_title")));
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","amextree_toaster_body")));
         if(m_window.hasOwnProperty("treeYellow_mc"))
         {
            addWidget(new ZwBaseWidget(m_window.treeYellow_mc));
         }
         Global.player.setFeatureLastShown("amextreeLastUpgrade",GlobalEngine.serverTime,true);
      }
      
      protected function onHitBoxClick(event:MouseEvent) : void
      {
         FarmStatsManager.count("serve_tree","harvest_custom_toaster","click");
         if(event != null)
         {
            event.stopPropagation();
         }
         close();
      }
   }
}


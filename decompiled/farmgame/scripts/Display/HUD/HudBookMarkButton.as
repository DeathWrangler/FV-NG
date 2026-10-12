package Display.HUD
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.BookmarkOpt2019InstallWindow;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class HudBookMarkButton extends ZwAbstractWindow
   {
      
      private static const X_POSITION:Number = 560;
      
      private static const Y_POSITION:Number = 40;
      
      private static const HUD_MC:String = "hud_mc";
      
      private var m_hudText:ZwTextField;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var FIRST_TIME_HUD_CLICK:String = "First_time_hud_click";
      
      private var m_featureName:String;
      
      private var m_iconMc:FarmIcon;
      
      private var m_notifText:ZwTextField;
      
      private var m_notifMC:MovieClip;
      
      private var m_highLightMC:MovieClip;
      
      public function HudBookMarkButton(assetPath:String, featureName:String)
      {
         super(Global.getAssetURL(assetPath));
         this.m_featureName = featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         var description:String = null;
         super.postLoadComplete();
         this.x = X_POSITION;
         this.y = Y_POSITION;
         if(m_window.hasOwnProperty(HUD_MC))
         {
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_window[HUD_MC],this.openUI),true);
            description = ZLocUtils.t("Dialogs",this.m_featureName + "_hudOnHover");
            this.m_hudButton.attachTooltip(new FarmTextTooltip("Bookmark FarmVille"));
            if(m_window[HUD_MC].hasOwnProperty("hud_tf"))
            {
               this.m_hudText = new ZwTextField(m_window[HUD_MC].hud_tf,"Bookmark FarmVille");
               addWidget(this.m_hudText);
               this.m_hudText.visible = true;
            }
            if(m_window[HUD_MC].hasOwnProperty("notif_mc"))
            {
               this.m_notifMC = m_window[HUD_MC]["notif_mc"] as MovieClip;
               this.m_notifMC.visible = false;
            }
         }
         this.visible = true;
      }
      
      public function releaseHud() : void
      {
         super.release();
      }
      
      override protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         return LoadingManager.load(url,onLoadCallback,LoadingManager.PRIORITY_HIGH);
      }
      
      private function openUI(fevent:Event) : void
      {
         StatsManager.count(this.m_featureName,"","click");
         if(!Global.player.getSeenFlag(this.FIRST_TIME_HUD_CLICK))
         {
            Global.player.setSeenFlag(this.FIRST_TIME_HUD_CLICK);
         }
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("fv_bookmarkOpt");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            UI.displayPopup(new BookmarkOpt2019InstallWindow("assets/dialogs/dau_contingency/FV_motd_daucontingency_2019.swf"),false);
            this.refresh();
            FarmStatsManager.count("chrome_extension","HUD","clicks","chrome_extension");
         }
      }
      
      public function refresh() : void
      {
         if(!Global.player.getSeenFlag(this.FIRST_TIME_HUD_CLICK))
         {
            if(this.m_notifMC)
            {
               this.m_notifMC.visible = true;
            }
         }
         else if(this.m_notifMC)
         {
            this.m_notifMC.visible = false;
         }
      }
   }
}


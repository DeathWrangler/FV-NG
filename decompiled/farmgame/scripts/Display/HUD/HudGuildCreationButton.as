package Display.HUD
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class HudGuildCreationButton extends ZwAbstractWindow
   {
      
      private static const X_POSITION:Number = 560;
      
      private static const Y_POSITION:Number = 40;
      
      private static const HUD_MC:String = "hud_mc";
      
      private var m_hudText:ZwTextField;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_featureName:String;
      
      private var m_iconMc:FarmIcon;
      
      private var m_notifText:ZwTextField;
      
      private var m_notifMC:MovieClip;
      
      private var m_highLightMC:MovieClip;
      
      public function HudGuildCreationButton(assetPath:String, featureName:String)
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
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_window[HUD_MC],this.handleGuildButtonClick),true);
            description = ZLocUtils.t("Dialogs",this.m_featureName + "_hudOnHover");
            this.m_hudButton.attachTooltip(new FarmTextTooltip("Farmers Clan"));
            this.m_hudButton.addEventListener(MouseEvent.MOUSE_OVER,this.hideHighLigtMC);
            if(m_window[HUD_MC].hasOwnProperty("hud_tf"))
            {
               this.m_hudText = new ZwTextField(m_window[HUD_MC].hud_tf,"Farmers Clan");
               addWidget(this.m_hudText);
               this.m_hudText.visible = true;
            }
            if(m_window[HUD_MC].hasOwnProperty("notif_tf"))
            {
               this.m_notifText = new ZwTextField(m_window[HUD_MC].notif_tf,"");
               addWidget(this.m_notifText);
               this.m_notifText.visible = false;
            }
            if(m_window[HUD_MC].hasOwnProperty("notif_mc"))
            {
               this.m_notifMC = m_window[HUD_MC]["notif_mc"] as MovieClip;
               this.m_notifMC.visible = false;
            }
            if(m_window[HUD_MC].hasOwnProperty("highlight_mc"))
            {
               this.m_highLightMC = m_window[HUD_MC]["highlight_mc"] as MovieClip;
               this.m_highLightMC.play();
               this.m_highLightMC.visible = false;
            }
            if(m_window[HUD_MC].hasOwnProperty("icon_mc"))
            {
               addWidget(this.m_iconMc = new FarmIcon(m_window[HUD_MC]["icon_mc"]));
               this.m_iconMc.visible = true;
               this.m_iconMc.loadIcon("assets/dialogs/Coop2019/FV_hudicon_Coop2019.png");
               this.m_iconMc.setIconSize(20,20);
               this.m_iconMc.setSmoothing(true);
            }
         }
         this.visible = true;
      }
      
      public function hideHighLigtMC(event:MouseEvent) : void
      {
         this.m_highLightMC.visible = false;
      }
      
      override protected function release() : void
      {
         m_window.removeEventListener(MouseEvent.MOUSE_DOWN,this.handleGuildButtonClick);
         super.release();
      }
      
      override protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         return LoadingManager.load(url,onLoadCallback,LoadingManager.PRIORITY_HIGH);
      }
      
      private function handleGuildButtonClick(e:MouseEvent) : void
      {
         StatsManager.count(this.m_featureName,"HudClick","click");
         GuildManager.getInstance().showUI();
         this.setDefaultTextAndIcon();
      }
      
      public function set hudText(text:String) : void
      {
         if(Boolean(this.m_hudText) && Boolean(this.m_notifText) && Boolean(this.m_notifMC))
         {
            this.m_notifText.visible = false;
            this.m_hudText.visible = true;
            this.m_hudText.text = text;
            this.m_notifMC.visible = false;
            this.m_highLightMC.visible = false;
         }
      }
      
      public function set notifText(text:String) : void
      {
         if(Boolean(this.m_hudText) && Boolean(this.m_notifText) && Boolean(this.m_notifMC))
         {
            this.m_hudText.visible = false;
            this.m_notifText.visible = true;
            this.m_notifText.text = text;
            this.m_notifMC.visible = true;
            this.m_highLightMC.visible = true;
            this.m_highLightMC.play();
         }
      }
      
      public function setDefaultTextAndIcon() : void
      {
         if(Boolean(this.m_hudText) && Boolean(this.m_notifText) && Boolean(this.m_notifMC))
         {
            this.m_notifText.visible = false;
            this.m_hudText.visible = true;
            GuildManager.getInstance().setDefaulHudText();
            this.m_notifMC.visible = false;
            this.m_highLightMC.visible = false;
         }
      }
      
      public function set iconType(iconType:String) : void
      {
         switch(iconType)
         {
            case "chat":
            case "notif":
         }
      }
      
      public function ishudTextVisible() : Boolean
      {
         return Boolean(this.m_hudText) && this.m_hudText.visible;
      }
   }
}


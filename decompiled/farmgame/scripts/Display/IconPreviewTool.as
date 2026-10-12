package Display
{
   import Managers.ToolModeManager;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwEventWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class IconPreviewTool extends FarmWindow
   {
      
      private var m_assetPath:String;
      
      private var m_icon:FarmIcon;
      
      private var m_icon_mc:MovieClip;
      
      public function IconPreviewTool(assetPath:String)
      {
         this.m_assetPath = ToolModeManager.getSaltAssetUrl(assetPath);
         super("assets/dialogs/FV_MasteryDialog_ArtTool.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwBaseWidget(m_window.smallIcon_mc));
         addWidget(new ZwBaseWidget(m_window.largeIcon_mc));
         this.m_icon_mc = new MovieClip();
         this.m_icon = new FarmIcon(this.m_icon_mc,this.m_assetPath);
         this.m_icon.addEventListener(ZwEventWidget.ICON_PREVIEW_EVENT_LISTENER,this.onIconLoaded);
         m_window.addChild(this.m_icon_mc);
      }
      
      protected function onIconLoaded(e:Event) : void
      {
         var xPos:Number = NaN;
         var yPos:Number = NaN;
         var xPosIcon:Number = NaN;
         var yPosIcon:Number = NaN;
         var iconHeight:Number = this.m_icon.getIconHeight();
         var iconWidth:Number = this.m_icon.getIconWidth();
         if(iconHeight > 100 || iconWidth > 100)
         {
            xPos = Number(m_window.largeIcon_mc.x);
            yPos = Number(m_window.largeIcon_mc.y);
            xPosIcon = Number(m_window.largeIcon_mc.icon_mc.x);
            yPosIcon = Number(m_window.largeIcon_mc.icon_mc.y);
         }
         else
         {
            xPos = Number(m_window.smallIcon_mc.x);
            yPos = Number(m_window.smallIcon_mc.y);
            xPosIcon = Number(m_window.smallIcon_mc.icon_mc.x);
            yPosIcon = Number(m_window.smallIcon_mc.icon_mc.y);
         }
         this.m_icon_mc.x = xPos + xPosIcon;
         this.m_icon_mc.y = yPos + yPosIcon;
         addWidget(new ZwTextField(m_window.goldTitle_tf,"height: " + iconHeight + ", width: " + iconWidth));
      }
   }
}


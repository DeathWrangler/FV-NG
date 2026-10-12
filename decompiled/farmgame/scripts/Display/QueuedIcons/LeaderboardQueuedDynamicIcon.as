package Display.QueuedIcons
{
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   
   public class LeaderboardQueuedDynamicIcon extends LeaderboardQueuedIcon
   {
      
      public static const DYNAMIC_ICON_NAME:String = "LeaderboardDynamicIcon";
      
      public function LeaderboardQueuedDynamicIcon(xml:XML)
      {
         super(xml);
      }
      
      override protected function injectContent() : void
      {
         var contentMC:MovieClip = null;
         var farmIcon:FarmIcon = null;
         var loadedMC:MovieClip = m_Loader.content as MovieClip;
         if(Boolean(loadedMC) && loadedMC.hasOwnProperty("hud_attract_mc"))
         {
            contentMC = loadedMC.hud_attract_mc;
            farmIcon = new FarmIcon(contentMC);
            farmIcon.loadIcon(m_leaderboard.iconUrl);
            farmIcon.setIconSize(contentMC.width,contentMC.height);
            m_widgetManager.addWidget(farmIcon);
         }
      }
   }
}


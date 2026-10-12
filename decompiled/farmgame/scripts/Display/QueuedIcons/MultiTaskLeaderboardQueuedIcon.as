package Display.QueuedIcons
{
   import Display.CategorizedDynamicIconQueue;
   import Display.DynamicIconQueue;
   import Managers.LeaderboardManager;
   
   public class MultiTaskLeaderboardQueuedIcon extends LeaderboardQueuedIcon
   {
      
      public static const ICON_NAME:String = "MultiTaskLeaderboardIcon";
      
      public function MultiTaskLeaderboardQueuedIcon(xml:XML)
      {
         super(xml);
      }
      
      override public function init() : void
      {
         super.init();
         category = CategorizedDynamicIconQueue.ICON_TYPE_FEATURE;
      }
      
      override public function finishClick(parent:DynamicIconQueue) : void
      {
         super.finishClick(parent);
         LeaderboardManager.displayMultiTaskLeaderboardWindow();
      }
      
      override public function getIconTooltip() : String
      {
         return m_leaderboard.nameText;
      }
   }
}


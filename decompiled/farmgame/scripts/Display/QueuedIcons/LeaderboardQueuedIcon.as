package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.Leaderboard.Leaderboard;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.CategorizedDynamicIconQueue;
   import Display.DynamicIconQueue;
   import Managers.FarmStatsManager;
   import Managers.LeaderboardManager;
   import Managers.ReturningUserExperienceManager;
   
   public class LeaderboardQueuedIcon extends QueuedIconWithArrow
   {
      
      public static const DEFAULT_ICON_NAME:String = "LeaderboardGenericIcon";
      
      protected var m_leaderboard:Leaderboard;
      
      public function LeaderboardQueuedIcon(xml:XML)
      {
         super(xml);
      }
      
      override public function init() : void
      {
         this.m_leaderboard = extraData.leaderboard;
         iconName = this.m_leaderboard.name;
         category = CategorizedDynamicIconQueue.ICON_TYPE_LEADERBOARD;
         extraData["expirationTime"] = this.m_leaderboard.expirationTime;
         extraData["iconTooltip"] = this.getIconTooltip();
         super.init();
      }
      
      public function get leaderboard() : Leaderboard
      {
         return this.m_leaderboard;
      }
      
      public function getIconTooltip() : String
      {
         return ZLocUtils.t("Leaderboard","IconTooltip");
      }
      
      public function onAdd() : void
      {
         this.conditionallyAttachArrow();
         FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"impressions","hud_icon",this.m_leaderboard.name);
      }
      
      public function onExpired() : void
      {
      }
      
      override public function finishClick(parent:DynamicIconQueue) : void
      {
         super.finishClick(parent);
         LeaderboardManager.markAsSeen(this.m_leaderboard.name);
         if(!this.m_leaderboard.isMultitask)
         {
            LeaderboardManager.displayLeaderboardWindow();
         }
         FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"clicks","hud_icon",this.m_leaderboard.name);
      }
      
      override public function attachArrow(arrowType:ArrowType, shouldPersistUntilClick:Boolean = false) : void
      {
         var days:Number = NaN;
         var daysString:String = null;
         switch(arrowType)
         {
            case ArrowType.ARROWEXPIRY:
               days = Math.ceil(this.m_leaderboard.timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
               daysString = FarmGameUtil.getTimeLeftTextInDays(days);
               if(days == 1)
               {
                  daysString = ZLocUtils.t("Dialogs","ExpiringToday");
               }
               setArrowText(daysString);
               break;
            case ArrowType.ARROWNEW:
               setArrowText(ZLocUtils.t("Dialogs","NewGoals"));
               break;
            case ArrowType.ARROWUPDATE:
               setArrowText(ZLocUtils.t("Dialogs","Progress"));
         }
         super.attachArrow(arrowType,shouldPersistUntilClick);
      }
      
      public function conditionallyAttachArrow() : void
      {
         if(this.m_leaderboard.isExpiringSoon)
         {
            this.attachArrow(ArrowType.ARROWEXPIRY);
         }
         else if(this.m_leaderboard.isNew)
         {
            this.attachArrow(ArrowType.ARROWNEW);
         }
      }
      
      override protected function canShowArrow() : Boolean
      {
         var result:Boolean = false;
         if(!ReturningUserExperienceManager.shouldHideArrowFlyout("cadence"))
         {
            result = super.canShowArrow();
         }
         return result;
      }
   }
}


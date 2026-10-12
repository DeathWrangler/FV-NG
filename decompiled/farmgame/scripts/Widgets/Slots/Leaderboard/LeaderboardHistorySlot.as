package Widgets.Slots.Leaderboard
{
   import Classes.Leaderboard.Leaderboard;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LeaderboardManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Leaderboard.LeaderboardWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class LeaderboardHistorySlot extends ZwSlotFrame
   {
      
      private static const ACTIVE_FRAME:int = 2;
      
      private static const EXPIRED_FRAME:int = 1;
      
      private static const ICON_SIZE:int = 50;
      
      private var m_leaderboard:Leaderboard;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_rankLabelTextField:ZwTextField;
      
      private var m_rankTextField:ZwTextField;
      
      private var m_statusTextField:ZwTextField;
      
      private var m_summaryButton:FarmAnimatedTextButton;
      
      public function LeaderboardHistorySlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_tf," ")) as ZwTextField;
         this.m_rankLabelTextField = addWidget(new ZwTextField(m_element.numberTitle_tf,ZLocUtils.t("Leaderboard","Rank"))) as ZwTextField;
         this.m_rankTextField = addWidget(new ZwTextField(m_element.number_tf," ")) as ZwTextField;
         this.m_statusTextField = addWidget(new ZwTextField(m_element.indicator_tf,ZLocUtils.t("Leaderboard","CurrentLeaderboard"))) as ZwTextField;
         this.m_summaryButton = addWidget(new FarmAnimatedTextButton(m_element.summary_btn," ",this.onSummaryButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function populate(data:Object) : void
      {
         var rank:int = 0;
         var rankText:String = null;
         super.populate(data);
         this.m_leaderboard = data as Leaderboard;
         if(this.m_leaderboard)
         {
            this.m_icon.loadIcon(this.m_leaderboard.iconUrl);
            this.m_icon.visible = true;
            this.m_nameTextField.text = this.m_leaderboard.nameText;
            this.m_nameTextField.visible = true;
            rank = LeaderboardManager.getRank(this.m_leaderboard.name);
            rankText = rank > 0 ? String(rank) : "?";
            this.m_rankTextField.text = rankText;
            this.m_rankTextField.visible = true;
            this.m_rankLabelTextField.visible = true;
            if(this.m_leaderboard.isActive)
            {
               this.m_statusTextField.visible = true;
               this.m_summaryButton.text = ZLocUtils.t("Leaderboard","ViewProgress");
               (m_element as MovieClip).gotoAndStop(ACTIVE_FRAME);
            }
            else
            {
               this.m_statusTextField.visible = false;
               this.m_summaryButton.text = ZLocUtils.t("Leaderboard","ViewSummary");
               (m_element as MovieClip).gotoAndStop(EXPIRED_FRAME);
            }
            this.m_summaryButton.visible = true;
         }
      }
      
      override public function release() : void
      {
         this.m_leaderboard = null;
         this.m_icon = null;
         this.m_nameTextField = null;
         this.m_rankTextField = null;
         this.m_rankLabelTextField = null;
         this.m_statusTextField = null;
         this.m_summaryButton = null;
         super.release();
      }
      
      private function onSummaryButtonClick(event:MouseEvent) : void
      {
         var window:LeaderboardWindow = null;
         if(this.m_leaderboard.isActive)
         {
            window = getAncestorByClassType(LeaderboardWindow) as LeaderboardWindow;
            if(window)
            {
               window.showTab(this.m_leaderboard.name);
            }
         }
         else
         {
            LeaderboardManager.displayLeaderboardSummaryWindow(this.m_leaderboard);
            FarmStatsManager.featureSample(LeaderboardManager.STAT_COUNTER,"clicks","summary_dialog",this.m_leaderboard.name);
         }
      }
   }
}


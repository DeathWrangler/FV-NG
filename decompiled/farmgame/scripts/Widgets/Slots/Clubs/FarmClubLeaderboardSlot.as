package Widgets.Slots.Clubs
{
   import Cache.Classes.ZCacheUtil;
   import Classes.util.ZLocUtils;
   import Managers.Clubs.DataObjects.FarmClub;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Clubs.FarmClubWindow2;
   import flash.display.DisplayObject;
   
   public class FarmClubLeaderboardSlot extends ZwSlotFrame
   {
      
      private var m_window:FarmClubWindow2;
      
      private var m_slotButton:FarmAnimatedButton = null;
      
      private var m_rankText:ZwTextField = null;
      
      private var m_nameText:ZwTextField = null;
      
      private var m_harvestAmount:ZwTextField = null;
      
      private var m_detailText:ZwTextField = null;
      
      private var m_bonusText:ZwTextField = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_badgeIcon:FarmIcon = null;
      
      private var m_highlight:ZwWidget = null;
      
      private var m_userClub:FarmClub = null;
      
      public function FarmClubLeaderboardSlot(element:DisplayObject, userClub:FarmClub = null, window:FarmClubWindow2 = null)
      {
         super(element);
         this.m_window = window;
         if(m_element.hasOwnProperty("hit_bt"))
         {
            this.m_slotButton = addWidget(new FarmAnimatedButton(m_element.hit_bt),true) as FarmAnimatedButton;
         }
         if(m_element.hasOwnProperty("clubRank_tf"))
         {
            this.m_rankText = addWidget(new ZwTextField(m_element.clubRank_tf)) as ZwTextField;
         }
         if(m_element.hasOwnProperty("clubName_tf"))
         {
            this.m_nameText = addWidget(new ZwTextField(m_element.clubName_tf)) as ZwTextField;
         }
         if(m_element.hasOwnProperty("harvestAmount_tf"))
         {
            this.m_harvestAmount = addWidget(new ZwTextField(m_element.harvestAmount_tf)) as ZwTextField;
         }
         if(m_element.hasOwnProperty("detail_tf"))
         {
            this.m_detailText = addWidget(new ZwTextField(m_element.detail_tf)) as ZwTextField;
         }
         if(m_element.hasOwnProperty("bonus_tf"))
         {
            this.m_bonusText = addWidget(new ZwTextField(m_element.bonus_tf)) as ZwTextField;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         }
         if(m_element.hasOwnProperty("badgeIcon_mc"))
         {
            this.m_badgeIcon = addWidget(new FarmIcon(m_element.badgeIcon_mc)) as FarmIcon;
         }
         if(m_element.hasOwnProperty("highlightBG_mc"))
         {
            this.m_highlight = addWidget(new ZwWidget(m_element.highlightBG_mc)) as ZwWidget;
         }
         this.m_userClub = userClub;
      }
      
      override public function populate(data:Object) : void
      {
         var rank:String = null;
         if(this.m_rankText != null)
         {
            this.m_rankText.text = data.rank;
            this.m_rankText.visible = true;
         }
         if(this.m_nameText != null)
         {
            if(data.clubName)
            {
               this.m_nameText.text = data.clubName;
               if(this.m_window != null && this.m_slotButton != null)
               {
                  this.m_slotButton.callback = ZCacheUtil.applyPartial(this.m_window.clubClickCallback,this,[data.clubId]);
                  this.m_slotButton.visible = true;
                  this.m_slotButton.detachTooltip();
                  this.m_slotButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("FarmClub","SlotButtonRollover")));
               }
            }
            else if(Boolean(data.friendInfo) && Boolean(data.friendInfo.first_name))
            {
               this.m_nameText.text = data.friendInfo.first_name;
            }
            this.m_nameText.visible = true;
         }
         if(this.m_harvestAmount != null)
         {
            this.m_harvestAmount.text = ZLocUtils.t("FarmClub","numHarvests",{"num":data.score});
            this.m_harvestAmount.visible = true;
         }
         if(this.m_icon != null)
         {
            if(data.clubLogoId)
            {
               this.m_icon.loadIcon(FarmClubUtility.getBackgroundLogoPathFromId(data.clubLogoId));
            }
            else if(Boolean(data.friendInfo) && Boolean(data.friendInfo.pic_square))
            {
               this.m_icon.loadIcon(data.friendInfo.pic_square);
            }
            this.m_icon.visible = true;
            this.m_icon.setIconScale(1,1);
            this.m_icon.setIconSize(50,50);
         }
         if(Boolean(this.m_userClub != null) && Boolean(data.friendInfo) && Boolean(data.friendInfo.uid))
         {
            rank = this.m_userClub.getRankOfMember(data.friendInfo.uid);
            if(rank != FarmClub.CLUB_MEMBERSHIP_MEMBER)
            {
               if(this.m_badgeIcon != null)
               {
                  this.m_badgeIcon.loadIcon(FarmClubUtility.getBadgePathForClubRank(rank));
                  this.m_badgeIcon.setIconSize(20,20);
                  this.m_badgeIcon.visible = true;
               }
               if(this.m_detailText != null)
               {
                  this.m_detailText.text = ZLocUtils.t("FarmClub",rank + "RankTitle");
                  this.m_detailText.visible = true;
               }
            }
            if(Boolean(Global.flashHotParams["SHOW_CLUBS_ONE_MULTIPLIER"]) || rank != FarmClub.CLUB_MEMBERSHIP_MEMBER)
            {
               if(this.m_bonusText != null)
               {
                  this.m_bonusText.text = ZLocUtils.t("FarmClub","scoreMultiplier",{"num":FarmClubUtility.getScoreMultiplierForClubRank(rank).toString()});
                  this.m_bonusText.visible = true;
               }
            }
            if(data.friendInfo.uid == Global.player.uid)
            {
               if(this.m_highlight != null)
               {
                  this.m_highlight.visible = true;
               }
               if(!Global.player.getSeenSessionFlag("Clubs_Roster_Rank") && this.m_userClub.clubId != null)
               {
                  Global.player.setSeenSessionFlag("Clubs_Roster_Rank",true);
                  FarmStatsManager.count("club_individual","Clubs",this.m_userClub.clubId.toString(),"roster_rank",data.rank);
               }
            }
         }
         if(this.m_highlight != null && data.clubId == FarmClubDataManager.getInstance().clubId)
         {
            this.m_highlight.visible = true;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_badgeIcon = null;
         this.m_icon = null;
         this.m_highlight = null;
         this.m_harvestAmount = null;
         this.m_rankText = null;
         this.m_nameText = null;
         this.m_userClub = null;
         this.m_slotButton = null;
      }
      
      public function setUserClub(club:FarmClub) : void
      {
         this.m_userClub = club;
      }
   }
}


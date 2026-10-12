package Widgets.Slots.Clubs
{
   import Classes.util.ZLocUtils;
   import Managers.Clubs.DataObjects.FarmClub;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class MyClubSlot extends ZwSlotFrame
   {
      
      private const CLUB_LOGO_ICON_SIZE:int = 50;
      
      private const FB_ICON_SIZE:int = 50;
      
      private const BADGE_OFFSET:int = -10;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_rankTextField:ZwTextField;
      
      private var m_scoreTextField:ZwTextField;
      
      private var m_multiplierTextField:ZwTextField;
      
      private var m_clubId:String;
      
      private var m_uid:String;
      
      private var m_promoteButton:FarmAnimatedTextButton;
      
      private var m_rankTitle:String;
      
      private var m_badgeIcon:FarmIcon;
      
      private var m_highlight:ZwWidget;
      
      private var m_rankTitleTextField:ZwTextField;
      
      private var m_rankNameTextField:ZwTextField;
      
      public function MyClubSlot(element:DisplayObject)
      {
         super(element);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_tf,"")) as ZwTextField;
         this.m_rankTextField = addWidget(new ZwTextField(m_element.rank_tf,"")) as ZwTextField;
         this.m_scoreTextField = addWidget(new ZwTextField(m_element.score_tf,"")) as ZwTextField;
         this.m_multiplierTextField = addWidget(new ZwTextField(m_element.totalMultiplier_tf)) as ZwTextField;
         this.m_icon = addWidget(new FarmIcon(m_element.logo_mc)) as FarmIcon;
         this.m_badgeIcon = addWidget(new FarmIcon(m_element.badge_mc)) as FarmIcon;
         this.m_badgeIcon.visible = false;
         this.m_promoteButton = addWidget(new FarmAnimatedTextButton(m_element.promote_bt,"",this.onPromoteDemote)) as FarmAnimatedTextButton;
         this.m_highlight = addWidget(new ZwWidget(m_element.highlight_mc)) as ZwWidget;
         this.m_highlight.visible = false;
         this.m_rankTitleTextField = addWidget(new ZwTextField(m_element.rankTITLE_tf,ZLocUtils.t("FarmClub","Rank"))) as ZwTextField;
         this.m_rankNameTextField = addWidget(new ZwTextField(m_element.rankName_tf,"")) as ZwTextField;
      }
      
      override public function populate(data:Object) : void
      {
         var logoAssetPath:String = null;
         var farmClubData:FarmClubDataObject = null;
         var multiplier:int = 0;
         var badgePath:String = null;
         var tierSlots:int = 0;
         var numMembers:int = 0;
         super.populate(data);
         this.m_clubId = data["clubId"];
         if(FarmClubDataManager.getInstance().clubId == this.m_clubId)
         {
            this.m_highlight.visible = true;
         }
         else
         {
            this.m_highlight.visible = false;
         }
         if(data["clubName"])
         {
            this.m_nameTextField.text = data["clubName"];
            this.m_nameTextField.visible = true;
         }
         if(Boolean(data["friendInfo"]) && Boolean(data["friendInfo"]["name"]))
         {
            this.m_nameTextField.text = data["friendInfo"]["name"];
            this.m_nameTextField.visible = true;
         }
         if(Boolean(data["friendInfo"]) && Boolean(data["friendInfo"]["pic_square"]))
         {
            this.m_icon.loadIcon(data["friendInfo"]["pic_square"]);
            this.m_icon.clearDimensions();
            this.m_icon.setIconSize(this.FB_ICON_SIZE,this.FB_ICON_SIZE);
            this.m_icon.visible = true;
         }
         if(data["rank"])
         {
            this.m_rankTextField.text = FarmClubUtility.formatRank(parseInt(data["rank"]));
            this.m_rankTextField.visible = true;
         }
         if(data["score"])
         {
            this.m_scoreTextField.text = data["score"];
            this.m_scoreTextField.visible = true;
         }
         if(data["clubLogoId"])
         {
            logoAssetPath = FarmClubUtility.getLogoPathFromId(parseInt(data["clubLogoId"]));
            this.m_icon.loadIcon(logoAssetPath);
            this.m_icon.clearDimensions();
            this.m_icon.setIconSize(this.CLUB_LOGO_ICON_SIZE,this.CLUB_LOGO_ICON_SIZE);
            this.m_icon.visible = true;
         }
         if(Boolean(data["friendInfo"]) && Boolean(data["friendInfo"]["uid"]))
         {
            this.m_uid = data["friendInfo"] && data["friendInfo"]["uid"];
            if(Global.player.uid.toString() == this.m_uid)
            {
               this.m_highlight.visible = true;
            }
            else
            {
               this.m_highlight.visible = false;
            }
            farmClubData = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
            if(Boolean(farmClubData) && Boolean(farmClubData.farmClub))
            {
               this.m_rankTitle = farmClubData.farmClub.getRankOfMember(this.m_uid);
               this.m_rankNameTextField.text = ZLocUtils.t("FarmClub",this.m_rankTitle);
               this.m_rankNameTextField.visible = true;
               this.m_rankTitleTextField.text = ZLocUtils.t("FarmClub","Rank");
               this.m_rankTitleTextField.visible = true;
               if(farmClubData.farmClub.getLeader() == String(Global.player.uid))
               {
                  tierSlots = FarmClubUtility.getNumOfficersForTier(farmClubData.farmClub.currentTier);
                  numMembers = farmClubData.farmClub.members[FarmClub.CLUB_MEMBERSHIP_OFFICER] ? int((farmClubData.farmClub.members[FarmClub.CLUB_MEMBERSHIP_OFFICER] as Array).length) : 0;
                  if(this.canPromote(this.m_rankTitle))
                  {
                     this.m_promoteButton.text = "Promote";
                     this.m_promoteButton.visible = true;
                     this.m_promoteButton.enabled = tierSlots > numMembers;
                  }
                  else if(this.m_rankTitle == FarmClub.CLUB_MEMBERSHIP_OFFICER)
                  {
                     this.m_promoteButton.text = "Demote";
                     this.m_promoteButton.visible = true;
                  }
               }
               multiplier = FarmClubUtility.getScoreMultiplierForClubRank(this.m_rankTitle);
               badgePath = FarmClubUtility.getBadgePathForClubRank(this.m_rankTitle);
               this.m_badgeIcon.loadIcon(badgePath);
               this.m_badgeIcon.visible = true;
               this.m_badgeIcon.y = this.BADGE_OFFSET;
               this.m_multiplierTextField.text = ZLocUtils.t("FarmClub","MyClub_MultiplierText",{"value":multiplier});
               this.m_multiplierTextField.visible = true;
            }
         }
      }
      
      private function onPromoteDemote(event:MouseEvent) : void
      {
         this.m_promoteButton.visible = false;
         var farmClubData:FarmClubDataObject = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
         if(this.canPromote(this.m_rankTitle))
         {
            FarmClubUtility.promoteMemberToOfficer(this.m_uid,null);
            if(farmClubData != null)
            {
               farmClubData.farmClub.promoteMemberToOfficer(this.m_uid);
            }
         }
         else
         {
            FarmClubUtility.demoteOfficerToMember(this.m_uid,null);
            if(farmClubData != null)
            {
               farmClubData.farmClub.demoteOfficerToMember(this.m_uid);
            }
         }
      }
      
      private function canPromote(rankTitle:String) : Boolean
      {
         return rankTitle != FarmClub.CLUB_MEMBERSHIP_LEADER && rankTitle != FarmClub.CLUB_MEMBERSHIP_OFFICER;
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_scoreTextField = null;
         this.m_nameTextField = null;
         this.m_rankTextField = null;
         this.m_multiplierTextField = null;
         super.release();
      }
   }
}


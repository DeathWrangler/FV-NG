package Widgets.Slots.Clubs
{
   import Classes.util.ZLocUtils;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class TopFarmersSlot extends ZwSlotFrame
   {
      
      private const BADGE_OFFSET:int = -10;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_rankTextField:ZwTextField;
      
      private var m_scoreTextField:ZwTextField;
      
      private var m_clubId:String;
      
      private var m_multiplierTextField:ZwTextField;
      
      private var m_rankTitle:String;
      
      private var m_badgeIcon:FarmIcon;
      
      private var m_rankNameTextField:ZwTextField;
      
      private var m_rankTitleTextField:ZwTextField;
      
      public function TopFarmersSlot(element:DisplayObject)
      {
         super(element);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_tf,"")) as ZwTextField;
         this.m_rankTextField = addWidget(new ZwTextField(m_element.rank_tf,"")) as ZwTextField;
         this.m_scoreTextField = addWidget(new ZwTextField(m_element.score_tf,"")) as ZwTextField;
         this.m_multiplierTextField = addWidget(new ZwTextField(m_element.totalMultiplier_tf,"")) as ZwTextField;
         this.m_icon = addWidget(new FarmIcon(m_element.logo_mc)) as FarmIcon;
         this.m_badgeIcon = addWidget(new FarmIcon(m_element.badge_mc)) as FarmIcon;
         this.m_badgeIcon.visible = false;
         this.m_rankTitleTextField = addWidget(new ZwTextField(m_element.rankTITLE_tf,ZLocUtils.t("FarmClub","Rank"))) as ZwTextField;
         this.m_rankNameTextField = addWidget(new ZwTextField(m_element.rankName_tf,"")) as ZwTextField;
      }
      
      override public function populate(data:Object) : void
      {
         var uid:String = null;
         var clubData:FarmClubDataObject = null;
         var multiplier:int = 0;
         var badgePath:String = null;
         super.populate(data);
         if(data["friendInfo"])
         {
            if(data.friendInfo.hasOwnProperty("name"))
            {
               this.m_nameTextField.text = data.friendInfo.name;
               this.m_nameTextField.visible = true;
            }
            if(data.friendInfo.hasOwnProperty("pic_square"))
            {
               this.m_icon.loadIcon(data.friendInfo.pic_square);
               this.m_icon.setIconSize(50,50);
               this.m_icon.visible = true;
            }
         }
         if(Boolean(data["friendInfo"]) && Boolean(data["friendInfo"]["uid"]))
         {
            uid = data["friendInfo"] && data["friendInfo"]["uid"];
            if(data["clubData"])
            {
               clubData = data["clubData"];
               if(Boolean(clubData) && Boolean(clubData.farmClub))
               {
                  this.m_rankTitleTextField.text = ZLocUtils.t("FarmClub","Rank");
                  this.m_rankTitleTextField.visible = true;
                  this.m_rankTitle = clubData.farmClub.getRankOfMember(uid);
                  this.m_rankNameTextField.text = this.m_rankTitle;
                  this.m_rankNameTextField.visible = true;
                  this.m_multiplierTextField.text = ZLocUtils.t("FarmClub","MyClub_MultiplierText",{"value":FarmClubUtility.getScoreMultiplierForClubRank(this.m_rankTitle)});
                  this.m_multiplierTextField.visible = true;
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


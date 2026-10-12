package Widgets.Slots.Clubs
{
   import Classes.util.ZLocUtils;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class Top50ClubSlot extends ZwSlotFrame
   {
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_rankTextField:ZwTextField;
      
      private var m_scoreTextField:ZwTextField;
      
      private var m_joinButton:FarmAnimatedTextButton;
      
      private var m_clubId:String;
      
      public function Top50ClubSlot(element:DisplayObject)
      {
         super(element);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_tf,"")) as ZwTextField;
         this.m_rankTextField = addWidget(new ZwTextField(m_element.rank_tf,"")) as ZwTextField;
         this.m_scoreTextField = addWidget(new ZwTextField(m_element.score_tf,"")) as ZwTextField;
         this.m_joinButton = addWidget(new FarmAnimatedTextButton(m_element.join_bt,ZLocUtils.t("FarmClub","Join"),this.onJoin)) as FarmAnimatedTextButton;
         this.m_icon = addWidget(new FarmIcon(m_element.logo_mc)) as FarmIcon;
      }
      
      override public function populate(data:Object) : void
      {
         var iconUrl:String = null;
         var logoAssetPath:String = null;
         super.populate(data);
         this.m_joinButton.visible = true;
         this.m_clubId = data["clubId"];
         if(data["clubName"])
         {
            this.m_nameTextField.text = data["clubName"];
            this.m_nameTextField.visible = true;
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
         if(data["isPrivate"] == true)
         {
            this.m_joinButton.enabled = false;
            this.m_joinButton.text = ZLocUtils.t("FarmClub","private");
         }
         if(data["clubLogoId"])
         {
            logoAssetPath = FarmClubUtility.getLogoPathFromId(parseInt(data["clubLogoId"]));
            this.m_icon.loadIcon(logoAssetPath);
            this.m_icon.setIconSize(50,50);
            this.m_icon.visible = true;
         }
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_scoreTextField = null;
         this.m_nameTextField = null;
         this.m_rankTextField = null;
         this.m_joinButton = null;
         super.release();
      }
      
      private function onJoin(event:MouseEvent) : void
      {
         FarmClubUtility.canJoinClub(this.m_clubId,this.canJoinClubCallback);
      }
      
      private function canJoinClubCallback(result:Boolean) : void
      {
         if(result)
         {
            this.m_joinButton.visible = false;
            FarmClubUtility.joinClub(this.m_clubId);
         }
      }
   }
}


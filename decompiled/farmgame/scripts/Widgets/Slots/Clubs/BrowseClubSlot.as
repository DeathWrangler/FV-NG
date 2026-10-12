package Widgets.Slots.Clubs
{
   import Classes.util.ZLocUtils;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class BrowseClubSlot extends ZwSlotFrame
   {
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_rankTextField:ZwTextField;
      
      private var m_acceptInviteButton:FarmAnimatedTextButton;
      
      private var m_joinButton:FarmAnimatedTextButton;
      
      private var m_clubId:String;
      
      private var m_harvestCount:ZwTextField;
      
      private var m_facepileIcons:Array = null;
      
      private var m_joinCallback:Function = null;
      
      public function BrowseClubSlot(element:DisplayObject, joinCallback:Function)
      {
         var newIcon:FarmIcon = null;
         super(element);
         this.m_joinCallback = joinCallback;
         this.m_nameTextField = addWidget(new ZwTextField(m_element.clubName_tf,"")) as ZwTextField;
         this.m_rankTextField = addWidget(new ZwTextField(m_element.clubRank_tf,"")) as ZwTextField;
         this.m_harvestCount = addWidget(new ZwTextField(m_element.harvestAmount_tf,"")) as ZwTextField;
         this.m_acceptInviteButton = addWidget(new FarmAnimatedTextButton(m_element.accept_bt,ZLocUtils.t("FarmClub","acceptInvite"),this.onJoin)) as FarmAnimatedTextButton;
         this.m_joinButton = addWidget(new FarmAnimatedTextButton(m_element.join_bt,ZLocUtils.t("FarmClub","Join"),this.onJoin)) as FarmAnimatedTextButton;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_facepileIcons = new Array();
         var faceIndex:int = 0;
         var iconName:String = "facePile_" + faceIndex + "_mc";
         while(m_element.hasOwnProperty(iconName))
         {
            newIcon = new FarmIcon(m_element[iconName]);
            addWidget(newIcon);
            this.m_facepileIcons.push(newIcon);
            faceIndex++;
            iconName = "facePile_" + faceIndex + "_mc";
         }
      }
      
      override public function populate(data:Object) : void
      {
         var logoAssetPath:String = null;
         var friendInfos:Array = null;
         var numIcons:int = 0;
         var faceIndex:int = 0;
         var icon:FarmIcon = null;
         super.populate(data);
         this.m_clubId = data.clubId;
         this.m_joinButton.visible = this.m_clubId != FarmClubDataManager.getInstance().clubId;
         if(data.clubName)
         {
            this.m_nameTextField.text = data["clubName"];
            this.m_nameTextField.visible = true;
         }
         if(Boolean(data.rank) && Boolean(data.currentTier))
         {
            this.m_rankTextField.text = ZLocUtils.t("FarmClub","rankTierTitle",{
               "rank":data.rank,
               "tier":data.currentTier
            });
            this.m_rankTextField.visible = true;
         }
         if(data.score)
         {
            this.m_harvestCount.text = ZLocUtils.t("FarmClub","numHarvests",{"num":data.score.toString()});
            this.m_harvestCount.visible = true;
         }
         if(data.isPrivate == false)
         {
            this.m_acceptInviteButton.visible = false;
            this.m_joinButton.visible = true;
         }
         if(data.hasInvite)
         {
            this.m_acceptInviteButton.visible = true;
            this.m_joinButton.visible = false;
         }
         if(data.clubLogoId)
         {
            logoAssetPath = FarmClubUtility.getBackgroundLogoPathFromId(parseInt(data.clubLogoId));
            this.m_icon.loadIcon(logoAssetPath);
            this.m_icon.setIconSize(70,70);
            this.m_icon.visible = true;
         }
         if(data.facepile)
         {
            friendInfos = data.facepile;
            numIcons = int(this.m_facepileIcons.length);
            for(faceIndex = 0; faceIndex < numIcons; faceIndex++)
            {
               if(faceIndex >= friendInfos.length)
               {
                  break;
               }
               icon = this.m_facepileIcons[faceIndex] as FarmIcon;
               if(Boolean(icon) && Boolean(friendInfos[faceIndex].hasOwnProperty("pic_square")))
               {
                  icon.loadIcon(friendInfos[faceIndex].pic_square);
                  icon.setIconSize(34,34);
                  icon.visible = true;
                  if(Boolean(icon.element) && Boolean(friendInfos[faceIndex].hasOwnProperty("first_name")))
                  {
                     icon.element.name_tf.text = friendInfos[faceIndex].first_name;
                     icon.element.visible = true;
                  }
               }
            }
         }
      }
      
      override public function release() : void
      {
         var icon:FarmIcon = null;
         this.m_icon = null;
         this.m_harvestCount = null;
         this.m_nameTextField = null;
         this.m_rankTextField = null;
         this.m_acceptInviteButton = null;
         this.m_joinButton = null;
         for each(icon in this.m_facepileIcons)
         {
            icon = null;
         }
         this.m_facepileIcons = null;
         this.m_joinCallback = null;
         super.release();
      }
      
      private function onJoin(event:MouseEvent) : void
      {
         if(this.m_joinCallback != null)
         {
            this.m_joinCallback(this.m_clubId);
         }
      }
   }
}


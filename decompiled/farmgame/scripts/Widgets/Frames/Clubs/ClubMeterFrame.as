package Widgets.Frames.Clubs
{
   import Classes.util.ZLocUtils;
   import Managers.Clubs.DataObjects.FarmClubBaseObject;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Clubs.FarmClubWindow2;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ClubMeterFrame extends ZwFrame
   {
      
      private var m_parentWindow:FarmClubWindow2 = null;
      
      private var m_userClubSmallLogo:FarmIcon = null;
      
      private var m_userClubBigLogo:FarmIcon = null;
      
      private var m_userClubName:ZwTextField = null;
      
      private var m_userClubTooltip:FarmTextTooltip = null;
      
      public function ClubMeterFrame(element:DisplayObject, parentWindow:FarmClubWindow2)
      {
         super(element);
         this.m_parentWindow = parentWindow;
      }
      
      public function populateData(data:FarmClubBaseObject, userClubData:FarmClubDataObject) : void
      {
         var meterIdx:String = null;
         var clubScore:int = 0;
         var widgetName:String = null;
         var clubInfo:Object = null;
         var logoId:int = 0;
         var clubName:String = null;
         var tooltip:FarmTextTooltip = null;
         var icon:FarmIcon = null;
         var logoPath:String = null;
         var idxNum:int = 0;
         var frameNum:int = 0;
         var meterInfo:Object = data.data;
         var userClubId:String = FarmClubDataManager.getInstance().clubId;
         for(meterIdx in meterInfo)
         {
            widgetName = "club_" + meterIdx + "_mc";
            if(meterInfo[meterIdx] != false && m_element.hasOwnProperty(widgetName))
            {
               clubInfo = meterInfo[meterIdx];
               logoId = 0;
               clubName = "";
               tooltip = new FarmTextTooltip();
               icon = new FarmIcon(m_element[widgetName]);
               if(clubInfo["clubId"] == userClubId)
               {
                  idxNum = parseInt(meterIdx);
                  frameNum = 100 * (idxNum / 20);
                  (m_element as MovieClip).gotoAndStop(frameNum);
                  logoId = userClubData.farmClub.clubLogoId;
                  clubName = userClubData.farmClub.clubName;
                  this.m_userClubTooltip = tooltip;
                  this.m_userClubSmallLogo = icon;
               }
               else
               {
                  logoId = int(clubInfo["clubLogoId"]);
                  clubName = clubInfo["clubName"];
               }
               logoPath = FarmClubUtility.getBackgroundLogoPathFromId(logoId);
               icon.loadIcon(logoPath);
               icon.setIconSize(50,50);
               addWidget(icon);
               tooltip.setText(clubName);
               icon.attachTooltip(tooltip);
            }
         }
         this.m_userClubName = addWidget(new ZwTextField(m_element.clubName_tf,userClubData.farmClub.clubName)) as ZwTextField;
         clubScore = 0;
         if(userClubData.clubRank != null && userClubData.clubRank.hasOwnProperty("value"))
         {
            clubScore = int(userClubData.clubRank["value"]);
         }
         addWidget(new ZwTextField(m_element.harvestAmount_tf,ZLocUtils.t("FarmClub","clubHarvests",{"num":clubScore})));
         logoPath = FarmClubUtility.getBackgroundLogoPathFromId(userClubData.farmClub.clubLogoId);
         this.m_userClubBigLogo = addWidget(new FarmIcon(m_element.clubIcon_mc,logoPath)) as FarmIcon;
         this.m_userClubBigLogo.setIconSize(70,70);
         this.m_userClubBigLogo.setSmoothing(true);
         this.m_userClubBigLogo.element.addEventListener(MouseEvent.CLICK,this.onBigIconClick);
         this.m_userClubBigLogo.element.buttonMode = true;
         addWidget(new FarmAnimatedTextButton(m_element.invite_bt,ZLocUtils.t("Dialogs","Invite"),this.onClickInvite));
      }
      
      private function onClickInvite(event:MouseEvent) : void
      {
         FarmClubUtility.showMFS();
      }
      
      private function onBigIconClick(event:MouseEvent) : void
      {
         this.m_parentWindow.onMeterIconClick();
      }
      
      public function populateNewClubData(farmClubData:FarmClubDataObject) : void
      {
         var iconPath:String = FarmClubUtility.getBackgroundLogoPathFromId(farmClubData.farmClub.clubLogoId);
         if(this.m_userClubBigLogo != null)
         {
            this.m_userClubBigLogo.loadIcon(iconPath);
         }
         if(this.m_userClubSmallLogo != null)
         {
            this.m_userClubSmallLogo.loadIcon(iconPath);
         }
         if(this.m_userClubName != null)
         {
            this.m_userClubName.text = farmClubData.farmClub.clubName;
         }
         if(this.m_userClubTooltip != null)
         {
            this.m_userClubTooltip.setText(farmClubData.farmClub.clubName);
         }
      }
   }
}


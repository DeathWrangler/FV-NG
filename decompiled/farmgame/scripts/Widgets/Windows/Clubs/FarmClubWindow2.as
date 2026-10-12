package Widgets.Windows.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.Clubs.DataObjects.FarmClubBaseObject;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.DataObjects.IFarmClubObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Clubs.ClubMeterFrame;
   import Widgets.Frames.Clubs.FarmClubBrowseCreateFrame;
   import Widgets.Frames.Clubs.FarmClubCountdownFrame;
   import Widgets.Frames.Clubs.FarmClubDrilldownFrame;
   import Widgets.Frames.Clubs.FarmClubLeaderMessageFrame;
   import Widgets.Frames.Clubs.FarmClubLeaderboardSlotContainerFrame;
   import Widgets.Frames.Clubs.FarmClubSettingsFrame;
   import Widgets.Frames.Clubs.FarmClubTierSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmClubWindow2 extends FarmWindow
   {
      
      private static const INTRO_SEEN_FLAG:String = "farmClub_intro";
      
      private static const CLUBS_DOWN_RUNTIME:String = "CLUBS_DOWN";
      
      private var m_currentClubId:String = null;
      
      private var m_helpButton:FarmAnimatedButton = null;
      
      private var m_settingsButton:FarmAnimatedButton = null;
      
      private var m_addButton:FarmAnimatedButton = null;
      
      private var m_myClubButton:FarmAnimatedButton = null;
      
      private var m_itemsLoading:int = 0;
      
      private var m_callbackIndexes:Object = {};
      
      private var m_meterData:FarmClubBaseObject = null;
      
      private var m_userClubData:FarmClubDataObject = null;
      
      private var m_meterFrame:ClubMeterFrame = null;
      
      private var m_userClubName:ZwTextField = null;
      
      private var m_userClubTierNum:ZwTextField = null;
      
      private var m_userClubTierName:ZwTextField = null;
      
      private var m_leaderPic:FarmIcon = null;
      
      private var m_leaderMessage:ZwTextField = null;
      
      private var m_leaderMessageBG:ZwWidget = null;
      
      private var m_leaderPicBG:ZwWidget = null;
      
      private var m_leaderMessageEditButton:FarmAnimatedTextButton = null;
      
      private var m_leaderMessageEditField:FarmClubLeaderMessageFrame = null;
      
      private var m_userPic:FarmIcon = null;
      
      private var m_userHarvestAmount:ZwTextField = null;
      
      private var m_userHarvestTitle:ZwTextField = null;
      
      private var m_moreInfoButton:FarmAnimatedTextButton = null;
      
      private var m_countdownFrame:FarmClubCountdownFrame = null;
      
      private var m_myClubTierLeaderboard:FarmClubLeaderboardSlotContainerFrame = null;
      
      private var m_myClubDrilldown:FarmClubDrilldownFrame = null;
      
      private var m_tierListFrame:FarmClubTierSlotContainerFrame = null;
      
      private var m_tierLeaderboard:FarmClubLeaderboardSlotContainerFrame = null;
      
      private var m_settingsFrame:FarmClubSettingsFrame = null;
      
      private var m_browseCreateFrame:FarmClubBrowseCreateFrame = null;
      
      private var m_loadingWidget:ZwWidget = null;
      
      private var m_intro:ZwWidget = null;
      
      private var m_harvestTimeWarning:ZwTextField = null;
      
      public function FarmClubWindow2()
      {
         var assetPath:String = Global.flashHotParams["CLUBS_DRILLDOWN"] ? "assets/dialogs/fv_clubs2.swf" : "assets/dialogs/fv_clubs.swf";
         super(assetPath);
         if(Global.flashHotParams[CLUBS_DOWN_RUNTIME] == false)
         {
            this.m_currentClubId = FarmClubDataManager.getInstance().clubId;
            if(this.m_currentClubId != null)
            {
               this.m_userClubData = FarmClubDataManager.getInstance().getFarmClubDataObject();
               if(this.m_userClubData == null)
               {
                  this.handleUnloadedData(FarmClubDataManager.FARM_CLUB_DATA,this.populateUserClubInfo);
               }
               this.m_meterData = FarmClubDataManager.getInstance().getMeterData();
               if(this.m_meterData == null)
               {
                  this.handleUnloadedData(FarmClubDataManager.METER_FRAME_DATA,this.populateMeterFrame);
               }
            }
         }
      }
      
      private function handleUnloadedData(dataType:String, populateFunction:Function) : void
      {
         ++this.m_itemsLoading;
         this.m_callbackIndexes[dataType] = FarmClubDataManager.getInstance().registerCaller(dataType,function(result:IFarmClubObject):void
         {
            --m_itemsLoading;
            if(m_itemsLoading <= 0)
            {
               m_itemsLoading = Math.max(m_itemsLoading,0);
               setLoadingSpinnerVisible(false);
            }
            populateFunction(result);
            FarmClubDataManager.getInstance().unregisterCaller(m_callbackIndexes[dataType]);
         });
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Global.flashHotParams[CLUBS_DOWN_RUNTIME] == true)
         {
            UI.displayMessage(ZLocUtils.t("FarmClub","clubsDown"),GenericPopup.TYPE_OK,function(e:Event):void
            {
               close();
            },"noClubs",true);
         }
         else
         {
            if(this.m_itemsLoading > 0)
            {
               this.setLoadingSpinnerVisible(true);
            }
            this.m_helpButton = new FarmAnimatedButton(m_window.help_bt,this.onHelp);
            addWidget(this.m_helpButton,false);
            this.m_settingsButton = new FarmAnimatedButton(m_window.settings_bt,this.onSettings);
            addWidget(this.m_settingsButton,false);
            this.m_addButton = new FarmAnimatedButton(m_window.add_bt,this.onAdd);
            addWidget(this.m_addButton,false);
            this.m_myClubButton = new FarmAnimatedButton(m_window.friend_bt,this.onMoreInfo);
            addWidget(this.m_myClubButton,false);
            this.m_userClubName = new ZwTextField(m_window.clubName_tf);
            addWidget(this.m_userClubName,false);
            this.m_userClubTierNum = new ZwTextField(m_window.stageNumber_tf);
            addWidget(this.m_userClubTierNum,false);
            this.m_userClubTierName = new ZwTextField(m_window.stageTitle_tf);
            addWidget(this.m_userClubTierName,false);
            this.m_leaderPic = new FarmIcon(m_window.leaderPic_mc);
            addWidget(this.m_leaderPic,false);
            this.m_leaderMessage = new ZwTextField(m_window.leaderMessage_tf);
            addWidget(this.m_leaderMessage,false);
            this.m_leaderMessageBG = new ZwWidget(m_window.leaderMessageBG_mc);
            addWidget(this.m_leaderMessageBG,false);
            this.m_leaderPicBG = new ZwWidget(m_window.leaderPicBG_mc);
            addWidget(this.m_leaderPicBG,false);
            this.m_leaderMessageEditButton = new FarmAnimatedTextButton(m_window.edit_bt,ZLocUtils.t("FarmClub","edit"),this.onEdit);
            addWidget(this.m_leaderMessageEditButton,false);
            this.m_userPic = new FarmIcon(m_window.profilePic_mc,Global.player.picture);
            addWidget(this.m_userPic,false);
            this.m_userHarvestAmount = new ZwTextField(m_window.harvestAmount_tf);
            addWidget(this.m_userHarvestAmount,false);
            this.m_userHarvestTitle = new ZwTextField(m_window.harvestTitle_tf,ZLocUtils.t("FarmClub","MyClub_MyTotalTitle"));
            addWidget(this.m_userHarvestTitle,false);
            this.m_moreInfoButton = new FarmAnimatedTextButton(m_window.moreInfo_bt,ZLocUtils.t("FarmClub","clubInfo"),this.onMoreInfo);
            addWidget(this.m_moreInfoButton,false);
            this.m_countdownFrame = new FarmClubCountdownFrame(m_window.countdown_mc,this);
            addWidget(this.m_countdownFrame,false);
            this.m_tierListFrame = new FarmClubTierSlotContainerFrame(m_window.topClubsBar_mc,this);
            addWidget(this.m_tierListFrame,false);
            this.m_harvestTimeWarning = new ZwTextField(m_window.harvestTimeWarning_tf,ZLocUtils.t("FarmClub","harvestTimeWarn"));
            addWidget(this.m_harvestTimeWarning,false);
            this.populateUserClubInfo();
            this.m_meterFrame = new ClubMeterFrame(m_window.gauge_mc,this);
            addWidget(this.m_meterFrame,false);
            this.populateMeterFrame();
         }
      }
      
      override protected function release() : void
      {
         var callbackType:String = null;
         super.release();
         this.m_myClubButton = null;
         this.m_meterFrame = null;
         this.m_userClubName = null;
         this.m_userClubTierName = null;
         this.m_userClubTierNum = null;
         this.m_leaderMessage = null;
         this.m_leaderMessageEditButton = null;
         this.m_leaderMessageEditField = null;
         this.m_leaderPic = null;
         this.m_userPic = null;
         this.m_userHarvestAmount = null;
         this.m_userHarvestTitle = null;
         this.m_countdownFrame = null;
         this.m_myClubTierLeaderboard = null;
         this.m_tierListFrame = null;
         this.m_tierLeaderboard = null;
         this.m_helpButton = null;
         this.m_settingsButton = null;
         this.m_addButton = null;
         this.m_myClubDrilldown = null;
         for(callbackType in this.m_callbackIndexes)
         {
            FarmClubDataManager.getInstance().unregisterCaller(this.m_callbackIndexes[callbackType]);
         }
         this.m_callbackIndexes = null;
      }
      
      private function populateMeterFrame(inputData:FarmClubBaseObject = null) : void
      {
         if(inputData != null)
         {
            this.m_meterData = inputData;
         }
         if(this.m_meterFrame != null && this.m_meterData != null && this.m_userClubData != null)
         {
            this.m_meterFrame.visible = true;
            this.m_meterFrame.populateData(this.m_meterData,this.m_userClubData);
            this.populateUserClubInfo();
         }
      }
      
      private function populateUserClubInfo(inputData:FarmClubDataObject = null) : void
      {
         var iconUrl:String = null;
         var iconSize:int = 0;
         if(inputData != null)
         {
            this.m_userClubData = inputData;
         }
         if(this.m_userClubData != null && this.m_itemsLoading == 0)
         {
            if(!Global.player.getSeenFlag(INTRO_SEEN_FLAG))
            {
               this.m_intro = addWidget(new ZwWidget(m_window.ftue_mc)) as ZwWidget;
               (this.m_intro.element as MovieClip).gotoAndPlay(1);
               (this.m_intro.element as MovieClip).addEventListener(Event.ENTER_FRAME,this.onIntroEnterFrame);
            }
            else
            {
               if(this.m_settingsButton != null)
               {
                  this.m_settingsButton.visible = true;
                  this.m_settingsButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("FarmClub","settings_tip")));
               }
               if(this.m_addButton != null)
               {
                  this.m_addButton.visible = true;
                  this.m_addButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("FarmClub","add_tip")));
               }
               if(this.m_myClubButton != null)
               {
                  this.m_myClubButton.visible = true;
                  this.m_myClubButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("FarmClub","myClub_tip")));
               }
               if(this.m_helpButton != null)
               {
                  this.m_helpButton.visible = true;
                  this.m_helpButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("FarmClub","help_tip")));
               }
               if(this.m_userClubName != null)
               {
                  this.m_userClubName.text = this.m_userClubData.farmClub.clubName;
                  this.m_userClubName.visible = true;
               }
               if(this.m_userClubTierNum != null)
               {
                  this.m_userClubTierNum.text = ZLocUtils.t("FarmClub","stageNum",{"num":this.m_userClubData.farmClub.currentTier});
                  this.m_userClubTierNum.visible = true;
               }
               if(this.m_userClubTierName != null)
               {
                  this.m_userClubTierName.text = ZLocUtils.t("FarmClub","stageTitle",{"name":ZLocUtils.t("FarmClub","stageName_" + this.m_userClubData.farmClub.currentTier)});
                  this.m_userClubTierName.visible = true;
               }
               if(this.m_leaderPic != null)
               {
                  iconUrl = "";
                  if(ObjectUtil.pathExists(this.m_userClubData,["leaderInfo","pic_square"]))
                  {
                     iconUrl = this.m_userClubData.leaderInfo["pic_square"];
                  }
                  else
                  {
                     iconUrl = FarmClubUtility.getBadgePathForClubRank("leader");
                  }
                  this.m_leaderPic.loadIcon(iconUrl);
                  this.m_leaderPic.visible = true;
                  this.m_leaderPic.setIconSize(50,50);
                  this.m_leaderPicBG.visible = true;
               }
               if(this.m_leaderMessage != null)
               {
                  this.m_leaderMessage.text = this.m_userClubData.farmClub.message;
                  this.m_leaderMessage.visible = true;
                  this.m_leaderMessageBG.visible = true;
               }
               if(this.m_userPic != null)
               {
                  iconSize = 100;
                  this.m_userPic.setIconSize(iconSize,iconSize);
                  this.m_userPic.setSmoothing(true);
                  this.m_userPic.visible = true;
               }
               if(this.m_userHarvestAmount != null)
               {
                  this.m_userHarvestAmount.text = this.m_userClubData.myRank != null ? this.m_userClubData.myRank.value : "0";
                  if(!Global.player.getSeenSessionFlag("Clubs_Harvest_Amount") && this.m_userClubData.farmClub != null && this.m_userClubData.farmClub.clubId != null)
                  {
                     Global.player.setSeenSessionFlag("Clubs_Harvest_Amount",true);
                     FarmStatsManager.count("club_individual","Clubs",this.m_userClubData.farmClub.clubId.toString(),"harvest",this.m_userHarvestAmount.text);
                  }
                  this.m_userHarvestAmount.visible = true;
                  this.m_userHarvestTitle.visible = true;
                  this.m_moreInfoButton.visible = true;
               }
               if(this.m_countdownFrame != null)
               {
                  this.m_countdownFrame.populatePlantNow(FarmClubUtility.getFarmItemFromTier(this.m_userClubData.farmClub.currentTier));
                  this.m_countdownFrame.visible = true;
               }
               if(this.m_leaderMessageEditButton != null)
               {
                  if(this.m_userClubData.farmClub.getLeader() == Global.player.uid)
                  {
                     this.m_leaderMessageEditButton.visible = true;
                  }
               }
               if(this.m_tierListFrame != null)
               {
                  this.m_tierListFrame.visible = true;
               }
               if(this.m_harvestTimeWarning != null)
               {
                  this.m_harvestTimeWarning.visible = true;
               }
            }
         }
         else if(this.m_currentClubId == null)
         {
            this.onAdd(null);
            if(this.m_userClubName != null)
            {
               this.m_userClubName.text = ZLocUtils.t("FarmClub","FarmClubWindow_Title");
               this.m_userClubName.visible = true;
            }
         }
      }
      
      private function onIntroEnterFrame(event:Event) : void
      {
         if((this.m_intro.element as MovieClip).currentFrame >= (this.m_intro.element as MovieClip).totalFrames)
         {
            (this.m_intro.element as MovieClip).stop();
            (this.m_intro.element as MovieClip).removeEventListener(Event.ENTER_FRAME,this.onIntroEnterFrame);
            this.m_intro.visible = false;
            Global.player.setSeenFlag(INTRO_SEEN_FLAG);
            this.populateUserClubInfo();
         }
      }
      
      private function onMoreInfo(event:Event) : void
      {
         FarmStatsManager.count("club_buttons","drill_down_myclub","click");
         if(Global.flashHotParams["CLUBS_DRILLDOWN"])
         {
            this.displayDrilldown(this.m_userClubData.farmClub.clubId);
         }
         else if(this.m_myClubTierLeaderboard == null)
         {
            this.m_myClubTierLeaderboard = addWidget(new FarmClubLeaderboardSlotContainerFrame(m_window.currentStageLeaderboard_mc,this.m_userClubData.farmClub.currentTier,FarmClubLeaderboardSlotContainerFrame.LEADERBOARD_VIEW_ROSTER,-1,this.m_userClubData.farmClub)) as FarmClubLeaderboardSlotContainerFrame;
         }
         else
         {
            this.m_myClubTierLeaderboard.setUserClub(this.m_userClubData.farmClub);
            this.m_myClubTierLeaderboard.setView(FarmClubLeaderboardSlotContainerFrame.LEADERBOARD_VIEW_ROSTER);
            this.m_myClubTierLeaderboard.visible = true;
         }
      }
      
      private function displayDrilldown(clubId:String) : void
      {
         if(this.m_myClubDrilldown == null)
         {
            this.m_myClubDrilldown = new FarmClubDrilldownFrame(m_window.drillDown_mc,clubId,this);
         }
         else
         {
            this.m_myClubDrilldown.setUserClub(clubId);
            this.m_myClubDrilldown.visible = true;
         }
      }
      
      private function onHelp(event:Event) : void
      {
         TutorialUI.displayBundleTutorialWindow("FarmClub","clubWhat_","assets/dialogs/4d_elements/Clubs/clubs");
      }
      
      private function onSettings(event:Event) : void
      {
         if(this.m_settingsFrame == null)
         {
            this.m_settingsFrame = addWidget(new FarmClubSettingsFrame(m_window.settings_mc,this.m_userClubData.farmClub,this.onSettingsSave,this)) as FarmClubSettingsFrame;
         }
         else
         {
            this.m_settingsFrame.visible = true;
            this.m_settingsFrame.repopulateClubData(this.m_userClubData.farmClub);
         }
      }
      
      private function onSettingsSave(clubNameInput:String, clubLogoId:String, isPrivate:Boolean) : void
      {
         FarmClubUtility.updateClubInfo(clubNameInput,clubLogoId,isPrivate);
         var newData:FarmClubDataObject = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
         this.populateUserClubInfo(newData);
         if(this.m_meterFrame)
         {
            this.m_meterFrame.populateNewClubData(newData);
         }
      }
      
      private function onAdd(event:Event) : void
      {
         if(this.m_browseCreateFrame == null)
         {
            this.m_browseCreateFrame = addWidget(new FarmClubBrowseCreateFrame(m_window.add_mc,this)) as FarmClubBrowseCreateFrame;
         }
         else
         {
            this.m_browseCreateFrame.visible = true;
         }
      }
      
      public function clubClickCallback(clubId:String, event:Event) : void
      {
         this.displayDrilldown(clubId);
      }
      
      public function onMeterIconClick() : void
      {
         FarmStatsManager.count("club_buttons","clubIcon","click");
         if(this.m_myClubTierLeaderboard == null)
         {
            this.m_myClubTierLeaderboard = addWidget(new FarmClubLeaderboardSlotContainerFrame(m_window.currentStageLeaderboard_mc,this.m_userClubData.farmClub.currentTier,FarmClubLeaderboardSlotContainerFrame.LEADERBOARD_VIEW_MY_TIER,-1,null,null,this)) as FarmClubLeaderboardSlotContainerFrame;
         }
         else
         {
            this.m_myClubTierLeaderboard.setView(FarmClubLeaderboardSlotContainerFrame.LEADERBOARD_VIEW_MY_TIER);
            this.m_myClubTierLeaderboard.visible = true;
         }
      }
      
      private function onEdit(event:Event) : void
      {
         FarmStatsManager.count("club_buttons","edit_message","click");
         if(this.m_leaderMessageEditField == null)
         {
            this.m_leaderMessageEditField = addWidget(new FarmClubLeaderMessageFrame(m_window.leaderMessagePop_mc,this.m_leaderMessage.text,this.populateUserClubInfo)) as FarmClubLeaderMessageFrame;
         }
         else
         {
            this.m_leaderMessageEditField.visible = true;
         }
      }
      
      private function setLoadingSpinnerVisible(visible:Boolean) : void
      {
         var element:MovieClip = null;
         var childIndex:int = 0;
         var child:MovieClip = null;
         if(m_window != null)
         {
            if(this.m_loadingWidget == null)
            {
               this.m_loadingWidget = new ZwWidget(m_window.loading_mc);
               addWidget(this.m_loadingWidget);
            }
            this.m_loadingWidget.visible = visible;
            element = this.m_loadingWidget.element as MovieClip;
            for(childIndex = 0; childIndex < element.numChildren; childIndex++)
            {
               child = element.getChildAt(childIndex) as MovieClip;
               if(!child)
               {
                  continue;
               }
               switch(visible)
               {
                  case true:
                     child.gotoAndPlay(1);
                     break;
                  case false:
                     child.stop();
               }
            }
         }
      }
      
      public function refreshLeaderMessageText(text:String) : void
      {
         if(this.m_leaderMessage != null)
         {
            this.m_leaderMessage.text = text;
         }
      }
      
      public function onTopClubsClick() : void
      {
         FarmStatsManager.count("club_buttons","Top50","click");
         if(this.m_tierLeaderboard == null)
         {
            this.m_tierLeaderboard = addWidget(new FarmClubLeaderboardSlotContainerFrame(m_window.stageLeaderboard_mc,-1,FarmClubDataManager.TOP_50_DATA,3,null,null,this)) as FarmClubLeaderboardSlotContainerFrame;
         }
         else
         {
            this.m_tierLeaderboard.setArrowIndex(3);
            this.m_tierLeaderboard.setCurrentTierIndex(-1);
            this.m_tierLeaderboard.setView(FarmClubDataManager.TOP_50_DATA);
            this.m_tierLeaderboard.visible = true;
         }
      }
      
      public function onTierSlotClick(tierClicked:int) : void
      {
         var arrowIndex:int = (tierClicked - 1) % 3;
         if(this.m_tierLeaderboard == null)
         {
            this.m_tierLeaderboard = addWidget(new FarmClubLeaderboardSlotContainerFrame(m_window.stageLeaderboard_mc,tierClicked,FarmClubDataManager.TIER_TOP_10_DATA,arrowIndex,null,null,this)) as FarmClubLeaderboardSlotContainerFrame;
         }
         else
         {
            this.m_tierLeaderboard.setCurrentTierIndex(tierClicked);
            this.m_tierLeaderboard.setArrowIndex(arrowIndex);
            this.m_tierLeaderboard.setView(FarmClubDataManager.TIER_TOP_10_DATA);
            this.m_tierLeaderboard.visible = true;
         }
      }
      
      override public function close() : void
      {
         super.close();
         if(!Global.player.getSeenFlag(FarmClubConstants.FARM_CLUB_ICON_TOASTER_SEEN_FLAG))
         {
            ToasterManager.getInstance().add(new FarmClubToaster());
            Global.player.setSeenFlag(FarmClubConstants.FARM_CLUB_ICON_TOASTER_SEEN_FLAG);
         }
      }
   }
}


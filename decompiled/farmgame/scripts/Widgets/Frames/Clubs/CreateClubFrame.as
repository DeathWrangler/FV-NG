package Widgets.Frames.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Classes.Quest.FarmQuest;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Clubs.FarmClubWindow;
   import Widgets.Windows.Quests.MultiStageQuests.MultiStageQuestWidgetFactory;
   import ZQuest.Classes.Quest;
   import ZQuest.Init.QuestSettingsInit;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CreateClubFrame extends ZwFrame
   {
      
      private var m_clubDataCallbackId:int = 0;
      
      private var m_inputNameTf:FarmTextField;
      
      private var m_joinButton:FarmButton;
      
      private var m_acceptButton:FarmAnimatedTextButton;
      
      private var m_checkmark:ZwFrame;
      
      private var m_checkBox:ZwButton;
      
      private var m_logo:ZwFrame;
      
      private var m_feedPartsWidget:ZwBaseWidget;
      
      private var m_farmClubWindow:FarmClubWindow;
      
      private var m_clubLogoSelector:ClubLogoSlotContainerFrame;
      
      private var m_headerTextfield:ZwTextField;
      
      private var m_isLeader:Boolean = false;
      
      private var m_loading:Boolean = false;
      
      public function CreateClubFrame(element:DisplayObject, farmClubWindow:FarmClubWindow)
      {
         super(element);
         if(FarmClubUtility.canCreateClub())
         {
            this.showCreateClubFrame();
         }
         else
         {
            this.showPartsCollectionFrame();
         }
         this.m_farmClubWindow = farmClubWindow;
         this.refresh();
      }
      
      private function showPartsCollectionFrame() : void
      {
         this.m_feedPartsWidget = MultiStageQuestWidgetFactory.getStageUI(this.getClubsFarmQuest(),m_element as DisplayObject,null,1,this.onCollectedAllParts);
         this.m_headerTextfield = addWidget(new ZwTextField(m_element.buildable_mc.description_tf,ZLocUtils.t("FarmClub","CreateClub_Description"))) as ZwTextField;
         if(this.m_feedPartsWidget)
         {
            addWidget(this.m_feedPartsWidget);
         }
      }
      
      private function showCreateClubFrame() : void
      {
         addWidget(new ZwBaseWidget(m_element.createSettings_mc));
         this.m_inputNameTf = addWidget(new FarmTextField(m_element.createSettings_mc.inputName_tf,"",false,true)) as FarmTextField;
         this.m_acceptButton = addWidget(new FarmAnimatedTextButton(m_element.createSettings_mc.save_bt,ZLocUtils.t("FarmClub","CreateClub_Button"),this.onAcceptButtonClicked)) as FarmAnimatedTextButton;
         this.m_checkBox = addWidget(new FarmButton(m_element.createSettings_mc.checkBox_mc,this.onCheckmarkClicked)) as ZwButton;
         this.m_checkmark = addWidget(new ZwFrame(m_element.createSettings_mc.checkMark_mc)) as ZwFrame;
         this.m_clubLogoSelector = addWidget(new ClubLogoSlotContainerFrame(m_element.createSettings_mc.logos_mc)) as ClubLogoSlotContainerFrame;
         (this.m_checkmark.element as MovieClip).mouseEnabled = false;
         addWidget(new ZwTextField(m_element.createSettings_mc.clubPublic_tf,ZLocUtils.t("FarmClub","CreateClub_Public")));
         addWidget(new ZwTextField(m_element.createSettings_mc.clubName_tf,ZLocUtils.t("FarmClub","CreateClub_ClubName")));
         addWidget(new ZwTextField(m_element.createSettings_mc.publicInstructions_tf,ZLocUtils.t("FarmClub","CreateClub_Public_Instructions")));
         addWidget(new ZwTextField(m_element.createSettings_mc.clubLogo_tf,ZLocUtils.t("FarmClub","CreateClub_ClubLogo")));
      }
      
      private function getClubsFarmQuest() : FarmQuest
      {
         var quest:Quest = QuestSettingsInit.getInstance().getItemByName(FarmClubConstants.CREATE_CLUB_QUEST_NAME);
         return quest as FarmQuest;
      }
      
      public function onAcceptButtonClicked(event:Event) : void
      {
         var clubNameInput:String = null;
         var clubLogoId:String = null;
         var isPrivate:Boolean = false;
         if(this.m_isLeader)
         {
            UI.displayPopup(new GenericPopup(ZLocUtils.t("FarmClub","CreateClub_AlreadyLeader")),false);
         }
         else
         {
            clubNameInput = this.m_inputNameTf.text;
            clubLogoId = this.m_clubLogoSelector.selectedLogoId;
            isPrivate = !this.m_checkmark.visible;
            FarmClubUtility.createClub(clubNameInput,clubLogoId,isPrivate,this.onCreateClubComplete);
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_EVENT,FarmClubWindow.BROWSE_CLUB_FRAME));
            this.m_loading = true;
         }
      }
      
      public function onCheckmarkClicked(event:Event) : void
      {
         if(this.m_checkmark != null)
         {
            this.m_checkmark.visible = !this.m_checkmark.visible;
            (this.m_checkmark.element as MovieClip).mouseEnabled = false;
         }
      }
      
      public function onCreateClubComplete(result:Object) : void
      {
         var popup:GenericPopup = null;
         if(result)
         {
            FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_COMPLETE_EVENT,FarmClubWindow.BROWSE_CLUB_FRAME));
            this.m_loading = false;
            popup = new GenericPopup(ZLocUtils.t("FarmClub","CreateClubComplete"));
            UI.displayPopup(popup,false);
         }
      }
      
      public function onCollectedAllParts() : void
      {
         removeWidget(this.m_feedPartsWidget);
         this.showCreateClubFrame();
      }
      
      public function refresh() : void
      {
         var farmClubDataObject:FarmClubDataObject = null;
         if(this.m_acceptButton == null && FarmClubUtility.canCreateClub())
         {
            this.m_acceptButton = addWidget(new FarmAnimatedTextButton(m_element.createSettings_mc.save_bt,ZLocUtils.t("FarmClub","CreateClub_Button"),this.onAcceptButtonClicked)) as FarmAnimatedTextButton;
            this.m_acceptButton.visible = true;
         }
         else if(FarmClubUtility.canCreateClub())
         {
            this.m_acceptButton.visible = true;
         }
         if(FarmClubDataManager.getInstance().clubId != null && FarmClubDataManager.getInstance().clubId != "")
         {
            farmClubDataObject = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
            if(farmClubDataObject == null)
            {
               this.unregisterClubDataCallback();
               this.m_clubDataCallbackId = FarmClubDataManager.getInstance().registerCaller(FarmClubDataManager.FARM_CLUB_DATA,this.setClubData);
               FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_EVENT,FarmClubWindow.BROWSE_CLUB_FRAME));
               this.m_loading = true;
            }
            else
            {
               this.setClubData(farmClubDataObject);
            }
         }
         else
         {
            this.m_isLeader = false;
         }
      }
      
      public function setClubData(farmClubDataObject:FarmClubDataObject) : void
      {
         FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.LOAD_COMPLETE_EVENT,FarmClubWindow.BROWSE_CLUB_FRAME));
         this.m_loading = false;
         this.m_isLeader = Global.player.uid.toString() == farmClubDataObject.farmClub.getLeader();
         if(this.m_acceptButton)
         {
            this.m_acceptButton.visible = true;
         }
      }
      
      private function unregisterClubDataCallback() : void
      {
         if(this.m_clubDataCallbackId != FarmClubDataManager.UNREGISTERED)
         {
            FarmClubDataManager.getInstance().unregisterCaller(this.m_clubDataCallbackId);
            this.m_clubDataCallbackId = FarmClubDataManager.UNREGISTERED;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_inputNameTf = null;
         this.m_joinButton = null;
         this.m_acceptButton = null;
         this.m_checkBox = null;
         this.m_checkmark = null;
         this.m_clubLogoSelector = null;
      }
   }
}


package Widgets.Frames.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Events.GenericPopupEvent;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Windows.Clubs.FarmClubWindow2;
   import Widgets.Windows.Quests.MultiStageQuests.MultiStageQuestWidgetFactory;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmClubBrowseCreateFrame extends ZwFrame
   {
      
      private var m_closeButton:FarmButton = null;
      
      private var m_createFrame:ZwFrame = null;
      
      private var m_settingsFrame:FarmClubSettingsFrame = null;
      
      private var m_createFramePopulated:Boolean = false;
      
      private var m_parentWindow:FarmClubWindow2 = null;
      
      public function FarmClubBrowseCreateFrame(element:DisplayObject, parentWindow:FarmClubWindow2)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_closeButton = addWidget(new FarmButton(m_element.close_bt,this.onClose)) as FarmButton;
         var browseTab:FarmTabButton = addWidget(new FarmTabButton(m_element.browse_bt,ZLocUtils.t("FarmClub","BrowseClub_SubTab_Title"))) as FarmTabButton;
         var createTab:FarmTabButton = addWidget(new FarmTabButton(m_element.create_bt,ZLocUtils.t("FarmClub","CreateClub_SubTab_Title"))) as FarmTabButton;
         var browseFrame:BrowseClubSlotContainerFrame = new BrowseClubSlotContainerFrame(m_element.browse_mc,parentWindow,this.m_closeButton);
         addWidget(browseFrame);
         this.m_createFrame = new ZwFrame(m_element.create_mc);
         addWidget(this.m_createFrame);
         var canCreateClub:Boolean = FarmClubUtility.canCreateClub();
         var toggleManager:ZwToggleManager = new ZwToggleManager();
         toggleManager.addToggle(new ZwVisibilityToggle(browseTab,browseFrame),!canCreateClub);
         toggleManager.addToggle(new ZwVisibilityToggle(createTab,this.m_createFrame,this.populateCreateFrame),canCreateClub);
      }
      
      private function populateCreateFrame() : void
      {
         var partsFrame:ZwBaseWidget = null;
         if(!this.m_createFramePopulated)
         {
            this.m_settingsFrame = this.m_createFrame.addWidget(new FarmClubSettingsFrame(this.m_createFrame.element.createSettings_mc,null,this.onClubCreate),false) as FarmClubSettingsFrame;
            if(FarmClubUtility.canCreateClub())
            {
               this.m_settingsFrame.visible = true;
            }
            else
            {
               partsFrame = this.m_createFrame.addWidget(MultiStageQuestWidgetFactory.getStageUI(FarmClubUtility.getClubsFarmQuest(),this.m_createFrame.element as DisplayObject,null,1,function():void
               {
                  partsFrame.visible = false;
                  m_settingsFrame.visible = true;
               }));
            }
            this.m_createFramePopulated = true;
         }
      }
      
      private function onClubCreate(clubNameInput:String, clubLogoId:String, isPrivate:Boolean) : void
      {
         var popup:GenericPopup = null;
         var currentClubId:String = FarmClubDataManager.getInstance().clubId;
         if(currentClubId != null && currentClubId != "")
         {
            popup = new GenericPopup(ZLocUtils.t("FarmClub","CreateClub_AlreayInClub"),GenericPopup.TYPE_ACCEPTCANCEL,function(event:GenericPopupEvent):void
            {
               if(event.button == GenericPopup.ACCEPT)
               {
                  onConfirmClubCreate(clubNameInput,clubLogoId,isPrivate);
               }
               else
               {
                  m_settingsFrame.visible = true;
               }
            });
            UI.displayPopup(popup,false);
         }
         else
         {
            this.onConfirmClubCreate(clubNameInput,clubLogoId,isPrivate);
         }
      }
      
      private function onConfirmClubCreate(clubNameInput:String, clubLogoId:String, isPrivate:Boolean) : void
      {
         FarmClubUtility.createClub(clubNameInput,clubLogoId,isPrivate,this.onCreateClubComplete);
         this.m_closeButton.visible = false;
         var spinner:ZwWidget = new ZwWidget(m_element.loadingSpinner_mc);
         (spinner.element as MovieClip).gotoAndPlay(1);
         addWidget(spinner);
      }
      
      private function onCreateClubComplete(result:Object) : void
      {
         this.m_parentWindow.close();
         FarmClubUtility.dispatcher.addEventListener(FarmClubConstants.CREATE_CLUB_EVENT,function(event:DynamicObjectEvent):void
         {
            FarmClubUtility.dispatcher.removeEventListener(FarmClubConstants.CREATE_CLUB_EVENT,arguments.callee);
            FarmClubUtility.showDialog();
         });
      }
      
      private function onClose(event:Event) : void
      {
         if(FarmClubDataManager.getInstance().clubId != null)
         {
            this.visible = false;
         }
         else
         {
            this.m_parentWindow.close();
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_parentWindow = null;
         this.m_settingsFrame = null;
         this.m_createFrame = null;
      }
   }
}


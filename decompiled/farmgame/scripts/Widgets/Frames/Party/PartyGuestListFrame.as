package Widgets.Frames.Party
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.PartyManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class PartyGuestListFrame extends ZwFrame
   {
      
      public static const CUSTOM_MESSAGE_CHARACTER_LIMIT:Number = 420;
      
      protected var m_containerFrame:ZwFrame;
      
      protected var m_hasFullStreamPermissions:Boolean = false;
      
      protected var m_customMessageTextInput:ZwTextField;
      
      protected var m_isFeatureEnabled:Boolean = true;
      
      public function PartyGuestListFrame(element:DisplayObject, partyIsFull:Boolean, partyIsEnabled:Boolean)
      {
         super(element);
         this.m_isFeatureEnabled = partyIsEnabled;
         if(!partyIsFull)
         {
            this.m_hasFullStreamPermissions = Global.farmSocialNetwork.userHasStreamPermissions() && Boolean(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.NEW_YEARS_PARTY_2011,FeatureOptionsManager.AUTO_PUBLISH_STREAM));
            if(this.m_hasFullStreamPermissions)
            {
               this.buildPermissionFrame();
            }
            else
            {
               this.buildNoPermissionFrame();
            }
         }
         else
         {
            this.buildPartyFullFrame();
         }
      }
      
      protected function buildPermissionFrame() : void
      {
         PartyManager.getInstance().autoPublish = this.m_hasFullStreamPermissions;
         this.m_containerFrame = addWidget(new ZwFrame(m_element.permission_mc)) as ZwFrame;
         this.m_containerFrame.addWidget(new PartyGuestListSlotFrame(m_element.permission_mc.invitePanel_mc));
         var numberOfAppFriends:uint = Global.friendManager.appFriendUids.length;
         var promptString:String = "";
         if(numberOfAppFriends > 0)
         {
            promptString = ZLocUtils.t("Dialogs","NewYearsParty_InviteFriends");
         }
         else
         {
            promptString = ZLocUtils.t("Dialogs","NewYearsParty_NoFriendsError");
         }
         this.m_containerFrame.addWidget(new ZwTextField(m_element.permission_mc.generic_tf,promptString));
         this.buildCustomMessageFrame();
      }
      
      protected function buildCustomMessageFrame() : void
      {
         var customMessageFrame:ZwFrame = addWidget(new ZwFrame(this.m_containerFrame.element.message_mc)) as ZwFrame;
         var numberOfAppFriends:uint = Global.friendManager.appFriendUids.length;
         var promptString:String = "";
         if(numberOfAppFriends > 0)
         {
            promptString = ZLocUtils.t("Dialogs","NewYearsParty_CustomMessagePrompt");
         }
         else
         {
            promptString = ZLocUtils.t("Dialogs","NewYearsParty_NoFriendsError");
         }
         customMessageFrame.addWidget(new ZwTextField(customMessageFrame.element.generic_tf,ZLocUtils.t("Dialogs","NewYearsParty_CustomMessagePrompt")));
         customMessageFrame.addWidget(new ZwTextField(customMessageFrame.element.generic2_tf,ZLocUtils.t("Dialogs","NewYearsParty_CustomMessageDescription")));
         this.m_customMessageTextInput = new ZwTextField(customMessageFrame.element.input_tf,"");
         this.m_customMessageTextInput.restrict(null,CUSTOM_MESSAGE_CHARACTER_LIMIT);
         customMessageFrame.addWidget(this.m_customMessageTextInput);
         PartyManager.getInstance().customMessageInput = this.m_customMessageTextInput;
      }
      
      public function getCustomMessageText() : String
      {
         return this.m_customMessageTextInput.text;
      }
      
      protected function buildPartyFullFrame() : void
      {
         this.m_containerFrame = addWidget(new ZwFrame(m_element.full_mc)) as ZwFrame;
         this.m_containerFrame.addWidget(new ZwTextField(this.m_containerFrame.element.generic_tf,ZLocUtils.t("Dialogs","NewYearsParty_PartyFullTitle")));
         var avatarMessageFrame:ZwFrame = new ZwFrame(this.m_containerFrame.element.avatarMessage_mc) as ZwFrame;
         this.m_containerFrame.addWidget(avatarMessageFrame);
         if(this.m_isFeatureEnabled)
         {
            avatarMessageFrame.addWidget(new ZwTextField(avatarMessageFrame.element.generic_tf,ZLocUtils.t("Dialogs","NewYearsParty_PartyFullMessage")));
            avatarMessageFrame.addWidget(new ZwTextField(avatarMessageFrame.element.generic2_tf,ZLocUtils.t("Dialogs","NewYearsParty_PartyFullMessage2")));
         }
         else
         {
            avatarMessageFrame.addWidget(new ZwTextField(avatarMessageFrame.element.generic_tf,ZLocUtils.t("Dialogs","NewYearsParty_PartyOverMessage")));
            avatarMessageFrame.addWidget(new ZwTextField(avatarMessageFrame.element.generic2_tf,ZLocUtils.t("Dialogs","NewYearsParty_PartyOverMessage2")));
         }
         this.m_containerFrame.addWidget(new PartyGuestListSlotFrame(this.m_containerFrame.element.invitePanel_mc,"FS01",true));
      }
      
      protected function buildNoPermissionFrame() : void
      {
         this.m_containerFrame = addWidget(new ZwFrame(m_element.noPermission_mc)) as ZwFrame;
         this.m_containerFrame.addWidget(new PartyGuestListSlotFrame(m_element.noPermission_mc.invitePanel_mc));
         this.m_containerFrame.addWidget(new ZwTextField(m_element.noPermission_mc.generic_tf,"Invite your friends to the party..."));
         this.buildAvatarMessageFrame();
      }
      
      protected function buildAvatarMessageFrame() : void
      {
         var avatarMessageFrame:ZwFrame = addWidget(new ZwFrame(this.m_containerFrame.element.avatarMessage_mc)) as ZwFrame;
         avatarMessageFrame.addWidget(new ZwTextField(avatarMessageFrame.element.generic_tf,ZLocUtils.t("Dialogs","DidYouKnow")));
         avatarMessageFrame.addWidget(new ZwTextField(avatarMessageFrame.element.generic2_tf,ZLocUtils.t("Dialogs","StreamPermissions_Prompt")));
         avatarMessageFrame.addWidget(new FarmAnimatedButton(avatarMessageFrame.element.allow_bt,this.onClickAllowPermissions));
         avatarMessageFrame.addWidget(new FarmAnimatedTextButton(avatarMessageFrame.element.whatisthis_mc,ZLocUtils.t("Dialogs","WhatIsThis"),this.displayAllowPermissionsWhatIsThis,true));
      }
      
      protected function onClickAllowPermissions(event:Event) : void
      {
         var hasFeatureStreamPermissions:Boolean = Boolean(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.NEW_YEARS_PARTY_2011,FeatureOptionsManager.AUTO_PUBLISH_STREAM));
         if(!Global.farmSocialNetwork.userHasStreamPermissions())
         {
            Global.farmSocialNetwork.showStreamPermissions(this.onShowStreamPermissions);
         }
         else if(!hasFeatureStreamPermissions)
         {
            this.showFeatureAutoPublishDialog();
         }
      }
      
      protected function onShowStreamPermissions() : void
      {
         if(Global.farmSocialNetwork.userHasStreamPermissions())
         {
            this.showFeatureAutoPublishDialog();
            FarmStatsManager.count("new_years_2011","extended_permissions","grant_permissions","fb_permissions");
         }
         else
         {
            FarmStatsManager.count("new_years_2011","extended_permissions","deny_permissions","fb_permissions");
         }
      }
      
      protected function showFeatureAutoPublishDialog() : void
      {
         var imageSize:Number = 100;
         var dialog:GenericXMLDialog = new GenericXMLDialog("","",null,"assets/animals/animal_duck_birthday_icon.png",imageSize,imageSize,ZLocUtils.t("Dialogs","NewYearsParty_AutoPublishPrompt"),this.onGiveFeatureAutoPublishPermission,false,ZLocUtils.t("Dialogs","Accept"),null,ZLocUtils.t("Dialogs","Cancel"),null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_LARGE);
         UI.displayPopup(dialog,false,"NYParty_autoPublish",true);
      }
      
      protected function onGiveFeatureAutoPublishPermission(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.NEW_YEARS_PARTY_2011,FeatureOptionsManager.AUTO_PUBLISH_STREAM,true);
            FeatureOptionsManager.getInstance().save();
            this.m_hasFullStreamPermissions = true;
            this.removeWidget(this.m_containerFrame);
            this.buildPermissionFrame();
            FarmStatsManager.count("new_years_2011","extended_permissions","grant_permissions","feature_specific_permissions");
         }
         else
         {
            FarmStatsManager.count("new_years_2011","extended_permissions","deny_permissions","feature_specific_permissions");
         }
      }
      
      protected function displayAllowPermissionsWhatIsThis(event:Event = null) : void
      {
         var imageSize:Number = 100;
         var dialog:GenericXMLDialog = new GenericXMLDialog("","",null,null,imageSize,imageSize,ZLocUtils.t("Dialogs","StreamPermissions_WhatIsThis"),null,false,ZLocUtils.t("Dialogs","Accept"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_LARGE);
         UI.displayPopup(dialog,false,"NYPartyStreamPermissions_howDoesThisWorkPopup",true);
         FarmStatsManager.count("new_years_2011","extended_permissions","whatisthispopup");
      }
   }
}


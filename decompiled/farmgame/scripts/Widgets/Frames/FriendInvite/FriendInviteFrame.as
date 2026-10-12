package Widgets.Frames.FriendInvite
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FriendInvite.FriendInviteSlot;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class FriendInviteFrame extends ZwFrame
   {
      
      public static const CUSTOM_MESSAGE_CHARACTER_LIMIT:Number = 420;
      
      protected var m_containerFrame:ZwFrame;
      
      protected var m_hasFullStreamPermissions:Boolean = false;
      
      protected var m_customMessageTextInput:ZwTextField;
      
      private var m_friendInviteCallback:Function = null;
      
      private var m_statName:String = "";
      
      private var m_locPrefix:String = "";
      
      private var m_friendList:Array;
      
      private var m_friendObjs:Array;
      
      public function FriendInviteFrame(element:DisplayObject, friendList:Array, statName:String, locPrefix:String, friendInviteCallback:Function)
      {
         var uid:String = null;
         this.m_friendList = new Array();
         this.m_friendObjs = new Array();
         this.m_friendList = friendList;
         var obj:Object = null;
         for each(uid in this.m_friendList)
         {
            obj = {};
            obj.uid = uid;
            obj.state = FriendInviteSlot.STATE_INVITE;
            obj.enabled = true;
            this.m_friendObjs.push(obj);
         }
         this.m_statName = statName;
         this.m_locPrefix = locPrefix;
         this.m_friendInviteCallback = friendInviteCallback;
         super(element);
         this.m_hasFullStreamPermissions = Global.farmSocialNetwork.userHasStreamPermissions() && Boolean(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.EXPANSION_INVITE,FeatureOptionsManager.AUTO_PUBLISH_STREAM));
         if(this.m_hasFullStreamPermissions)
         {
            this.buildPermissionFrame();
         }
         else
         {
            this.buildNoPermissionFrame();
         }
      }
      
      public function get friendList() : Array
      {
         return this.m_friendList;
      }
      
      public function get friendObjs() : Array
      {
         return this.m_friendObjs;
      }
      
      public function get locPrefix() : String
      {
         return this.m_locPrefix;
      }
      
      public function get friendInviteCallback() : Function
      {
         return this.m_friendInviteCallback;
      }
      
      public function updateFriend(uid:String, data:Object) : void
      {
         for(var i:Number = 0; i < this.m_friendObjs.length; i++)
         {
            if(this.m_friendObjs[i].uid == uid)
            {
               this.m_friendObjs[i] = data;
               break;
            }
         }
      }
      
      protected function buildPermissionFrame() : void
      {
         this.m_containerFrame = addWidget(new ZwFrame(m_element.permission_mc)) as ZwFrame;
         this.m_containerFrame.addWidget(new FriendInviteSlotFrame(m_element.permission_mc.invitePanel_mc,this));
         var numberOfAppFriends:uint = this.m_friendList.length;
         var promptString:String = "";
         if(numberOfAppFriends > 0)
         {
            promptString = ZLocUtils.t("Dialogs",this.m_locPrefix + "Instructions");
         }
         else
         {
            promptString = ZLocUtils.t("Dialogs",this.m_locPrefix + "NoFriendsError");
         }
         this.m_containerFrame.addWidget(new FarmTextField(m_element.permission_mc.generic_tf,promptString));
         this.buildCustomMessageFrame();
      }
      
      protected function buildCustomMessageFrame() : void
      {
         var customMessageFrame:ZwFrame = addWidget(new ZwFrame(this.m_containerFrame.element.message_mc)) as ZwFrame;
         var numberOfAppFriends:uint = this.m_friendList.length;
         var promptString:String = "";
         if(numberOfAppFriends > 0)
         {
            promptString = ZLocUtils.t("Dialogs",this.m_locPrefix + "CustomMessagePrompt");
         }
         else
         {
            promptString = ZLocUtils.t("Dialogs",this.m_locPrefix + "NoFriendsError");
         }
         customMessageFrame.addWidget(new FarmTextField(customMessageFrame.element.generic_tf,promptString));
         customMessageFrame.addWidget(new FarmTextField(customMessageFrame.element.generic2_tf,ZLocUtils.t("Dialogs",this.m_locPrefix + "CustomMessageDescription")));
         this.m_customMessageTextInput = new FarmTextField(customMessageFrame.element.input_tf,"");
         this.m_customMessageTextInput.restrict(null,CUSTOM_MESSAGE_CHARACTER_LIMIT);
         customMessageFrame.addWidget(this.m_customMessageTextInput);
      }
      
      public function getCustomMessageText() : String
      {
         var customMessage:String = "";
         if(this.m_customMessageTextInput != null)
         {
            customMessage = this.m_customMessageTextInput.text;
         }
         return customMessage;
      }
      
      protected function buildNoPermissionFrame() : void
      {
         this.m_containerFrame = addWidget(new ZwFrame(m_element.noPermission_mc)) as ZwFrame;
         this.m_containerFrame.addWidget(new FriendInviteSlotFrame(m_element.noPermission_mc.invitePanel_mc,this));
         this.m_containerFrame.addWidget(new FarmTextField(m_element.noPermission_mc.generic_tf,ZLocUtils.t("Dialogs",this.m_locPrefix + "Instructions")));
         this.buildAvatarMessageFrame();
      }
      
      protected function buildAvatarMessageFrame() : void
      {
         var avatarMessageFrame:ZwFrame = addWidget(new ZwFrame(this.m_containerFrame.element.avatarMessage_mc)) as ZwFrame;
         avatarMessageFrame.addWidget(new FarmTextField(avatarMessageFrame.element.generic_tf,ZLocUtils.t("Dialogs","DidYouKnow")));
         avatarMessageFrame.addWidget(new FarmTextField(avatarMessageFrame.element.generic2_tf,ZLocUtils.t("Dialogs","StreamPermissions_Prompt")));
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
            FarmStatsManager.count("expansions","extended_permissions","grant_permissions","fb_permissions");
         }
         else
         {
            FarmStatsManager.count("expansions","extended_permissions","deny_permissions","fb_permissions");
         }
      }
      
      protected function showFeatureAutoPublishDialog() : void
      {
         var imageSize:Number = 100;
         var dialog:GenericXMLDialog = new GenericXMLDialog("","",null,"",imageSize,imageSize,ZLocUtils.t("Dialogs",this.m_locPrefix + "AutoPublishPrompt"),this.onGiveFeatureAutoPublishPermission,false,ZLocUtils.t("Dialogs","Accept"),null,ZLocUtils.t("Dialogs","Cancel"),null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_LARGE);
         UI.displayPopup(dialog,false,"autoPublish",true);
      }
      
      protected function onGiveFeatureAutoPublishPermission(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.EXPANSION_INVITE,FeatureOptionsManager.AUTO_PUBLISH_STREAM,true);
            FeatureOptionsManager.getInstance().save();
            this.m_hasFullStreamPermissions = true;
            this.removeWidget(this.m_containerFrame);
            this.buildPermissionFrame();
            FarmStatsManager.count(this.m_statName,"extended_permissions","grant_permissions","feature_specific_permissions");
         }
         else
         {
            FarmStatsManager.count(this.m_statName,"extended_permissions","deny_permissions","feature_specific_permissions");
         }
      }
      
      protected function displayAllowPermissionsWhatIsThis(event:Event = null) : void
      {
         var imageSize:Number = 100;
         var dialog:GenericXMLDialog = new GenericXMLDialog("","",null,null,imageSize,imageSize,ZLocUtils.t("Dialogs","StreamPermissions_WhatIsThis"),null,false,ZLocUtils.t("Dialogs","Accept"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_LARGE);
         UI.displayPopup(dialog,false,"extended_howDoesThisWorkPopup",true);
         FarmStatsManager.count(this.m_statName,"extended_permissions","whatisthispopup");
      }
   }
}


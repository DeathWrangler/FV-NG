package Widgets.Slots.TicketParty
{
   import Classes.EmbeddedArt;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   
   public class TicketPartyFriendSlot extends ZwSlotFrame
   {
      
      private static const FAKE_FRIEND_PROFILE_IMAGE_URL:String = "assets/dialogs/fake_friend_profile_pic.png";
      
      private var m_friendImageIcon:FarmIcon;
      
      private var m_friendNameTextField:FarmTextField;
      
      public function TicketPartyFriendSlot(element:DisplayObject, showNames:Boolean = true)
      {
         super(element);
         this.m_friendImageIcon = new FarmIcon(this.element.loader_mc);
         this.addWidget(this.m_friendImageIcon);
         if(this.element.hasOwnProperty("name_tf") && this.element.name_tf != null && showNames)
         {
            this.m_friendNameTextField = new FarmTextField(this.element.name_tf,"");
            this.addWidget(this.m_friendNameTextField);
            this.m_friendNameTextField.selectable = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var friend:Friend = null;
         var iconUrl:String = null;
         super.populate(data);
         if(m_element.loader_mc)
         {
            Utilities.removeAllChildren(m_element.loader_mc);
         }
         this.m_friendImageIcon.visible = true;
         this.m_friendImageIcon.detachTooltip();
         if(data != null)
         {
            if(data != "-1")
            {
               if(this.m_friendNameTextField != null)
               {
                  this.m_friendNameTextField.visible = true;
               }
               if(data == FriendSet.FAKE_FRIEND_UID)
               {
                  if(this.m_friendNameTextField)
                  {
                     this.m_friendNameTextField.text = "";
                  }
                  this.m_friendImageIcon.loadIcon(FAKE_FRIEND_PROFILE_IMAGE_URL);
               }
               else
               {
                  friend = Global.friendManager.getFriendData(data as String);
                  if(friend != null)
                  {
                     if(this.m_friendNameTextField != null && Boolean(friend.name))
                     {
                        this.m_friendNameTextField.text = friend.name;
                     }
                     else if(this.m_friendNameTextField != null)
                     {
                        this.m_friendNameTextField.text = "<NO NAME>";
                     }
                     iconUrl = friend.picture;
                     if(iconUrl == null)
                     {
                        m_element.loader_mc.addChild(new EmbeddedArt.hud_no_profile_pic());
                     }
                     else
                     {
                        this.m_friendImageIcon.loadIcon(iconUrl);
                     }
                     this.m_friendImageIcon.attachTooltip(new FarmTextTooltip(friend.name));
                  }
                  else
                  {
                     m_element.loader_mc.addChild(new EmbeddedArt.hud_no_profile_pic());
                     if(this.m_friendNameTextField != null)
                     {
                        this.m_friendNameTextField.text = "<" + (data as String) + ">";
                     }
                  }
               }
            }
            else
            {
               if(this.m_friendNameTextField != null)
               {
                  this.m_friendNameTextField.visible = false;
                  this.m_friendNameTextField.text = "";
               }
               attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","TicketPartyBuilding_AskForVotesTooltip")));
            }
         }
         else if(this.m_friendNameTextField != null)
         {
            this.m_friendNameTextField.visible = true;
            this.m_friendNameTextField.text = "<NULL>";
         }
      }
   }
}

